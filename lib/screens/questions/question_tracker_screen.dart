import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/study_provider.dart';
import 'add_question_dialog.dart';
import 'question_log_card.dart';

class QuestionTrackerScreen extends StatefulWidget {
  const QuestionTrackerScreen({super.key});

  @override
  State<QuestionTrackerScreen> createState() => _QuestionTrackerScreenState();
}

class _QuestionTrackerScreenState extends State<QuestionTrackerScreen> {
  String? _selectedCourseIdFilter;

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allLogs = studyProvider.questionLogs;
    final filteredLogs = _selectedCourseIdFilter == null
        ? allLogs
        : allLogs.where((l) => l.courseId == _selectedCourseIdFilter).toList();

    final filteredTotalQuestions = filteredLogs.fold(0, (sum, i) => sum + i.totalQuestions);
    final filteredTotalNet = filteredLogs.fold(0.0, (sum, i) => sum + i.netScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soru Çözüm Takibi'),
        actions: [
          IconButton(
            tooltip: 'Yeni Soru Girişi',
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF4F46E5), size: 28),
            onPressed: () => _openAddDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Ders Filtreleme Çipleri
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Tüm Dersler'),
                    selected: _selectedCourseIdFilter == null,
                    onSelected: (selected) {
                      setState(() => _selectedCourseIdFilter = null);
                    },
                    selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    checkmarkColor: const Color(0xFF4F46E5),
                    labelStyle: TextStyle(
                      fontWeight: _selectedCourseIdFilter == null ? FontWeight.bold : FontWeight.normal,
                      color: _selectedCourseIdFilter == null ? const Color(0xFF4F46E5) : null,
                    ),
                  ),
                ),
                ...studyProvider.courses.map((course) {
                  final isSelected = _selectedCourseIdFilter == course.id;
                  final color = Color(course.colorValue);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(course.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCourseIdFilter = selected ? course.id : null;
                        });
                      },
                      avatar: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      selectedColor: color.withValues(alpha: 0.2),
                      checkmarkColor: color,
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? color : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Özet İstatistik Çubuğu
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredLogs.length} Kayıt • $filteredTotalQuestions Soru',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  'Toplam Net: ${filteredTotalNet.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),

          // Kayıtlar Listesi
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Henüz soru çözümü kaydı yok',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Çözdüğün soruları kaydederek net gelişimini grafiklerle takip et!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _openAddDialog(context),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('İlk Soruyu Kaydet'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      final course = studyProvider.allCourses.firstWhere(
                        (c) => c.id == log.courseId,
                        orElse: () => CourseModel(
                          id: log.courseId,
                          name: log.courseName,
                          colorValue: 0xFF4F46E5,
                        ),
                      );

                      return QuestionLogCard(
                        log: log,
                        course: course,
                        onDelete: () => studyProvider.deleteQuestionLog(log.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Soru Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _openAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddQuestionDialog(),
    );
  }
}
