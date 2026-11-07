import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/study_provider.dart';
import '../../utils/formatters.dart';

class AddScheduleDialog extends StatefulWidget {
  final int initialDay;

  const AddScheduleDialog({super.key, required this.initialDay});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  late int _selectedDay;
  CourseModel? _selectedCourse;
  final TextEditingController _topicController = TextEditingController();
  int _targetMinutes = 60;
  int _targetQuestions = 30;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay;
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    if (studyProvider.courses.isNotEmpty) {
      _selectedCourse = studyProvider.courses.first;
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final availableCourses = studyProvider.courses;
    if (_selectedCourse != null && !availableCourses.any((c) => c.id == _selectedCourse!.id)) {
      _selectedCourse = availableCourses.isNotEmpty ? availableCourses.first : null;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Program Hedefi Ekle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Gün Seçimi
            const Text(
              'Gün',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedDay,
                  isExpanded: true,
                  items: List.generate(7, (index) {
                    final day = index + 1;
                    return DropdownMenuItem(
                      value: day,
                      child: Text(
                        Formatters.formatDayOfWeek(day),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDay = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Ders Seçimi
            const Text(
              'Ders',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CourseModel>(
                  value: _selectedCourse,
                  isExpanded: true,
                  items: studyProvider.courses.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: Color(c.colorValue), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCourse = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Konu / Görev Başlığı
            const Text(
              'Hedef Konu veya Görev',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'Örn: Fonksiyonlar 50 Soru & Video İzleme',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),

            // Hedef Süre & Hedef Soru
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hedef Süre (dk)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _targetMinutes,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 30, child: Text('30 dk')),
                              DropdownMenuItem(value: 45, child: Text('45 dk')),
                              DropdownMenuItem(value: 60, child: Text('60 dk (1 sa)')),
                              DropdownMenuItem(value: 90, child: Text('90 dk (1.5 sa)')),
                              DropdownMenuItem(value: 120, child: Text('120 dk (2 sa)')),
                              DropdownMenuItem(value: 180, child: Text('180 dk (3 sa)')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _targetMinutes = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hedef Soru',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _targetQuestions,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 20, child: Text('20 Soru')),
                              DropdownMenuItem(value: 30, child: Text('30 Soru')),
                              DropdownMenuItem(value: 40, child: Text('40 Soru')),
                              DropdownMenuItem(value: 50, child: Text('50 Soru')),
                              DropdownMenuItem(value: 75, child: Text('75 Soru')),
                              DropdownMenuItem(value: 100, child: Text('100 Soru')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _targetQuestions = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ekle Butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedCourse == null || _topicController.text.trim().isEmpty
                    ? null
                    : () async {
                        await studyProvider.addScheduleItem(
                          dayOfWeek: _selectedDay,
                          courseId: _selectedCourse!.id,
                          courseName: _selectedCourse!.name,
                          topicName: _topicController.text.trim(),
                          targetMinutes: _targetMinutes,
                          targetQuestions: _targetQuestions,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Programa Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
