import 'package:flutter/material.dart';
import '../../../models/user_profile_model.dart';
import '../../../providers/study_provider.dart';
import '../../schedule/smart_schedule_dialog.dart';

class TargetGoalCard extends StatelessWidget {
  final UserProfileModel? userProfile;
  final StudyProvider studyProvider;

  const TargetGoalCard({
    super.key,
    required this.userProfile,
    required this.studyProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final department = userProfile?.targetDepartment.isNotEmpty == true
        ? userProfile!.targetDepartment
        : 'Genel Başarı Hedefi';
    final targetScore = (userProfile?.targetScore ?? 400.0).toInt();
    final targetNet = userProfile?.targetNet ?? 75.0;

    // Öğrencinin son performansı (En son deneme veya ortalama net)
    final latestMock = studyProvider.latestMockExam;
    final double currentNet = latestMock != null ? latestMock.totalNet : studyProvider.todayNetScore;
    final bool hasMock = latestMock != null;

    final double progress = targetNet > 0 ? (currentNet / targetNet).clamp(0.0, 1.0) : 0.0;
    final double remainingNet = (targetNet - currentNet).clamp(0.0, 999.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF2E1065)]
              : [const Color(0xFF4338CA), const Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Rozet & AI Başlığı
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Yapay Zeka Hedef Takibi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$targetScore Puan Hedefi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bölüm Adı
            Text(
              department,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${userProfile?.targetExam ?? 'Sınav'} • Taban Net Hedefi: ${targetNet.toStringAsFixed(1)} Net',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 14),

            // İlerleme Çubuğu ve Net Durumu
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasMock
                      ? 'Son Deneme: ${currentNet.toStringAsFixed(1)} Net'
                      : (currentNet > 0 ? 'Bugünkü Net: ${currentNet.toStringAsFixed(1)} Net' : 'İlk denemeni kaydet'),
                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                Text(
                  remainingNet > 0
                      ? 'Hedefe ${remainingNet.toStringAsFixed(1)} Net Kaldı'
                      : '🎉 Hedefe Ulaşıldı!',
                  style: TextStyle(
                    color: remainingNet > 0 ? Colors.amberAccent : const Color(0xFF34D399),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Yapay Zeka Program Butonu
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const SmartScheduleDialog(),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Yapay Zeka Çalışma Programını Hazırla / Güncelle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 11),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
