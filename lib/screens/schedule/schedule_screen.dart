import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/schedule_item_model.dart';
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

    final rawDayItems = studyProvider.getScheduleForDay(_selectedDay);
    final isSunday = _selectedDay == 7;
    final sundayCatchUpTasks = isSunday ? studyProvider.getSundayCatchUpTasks() : <ScheduleItemModel>[];
    final isSundayRestDay = isSunday && rawDayItems.isEmpty;
    final isSundayCatchUpMode = isSundayRestDay && sundayCatchUpTasks.isNotEmpty;

    final items = isSundayCatchUpMode ? sundayCatchUpTasks : rawDayItems;
    final completedCount = items.where((i) => i.isCompleted).length;
    final progress = items.isNotEmpty ? (completedCount / items.length).clamp(0.0, 1.0) : 0.0;

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
                      isSundayCatchUpMode
                          ? 'Pazar (⚡ Telafi Günü)'
                          : Formatters.formatDayOfWeek(_selectedDay),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isSundayCatchUpMode
                          ? '$completedCount / ${items.length} Telafi Edildi'
                          : '$completedCount / ${items.length} Tamamlandı',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSundayCatchUpMode ? const Color(0xFFD97706) : const Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  lineHeight: 8.0,
                  percent: progress,
                  progressColor: isSundayCatchUpMode ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
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
                ? (isSundayRestDay
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F291E) : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.celebration_rounded, color: Color(0xFF10B981), size: 52),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Tebrikler! Dinlenme Günü 🎉',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Hafta içi tüm ders ve konu görevlerini başarıyla tamamladın! Bugün zihnini toparla, enerji depola ve yeni haftaya enerjik başla.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: () => _openAddDialog(context),
                                  icon: const Icon(Icons.add_rounded, color: Color(0xFF10B981)),
                                  label: const Text('İsteğe Bağlı Hedef Ekle', style: TextStyle(color: Color(0xFF10B981))),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF10B981)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Center(
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
                      ))
                : Column(
                    children: [
                      if (isSundayCatchUpMode)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.published_with_changes_rounded, color: Color(0xFFD97706), size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pazar Telafi Günü Devrede! ⚡',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFD97706)),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Hafta içi tamamlayamadığın hedefler buraya aktarıldı. Tamamlayarak haftayı eksiksiz bitirebilirsin!',
                                      style: TextStyle(fontSize: 11.5, color: Color(0xFFB45309)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
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
                              customTag: isSundayCatchUpMode
                                  ? '⚡ ${Formatters.formatDayOfWeekShort(item.dayOfWeek)} Telafisi'
                                  : null,
                              onToggle: () => studyProvider.toggleScheduleCompleted(item.id),
                              onDelete: () => studyProvider.deleteScheduleItem(item.id),
                            );
                          },
                        ),
                      ),
                    ],
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
