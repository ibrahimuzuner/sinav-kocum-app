import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/timer_provider.dart';
import '../../utils/formatters.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final studyProvider = Provider.of<StudyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isPomodoro = timerProvider.mode == TimerMode.pomodoro;
    final totalSeconds = isPomodoro
        ? timerProvider.pomodoroSecondsRemaining
        : timerProvider.secondsElapsed;

    final pomodoroTotal = (timerProvider.pomodoroPhase == PomodoroPhase.study
            ? timerProvider.pomodoroStudyMinutes
            : timerProvider.pomodoroRestMinutes) *
        60;
    final pomodoroPercent = isPomodoro && pomodoroTotal > 0
        ? (1.0 - (timerProvider.pomodoroSecondsRemaining / pomodoroTotal)).clamp(0.0, 1.0)
        : 1.0;

    final todaySessions = studyProvider.studySessions
        .where((s) => Formatters.isSameDay(s.date, DateTime.now()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Sayacı'),
        actions: [
          if (isPomodoro)
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              tooltip: 'Pomodoro Ayarları',
              onPressed: () => _showPomodoroSettings(context, timerProvider),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Mod Seçici: Kronometre vs Pomodoro
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeTab(
                      context,
                      title: 'Kronometre',
                      icon: Icons.timer_outlined,
                      isSelected: !isPomodoro,
                      onTap: () => timerProvider.setMode(TimerMode.stopwatch),
                    ),
                  ),
                  Expanded(
                    child: _buildModeTab(
                      context,
                      title: 'Pomodoro',
                      icon: Icons.alarm_rounded,
                      isSelected: isPomodoro,
                      onTap: () => timerProvider.setMode(TimerMode.pomodoro),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ders & Konu Seçim Hapı (Pill)
            InkWell(
              onTap: () => _showCourseTopicPicker(context, timerProvider, studyProvider),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: timerProvider.selectedCourse != null
                        ? Color(timerProvider.selectedCourse!.colorValue).withValues(alpha: 0.5)
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    width: timerProvider.selectedCourse != null ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (timerProvider.selectedCourse != null)
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Color(timerProvider.selectedCourse!.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      timerProvider.selectedCourse?.name ?? 'Ders Seçilmedi (Genel Çalışma)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: timerProvider.selectedCourse != null
                            ? Color(timerProvider.selectedCourse!.colorValue)
                            : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                      ),
                    ),
                    if (timerProvider.selectedTopic != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• ${timerProvider.selectedTopic!.name}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    ],
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Dairesel Sayaç Göstergesi
            CircularPercentIndicator(
              radius: 125.0,
              lineWidth: 12.0,
              percent: isPomodoro ? pomodoroPercent : 1.0,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isPomodoro) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (timerProvider.pomodoroPhase == PomodoroPhase.study
                                ? const Color(0xFF4F46E5)
                                : const Color(0xFF10B981))
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        timerProvider.pomodoroPhase == PomodoroPhase.study
                            ? 'Ders Çalışma 📖'
                            : 'Mola Zamanı ☕',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: timerProvider.pomodoroPhase == PomodoroPhase.study
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    Formatters.formatSecondsToTime(totalSeconds),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timerProvider.isRunning
                        ? 'Odaklanma Sürüyor...'
                        : (timerProvider.isPaused ? 'Duraklatıldı' : 'Hazır'),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              progressColor: isPomodoro
                  ? (timerProvider.pomodoroPhase == PomodoroPhase.study
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF10B981))
                  : const Color(0xFF0EA5E9),
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              circularStrokeCap: CircularStrokeCap.round,
              animation: false,
            ),
            const SizedBox(height: 36),

            // Kontrol Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset / Sıfırla
                if (!timerProvider.isInitial)
                  IconButton.filledTonal(
                    onPressed: () => timerProvider.reset(),
                    icon: const Icon(Icons.refresh_rounded),
                    iconSize: 28,
                    padding: const EdgeInsets.all(14),
                  ),
                const SizedBox(width: 16),

                // Başlat / Duraklat Büyük Buton
                GestureDetector(
                  onTap: () {
                    if (timerProvider.isRunning) {
                      timerProvider.pause();
                    } else {
                      timerProvider.start();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: timerProvider.isRunning
                            ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                            : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (timerProvider.isRunning
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF4F46E5))
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          timerProvider.isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timerProvider.isRunning ? 'Duraklat' : 'Başlat',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Bitir & Kaydet Butonu
                if (timerProvider.secondsElapsed >= 10)
                  IconButton.filled(
                    onPressed: () async {
                      final duration = timerProvider.finishAndGetSessionSeconds();
                      await studyProvider.addStudySession(
                        courseId: timerProvider.selectedCourse?.id,
                        courseName: timerProvider.selectedCourse?.name ?? 'Genel Çalışma',
                        topicName: timerProvider.selectedTopic?.name,
                        durationSeconds: duration,
                        mode: isPomodoro ? 'pomodoro' : 'stopwatch',
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Harika! ${Formatters.formatMinutesToDuration((duration / 60).round())} çalışma süresi kaydedildi! 🎯',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_rounded),
                    iconSize: 28,
                    padding: const EdgeInsets.all(14),
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  ),
              ],
            ),
            const SizedBox(height: 36),

            // Bugünün Seansları Başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bugünkü Seanslar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${todaySessions.length} seans • ${Formatters.formatMinutesToDuration(studyProvider.todayStudyMinutes)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (todaySessions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Bugün henüz tamamlanan bir sayaç seansı yok.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ),
              )
            else
              ...todaySessions.map((session) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          session.mode == 'pomodoro'
                              ? Icons.alarm_rounded
                              : Icons.timer_outlined,
                          size: 18,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.courseName ?? 'Genel Çalışma',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            if (session.topicName != null && session.topicName!.isNotEmpty)
                              Text(
                                session.topicName!,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        Formatters.formatSecondsToTime(session.durationSeconds),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0EA5E9),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseTopicPicker(
    BuildContext context,
    TimerProvider timerProvider,
    StudyProvider studyProvider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ders Seçin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.all_inclusive_rounded),
                title: const Text('Genel Çalışma (Derssiz)'),
                onTap: () {
                  timerProvider.setSelectedCourse(null);
                  Navigator.pop(ctx);
                },
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: studyProvider.courses.length,
                  itemBuilder: (cContext, idx) {
                    final course = studyProvider.courses[idx];
                    return ListTile(
                      leading: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Color(course.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      onTap: () {
                        timerProvider.setSelectedCourse(course);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPomodoroSettings(BuildContext context, TimerProvider timerProvider) {
    int studyMins = timerProvider.pomodoroStudyMinutes;
    int restMins = timerProvider.pomodoroRestMinutes;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            title: const Text('Pomodoro Aralıkları'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Çalışma Süresi:'),
                    DropdownButton<int>(
                      value: studyMins,
                      items: const [
                        DropdownMenuItem(value: 15, child: Text('15 dk')),
                        DropdownMenuItem(value: 20, child: Text('20 dk')),
                        DropdownMenuItem(value: 25, child: Text('25 dk (Klasik)')),
                        DropdownMenuItem(value: 30, child: Text('30 dk')),
                        DropdownMenuItem(value: 45, child: Text('45 dk')),
                        DropdownMenuItem(value: 50, child: Text('50 dk')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => studyMins = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mola Süresi:'),
                    DropdownButton<int>(
                      value: restMins,
                      items: const [
                        DropdownMenuItem(value: 5, child: Text('5 dk (Klasik)')),
                        DropdownMenuItem(value: 10, child: Text('10 dk')),
                        DropdownMenuItem(value: 15, child: Text('15 dk')),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => restMins = v);
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  timerProvider.setPomodoroDurations(studyMinutes: studyMins, restMinutes: restMins);
                  Navigator.pop(ctx);
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }
}
