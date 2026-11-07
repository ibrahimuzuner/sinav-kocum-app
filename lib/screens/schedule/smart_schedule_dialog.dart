import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/smart_scheduler_service.dart';

class SmartScheduleDialog extends StatefulWidget {
  const SmartScheduleDialog({super.key});

  @override
  State<SmartScheduleDialog> createState() => _SmartScheduleDialogState();
}

class _SmartScheduleDialogState extends State<SmartScheduleDialog> {
  late int _dailyMinutes;
  ScheduleStrategy _strategy = ScheduleStrategy.focusWeak;
  StudyContentMode _contentMode = StudyContentMode.hybrid;
  bool _includeSunday = false;
  final bool _replaceExisting = true;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _dailyMinutes = userProvider.dailyTargetHours * 60;
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tespit edilen zayıf dersler
    final List<String> weakCourses = [];
    for (final course in studyProvider.courses) {
      final logs = studyProvider.questionLogs.where((l) => l.courseId == course.id).toList();
      final totalQ = logs.fold(0, (sum, l) => sum + l.totalQuestions);
      final correct = logs.fold(0, (sum, l) => sum + l.correctCount);
      if (totalQ > 0) {
        final accuracy = (correct / totalQ) * 100;
        if (accuracy < 60) {
          weakCourses.add('${course.name} (%${accuracy.toInt()})');
        }
      }
    }

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Başlık & Kapat butonu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4F46E5), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Akıllı Program Sihirbazı',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${userProvider.displayName} • ${userProvider.targetExam}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sınav Türü & Hedef Bölüm / Puan Yapay Zeka Bilgilendirmesi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4F46E5).withValues(alpha: 0.12),
                    const Color(0xFF6366F1).withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_rounded, color: Color(0xFF4F46E5), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Yapay Zeka Koç Analizi (${userProvider.targetDepartment})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hedef Puan: ${userProvider.targetScore.toInt()} Puan • Gereken Net: ~${userProvider.targetNet.toStringAsFixed(1)} Net\n'
                    'Yapay Zeka, bu hedefin puan barajına, ders katsayılarına ve konu durumuna göre haftalık ders bloklarını optimize eder.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Zayıf Dersler Tespit Kutusu
            if (weakCourses.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF59E0B), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Eksik tespit edilen dersler: ${weakCourses.join(', ')}. Bu derslere programda öncelik verilecek.',
                        style: const TextStyle(fontSize: 12, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

            // ADIM 1: Günlük Çalışma Süresi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Günlük Çalışma Süresi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(_dailyMinutes / 60).round()} Saat / Gün',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildTimeChip(label: '2 Saat', minutes: 120),
                _buildTimeChip(label: '3 Saat', minutes: 180),
                _buildTimeChip(label: '4 Saat', minutes: 240),
                _buildTimeChip(label: '5 Saat', minutes: 300),
                _buildTimeChip(label: '6 Saat', minutes: 360),
              ],
            ),
            const SizedBox(height: 20),

            // ADIM 2: Konu Hazırlık Durumu & Çalışma Şekli (Kullanıcı Talebi)
            const Text(
              'Konu Hazırlık Durumun (Çalışma Şekli)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Yapay zeka, ders bloklarını konu tekrarı ve soru oranına göre planlar.',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),
            _buildContentModeCard(
              title: '🎯 30 dk Video / Konu Tekrarı + Soru Çözümü (Önerilen)',
              description: 'Önce 30 dk özet video veya konu tekrarı, ardından konuyu pekiştiren soru çözümü.',
              value: StudyContentMode.hybrid,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildContentModeCard(
              title: '🚀 Konularım Tamam (Sadece Soru Çözümü & Deneme)',
              description: 'Konu eksiğim yok. Doğrudan zamanlı testler, soru kampları ve hız pratiği hazırla.',
              value: StudyContentMode.practiceOnly,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildContentModeCard(
              title: '📖 Sıfırdan Başlıyorum (Ağırlıklı Konu Anlatımı)',
              description: 'Konuları yeni öğreniyorum. 40 dk detaylı video ders anlatımı + 15 temel pekiştirme sorusu.',
              value: StudyContentMode.conceptFocus,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // ADIM 3: Strateji Seçimi
            const Text(
              'Çalışma Stratejisi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildStrategyCard(
              title: '🎯 Zayıf Dersleri Güçlendir (Önerilen)',
              description: 'Başarı ve net oranının düşük olduğu derslere daha fazla gün ve süre ayırır.',
              value: ScheduleStrategy.focusWeak,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildStrategyCard(
              title: '⚖️ Dengeli Dağılım',
              description: 'Tüm dersleri haftanın günlerine dengeli ve eşit şekilde yayar.',
              value: ScheduleStrategy.balanced,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildStrategyCard(
              title: '🚀 Yoğun Sınav Kampı',
              description: 'Yüksek soru hedefleri ve zamanlı test pratiği odaklı yoğun program.',
              value: ScheduleStrategy.intensive,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // ADIM 4: Dinlenme Günü
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pazar Günü Dinlenme Günü Olsun', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Haftada 1 gün zihnini dinlendirmek verimi artırır', style: TextStyle(fontSize: 11)),
              value: !_includeSunday,
              activeColor: const Color(0xFF4F46E5),
              onChanged: (val) {
                setState(() => _includeSunday = !val);
              },
            ),
            const Divider(height: 16),

            // Buton
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final count = await studyProvider.applySmartSchedule(
                    dailyMinutes: _dailyMinutes,
                    strategy: _strategy,
                    includeSunday: _includeSunday,
                    targetExam: userProvider.targetExam,
                    targetDepartment: userProvider.targetDepartment,
                    targetScore: userProvider.targetScore,
                    targetNet: userProvider.targetNet,
                    contentMode: _contentMode,
                    replaceExisting: _replaceExisting,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✨ ${userProvider.targetDepartment} (${userProvider.targetScore.toInt()} Puan) için $count adet yapay zeka hedefi hazırlandı!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.bolt_rounded),
                label: const Text(
                  'Programı Otomatik Oluştur',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip({required String label, required int minutes}) {
    final isSelected = _dailyMinutes == minutes;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _dailyMinutes = minutes),
      selectedColor: const Color(0xFF4F46E5),
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : null,
      ),
    );
  }

  Widget _buildContentModeCard({
    required String title,
    required String description,
    required StudyContentMode value,
    required bool isDark,
  }) {
    final isSelected = _contentMode == value;

    return InkWell(
      onTap: () => setState(() => _contentMode = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5).withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF4F46E5) : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Radio<StudyContentMode>(
              value: value,
              groupValue: _contentMode,
              activeColor: const Color(0xFF4F46E5),
              onChanged: (val) {
                if (val != null) setState(() => _contentMode = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyCard({
    required String title,
    required String description,
    required ScheduleStrategy value,
    required bool isDark,
  }) {
    final isSelected = _strategy == value;

    return InkWell(
      onTap: () => setState(() => _strategy = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5).withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF4F46E5) : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Radio<ScheduleStrategy>(
              value: value,
              groupValue: _strategy,
              activeColor: const Color(0xFF4F46E5),
              onChanged: (val) {
                if (val != null) setState(() => _strategy = val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
