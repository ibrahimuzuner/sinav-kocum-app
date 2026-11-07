import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../models/topic_model.dart';
import '../../providers/study_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/formatters.dart';

class AddQuestionDialog extends StatefulWidget {
  final CourseModel? initialCourse;

  const AddQuestionDialog({super.key, this.initialCourse});

  @override
  State<AddQuestionDialog> createState() => _AddQuestionDialogState();
}

class _AddQuestionDialogState extends State<AddQuestionDialog> {
  CourseModel? _selectedCourse;
  TopicModel? _selectedTopic;
  String? _customTopicName;
  bool _showAllCourses = false;

  int _correct = 0;
  int _wrong = 0;
  int _empty = 0;
  int _durationMinutes = 0;
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.targetExam.isNotEmpty) {
      studyProvider.setCurrentExam(userProvider.targetExam);
    }

    final activeCourses = studyProvider.courses;
    if (widget.initialCourse != null && activeCourses.any((c) => c.id == widget.initialCourse!.id)) {
      _selectedCourse = widget.initialCourse;
    } else if (activeCourses.isNotEmpty) {
      _selectedCourse = activeCourses.first;
    } else if (studyProvider.allCourses.isNotEmpty) {
      _selectedCourse = studyProvider.allCourses.first;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _currentNet {
    final net = _correct - (_wrong / 4.0);
    return net < 0 ? 0.0 : double.parse(net.toStringAsFixed(2));
  }

  int get _totalQuestions => _correct + _wrong + _empty;

  @override
  Widget build(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayCourses = _showAllCourses ? studyProvider.allCourses : studyProvider.courses;
    if (_selectedCourse != null && !displayCourses.any((c) => c.id == _selectedCourse!.id)) {
      _selectedCourse = displayCourses.isNotEmpty ? displayCourses.first : null;
    }

    final availableTopics = _selectedCourse != null
        ? studyProvider.getTopicsForCourse(_selectedCourse!.id)
        : <TopicModel>[];

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Soru Çözümü Kaydet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🎯 ${userProvider.targetExam}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Ders Seçimi Başlığı & Filtre Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ders Seçin',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showAllCourses = !_showAllCourses;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          _showAllCourses ? Icons.filter_alt_off_rounded : Icons.filter_alt_rounded,
                          size: 14,
                          color: const Color(0xFF4F46E5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showAllCourses ? 'Sadece Sınav Dersleri' : 'Tüm Dersleri Göster',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CourseModel>(
                  value: _selectedCourse,
                  isExpanded: true,
                  hint: const Text('Ders Seçiniz'),
                  items: displayCourses.map((course) {
                    return DropdownMenuItem<CourseModel>(
                      value: course,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(course.colorValue),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            course.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCourse = val;
                      _selectedTopic = null;
                      _customTopicName = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Konu Seçimi
            const Text(
              'Konu (İsteğe Bağlı)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TopicModel?>(
                  value: _selectedTopic,
                  isExpanded: true,
                  hint: const Text('Genel / Konu Seçin'),
                  items: [
                    const DropdownMenuItem<TopicModel?>(
                      value: null,
                      child: Text('Genel Konular / Deneme'),
                    ),
                    ...availableTopics.map((topic) {
                      return DropdownMenuItem<TopicModel?>(
                        value: topic,
                        child: Text(topic.name),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedTopic = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Soru Sayıları Sayaçları (Doğru, Yanlış, Boş)
            Row(
              children: [
                Expanded(
                  child: _buildCounterField(
                    title: 'Doğru',
                    value: _correct,
                    color: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _correct = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCounterField(
                    title: 'Yanlış',
                    value: _wrong,
                    color: const Color(0xFFEF4444),
                    onChanged: (v) => setState(() => _wrong = v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCounterField(
                    title: 'Boş',
                    value: _empty,
                    color: const Color(0xFF94A3B8),
                    onChanged: (v) => setState(() => _empty = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Net Hesaplama Canlı Göstergesi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics_rounded, color: Color(0xFF4F46E5), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Toplam: $_totalQuestions Soru',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    'Net: $_currentNet',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Süre & Tarih
            Row(
              children: [
                Expanded(
                  child: _buildDurationField(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Formatters.formatDateTurkish(_selectedDate),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Kaydet Butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _totalQuestions == 0 || _selectedCourse == null
                    ? null
                    : () async {
                        await studyProvider.addQuestionLog(
                          courseId: _selectedCourse!.id,
                          courseName: _selectedCourse!.name,
                          topicId: _selectedTopic?.id,
                          topicName: _selectedTopic?.name ?? _customTopicName,
                          correct: _correct,
                          wrong: _wrong,
                          empty: _empty,
                          date: _selectedDate,
                          durationMinutes: _durationMinutes > 0 ? _durationMinutes : null,
                          notes: _notesController.text.trim().isNotEmpty
                              ? _notesController.text.trim()
                              : null,
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${_selectedCourse!.name} için $_totalQuestions soru kaydedildi! (Net: $_currentNet)',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Kaydet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterField({
    required String title,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallBtn(
                icon: Icons.remove,
                onTap: () {
                  if (value > 0) onChanged(value - 1);
                },
              ),
              const SizedBox(width: 8),
              _buildSmallBtn(
                icon: Icons.add,
                onTap: () => onChanged(value + 1),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Hızlı +5 / +10
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => onChanged(value + 5),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '+5',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => onChanged(value + 10),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '+10',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
      ),
    );
  }

  Widget _buildDurationField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _durationMinutes,
                isDense: true,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('Süre yok', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 15, child: Text('15 dk', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 30, child: Text('30 dk', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 45, child: Text('45 dk', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 60, child: Text('60 dk', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 90, child: Text('90 dk', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 120, child: Text('120 dk', style: TextStyle(fontSize: 12))),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _durationMinutes = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
