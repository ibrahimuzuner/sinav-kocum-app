import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/study_provider.dart';
import '../../utils/formatters.dart';
import 'add_schedule_dialog.dart';
import 'schedule_card.dart';
import 'smart_schedule_dialog.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    // Default to today's weekday (1 = Pazartesi ... 7 = Pazar)
    _selectedDay = DateTime.now().weekday;
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = studyProvider.getScheduleForDay(_selectedDay);
    final completedCount = items.where((i) => i.isCompleted).length;
    final progress = items.isNotEmpty ? completedCount / items.length : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Programı'),
        actions: [
          IconButton(
            tooltip: 'Akıllı Program Oluştur (Yapay Zeka)',
            icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6), size: 26),
            onPressed: () => _openSmartDialog(context),
          ),
          IconButton(
            tooltip: 'Yeni Hedef Ekle',
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF4F46E5), size: 28),
            onPressed: () => _openAddDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Gün Seçici Çubuk
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = index + 1;
                final isSelected = day == _selectedDay;
                final isToday = day == DateTime.now().weekday;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedDay = day),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4F46E5)
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(16),
                        border: isToday && !isSelected
                            ? Border.all(color: const Color(0xFF4F46E5), width: 1.5)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Formatters.formatDayOfWeekShort(day),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : const Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Gün İlerleme Çubuğu
          Container(
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Formatters.formatDayOfWeek(_selectedDay),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$completedCount / ${items.length} Tamamlandı',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: progress,
                  progressColor: const Color(0xFF10B981),
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  barRadius: const Radius.circular(8),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Program Maddeleri Listesi
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_note_rounded,
                            size: 64,
                            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${Formatters.formatDayOfWeek(_selectedDay)} günü için plan yok',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Bu gün için ders ve konu hedefleri ekleyerek çalışma disiplinini artır!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _openSmartDialog(context),
                                icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6)),
                                label: const Text('Akıllı Sihirbaz', style: TextStyle(color: Color(0xFF8B5CF6))),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _openAddDialog(context),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Manuel Hedef Ekle'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
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
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Hedef Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _openAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddScheduleDialog(initialDay: _selectedDay),
    );
  }

  void _openSmartDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const SmartScheduleDialog(),
    );
  }
}
