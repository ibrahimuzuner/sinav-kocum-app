import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/formatters.dart';
import '../questions/add_question_dialog.dart';
import '../schedule/schedule_card.dart';
import '../mock_exams/mock_exam_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../widgets/premium_upgrade_modal.dart';
import 'widgets/quick_actions.dart';
import 'widgets/quote_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/today_summary_card.dart';
import 'widgets/target_goal_card.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final todayWeekday = DateTime.now().weekday;
    final todayScheduleItems = studyProvider.getScheduleForDay(todayWeekday);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Merhaba, ${userProvider.displayName} 👋',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (userProvider.isEmailVerified) ...[
                  const SizedBox(width: 6),
                  const Tooltip(
                    message: 'Onaylı Öğrenci Hesabı',
                    child: Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                  ),
                ],
                if (userProvider.isPremium) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Text('👑 PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                  ),
                ],
              ],
            ),
            Text(
              '${userProvider.targetDepartment} • ${userProvider.targetScore.toInt()} Puan Hedefi',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          if (userProvider.isAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
                icon: const Icon(Icons.shield_rounded, size: 16, color: Colors.amber),
                label: const Text(
                  'Yönetici',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.amber, width: 1.2),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Karanlık/Aydınlık Mod',
            icon: Icon(
              settingsProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => settingsProvider.toggleTheme(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          studyProvider.loadData();
          await userProvider.syncCloudUserData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seri Kartı
              StreakCard(
                streakDays: studyProvider.streak,
                didStudyToday: studyProvider.didStudyToday,
              ),
              const SizedBox(height: 14),

              // 👑 Koçluk Tavsiyesi (PRO) veya PRO Tanıtım Kartı
              if (userProvider.isPremium || userProvider.isAdmin) ...[
                _buildCoachFeedbackCard(context, userProvider, isDark),
                const SizedBox(height: 14),
              ] else ...[
                _buildProUpgradeBanner(context, isDark),
                const SizedBox(height: 14),
              ],

              // 📧 E-posta Onay Hatırlatması (Eğer henüz onaylanmamışsa)
              if (!userProvider.isEmailVerified && userProvider.email.isNotEmpty) ...[
                _buildEmailVerificationNotice(context, userProvider),
                const SizedBox(height: 14),
              ],

              // 🎯 Yapay Zeka Hedef & Puan Takip Kartı
              TargetGoalCard(
                userProfile: userProvider.userProfile,
                studyProvider: studyProvider,
              ),
              const SizedBox(height: 14),

              // Günlük Motivasyon Sözü
              const QuoteCard(),
              const SizedBox(height: 16),

              // Bugünün Çalışma Özeti
              TodaySummaryCard(
                totalQuestions: studyProvider.todayTotalQuestions,
                targetQuestions: settingsProvider.targetQuestions,
                netScore: studyProvider.todayNetScore,
                correctCount: studyProvider.todayCorrectCount,
                wrongCount: studyProvider.todayWrongCount,
                emptyCount: studyProvider.todayEmptyCount,
                studyMinutes: studyProvider.todayStudyMinutes,
                targetMinutes: settingsProvider.targetMinutes,
              ),
              const SizedBox(height: 16),

              // DENEME SINAVI TAKİBİ HIZLI ERİŞİM KARTI
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const MockExamScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3730A3), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.assignment_turned_in_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Deneme Sınavı Takibi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (studyProvider.mockExamCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${studyProvider.mockExamCount} Deneme',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              studyProvider.latestMockExam != null
                                  ? 'Son Net: ${studyProvider.latestMockExam!.totalNet.toStringAsFixed(1)} • En Yüksek: ${studyProvider.highestMockNet.toStringAsFixed(1)} Net'
                                  : 'Denemelerini ekle, net gelişimini grafikle takip et!',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hızlı Aksiyonlar
              QuickActions(
                onStartTimer: () => onNavigateTab(1), // Tab 1: Timer
                onAddQuestions: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => const AddQuestionDialog(),
                  );
                },
                onOpenSchedule: () => onNavigateTab(3), // Tab 3: Schedule
              ),
              const SizedBox(height: 22),

              // Bugünün Programı Başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Bugünün Programı',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          Formatters.formatDayOfWeek(todayWeekday),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab(3),
                    child: const Text('Tümünü Gör'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (todayScheduleItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Bugün için henüz bir görev eklenmemiş.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab(3),
                        child: const Text('Hedef Ekle'),
                      ),
                    ],
                  ),
                )
              else
                ...todayScheduleItems.map((item) {
                  final course = studyProvider.allCourses.firstWhere(
                    (c) => c.id == item.courseId,
                    orElse: () => CourseModel(
                      id: item.courseId,
                      name: item.courseName,
                      colorValue: 0xFF4F46E5,
                    ),
                  );
                  return ScheduleCard(
                    item: item,
                    course: course,
                    onToggle: () => studyProvider.toggleScheduleCompleted(item.id),
                    onDelete: () => studyProvider.deleteScheduleItem(item.id),
                  );
                }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailVerificationNotice(BuildContext context, UserProvider userProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2415) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_unread_rounded, color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'E-posta Adresinizi Onaylayın',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${userProvider.email} adresine doğrulama bağlantısı gönderildi.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        final ok = await userProvider.checkEmailVerification();
                        if (context.mounted) {
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Tebrikler! E-posta adresiniz başarıyla onaylandı.'),
                                backgroundColor: Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Henüz e-postadaki linke tıklanmamış görünüyor. Lütfen gelen kutunuzu (veya spam klasörünü) kontrol edin.'),
                                backgroundColor: Color(0xFFF59E0B),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Onayladım', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        await userProvider.sendVerificationEmail();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Doğrulama bağlantısı tekrar gönderildi.'),
                              backgroundColor: Color(0xFF4F46E5),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tekrar Gönder',
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF334155),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachFeedbackCard(BuildContext context, UserProvider userProvider, bool isDark) {
    final note = userProvider.coachNote;
    final hasNote = note != null && note.trim().isNotEmpty;
    final updated = userProvider.coachNoteUpdatedAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFFFEF3C7), const Color(0xFFFFFBEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👨‍🏫 Koçun İbrahim\'den Sana Özel Tavsiye',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF78350F),
                      ),
                    ),
                    Text(
                      '👑 Birebir Koçluk Desteği',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              hasNote
                  ? note
                  : 'Koçun İbrahim çalışmalarını ve soru çözümlerini inceliyor. Performansını analiz edip sana özel haftalık stratejini buraya iletecek!',
              style: TextStyle(
                fontSize: 13,
                fontStyle: hasNote ? FontStyle.normal : FontStyle.italic,
                height: 1.4,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                fontWeight: hasNote ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (updated != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Son Güncelleme: ${Formatters.formatDateTurkish(updated)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProUpgradeBanner(BuildContext context, bool isDark) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const PremiumUpgradeModal(source: 'coach'),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👑 Sınav Koçum PRO\'ya Yükselt',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Özel koç tavsiyesi, renkli PDF karne & sınırsız deneme!',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFF59E0B), size: 14),
          ],
        ),
      ),
    );
  }
}
