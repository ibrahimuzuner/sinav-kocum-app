import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/mock_exam_model.dart';
import '../../providers/study_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/predefined_data.dart';

class AddMockExamDialog extends StatefulWidget {
  final MockExamModel? initialExam;

  const AddMockExamDialog({super.key, this.initialExam});

  @override
  State<AddMockExamDialog> createState() => _AddMockExamDialogState();
}

class _CourseInputData {
  final String courseId;
  final String courseName;
  final int colorValue;
  final int maxQuestions;
  final TextEditingController correctCtrl;
  final TextEditingController wrongCtrl;
  final TextEditingController emptyCtrl;

  _CourseInputData({
    required this.courseId,
    required this.courseName,
    required this.colorValue,
    required this.maxQuestions,
    required this.correctCtrl,
    required this.wrongCtrl,
    required this.emptyCtrl,
  });

  int get correct => int.tryParse(correctCtrl.text) ?? 0;
  int get wrong => int.tryParse(wrongCtrl.text) ?? 0;
  int get empty => int.tryParse(emptyCtrl.text) ?? 0;
  int get totalEntered => correct + wrong + empty;
  bool get isOverLimit => maxQuestions > 0 && totalEntered > maxQuestions;

  double calculateNet(bool isLgs) {
    return MockExamCourseScore.calculateNet(correct, wrong, isLgs: isLgs);
  }
}

class _AddMockExamDialogState extends State<AddMockExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  String _examType = 'Genel Deneme';
  final List<_CourseInputData> _courseInputs = [];
  bool _isLgs = false;

  final List<String> _publisherSuggestions = [
    'Pegem',
    '3D',
    'Özdebir',
    'Yargı',
    'Limit',
    'Yediiklim',
    'Apotemi',
    'Karekök',
    'Benim Hocam',
  ];

  @override
  void initState() {
    super.initState();
    final studyProvider = context.read<StudyProvider>();
    final userProvider = context.read<UserProvider>();
    final targetExam = userProvider.targetExam;
    _isLgs = targetExam.toLowerCase().contains('lgs');

    if (widget.initialExam != null) {
      final exam = widget.initialExam!;
      _titleController.text = exam.title;
      _examType = exam.examType;
      _selectedDate = exam.date;
      if (exam.durationMinutes != null) {
        _durationController.text = exam.durationMinutes.toString();
      }
      if (exam.notes != null) {
        _notesController.text = exam.notes!;
      }

      // Populate courses from initial exam
      for (final score in exam.courseScores) {
        final courseMatch = studyProvider.allCourses.firstWhere(
          (c) => c.id == score.courseId,
          orElse: () => studyProvider.courses.first,
        );
        final maxQ = PredefinedData.getMaxQuestionsForCourse(targetExam, score.courseId);
        final input = _CourseInputData(
          courseId: score.courseId,
          courseName: score.courseName,
          colorValue: courseMatch.colorValue,
          maxQuestions: maxQ,
          correctCtrl: TextEditingController(text: score.correctCount > 0 ? score.correctCount.toString() : ''),
          wrongCtrl: TextEditingController(text: score.wrongCount > 0 ? score.wrongCount.toString() : ''),
          emptyCtrl: TextEditingController(text: score.emptyCount > 0 ? score.emptyCount.toString() : ''),
        );
        input.correctCtrl.addListener(_onFieldChanged);
        input.wrongCtrl.addListener(_onFieldChanged);
        input.emptyCtrl.addListener(_onFieldChanged);
        _courseInputs.add(input);
      }
    } else {
      _selectedDate = DateTime.now();
      _durationController.text = _getDefaultDuration(targetExam);

      // Populate courses from active exam's courses
      for (final course in studyProvider.courses) {
        final maxQ = PredefinedData.getMaxQuestionsForCourse(targetExam, course.id);
        final input = _CourseInputData(
          courseId: course.id,
          courseName: course.name,
          colorValue: course.colorValue,
          maxQuestions: maxQ,
          correctCtrl: TextEditingController(),
          wrongCtrl: TextEditingController(),
          emptyCtrl: TextEditingController(),
        );
        input.correctCtrl.addListener(_onFieldChanged);
        input.wrongCtrl.addListener(_onFieldChanged);
        input.emptyCtrl.addListener(_onFieldChanged);
        _courseInputs.add(input);
      }
    }
  }

  String _getDefaultDuration(String targetExam) {
    final lower = targetExam.toLowerCase();
    if (lower.contains('kpss')) {
      if (lower.contains('eğitim') || lower.contains('egitim')) return '100';
      if (lower.contains('öabt') || lower.contains('oabt')) return '150';
      return '130';
    }
    if (lower.contains('tyt') || lower.contains('msü')) return '165';
    if (lower.contains('ayt')) return '180';
    if (lower.contains('ales')) return '150';
    if (lower.contains('dgs')) return '135';
    if (lower.contains('lgs')) return '155';
    if (lower.contains('ags')) return '110';
    if (lower.contains('hmgs')) return '150';
    if (lower.contains('ekpss')) return '60';
    if (lower.contains('ehliyet')) return '45';
    if (lower.contains('yds') || lower.contains('yökdil')) return '180';
    if (lower.contains('ydt')) return '120';
    if (lower.contains('tus')) return '300';
    if (lower.contains('dus')) return '150';
    return '120';
  }

  void _onFieldChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    for (final c in _courseInputs) {
      c.correctCtrl.dispose();
      c.wrongCtrl.dispose();
      c.emptyCtrl.dispose();
    }
    super.dispose();
  }

  double get _totalLiveNet {
    double sum = 0.0;
    for (final c in _courseInputs) {
      sum += c.calculateNet(_isLgs);
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  double get _totalLiveEstimatedScore {
    final userProvider = context.read<UserProvider>();
    final courseScores = _courseInputs.map((c) {
      return MockExamCourseScore(
        courseId: c.courseId,
        courseName: c.courseName,
        correctCount: c.correct,
        wrongCount: c.wrong,
        emptyCount: c.empty,
        netScore: c.calculateNet(_isLgs),
      );
    }).toList();
    return MockExamModel.calculateEstimatedScore(userProvider.targetExam, courseScores);
  }

  String get _liveCoachAdvice {
    final userProvider = context.read<UserProvider>();
    final courseScores = _courseInputs.map((c) {
      return MockExamCourseScore(
        courseId: c.courseId,
        courseName: c.courseName,
        correctCount: c.correct,
        wrongCount: c.wrong,
        emptyCount: c.empty,
        netScore: c.calculateNet(_isLgs),
      );
    }).toList();
    return MockExamModel.generateCoachAdvice(
      targetExam: userProvider.targetExam,
      scores: courseScores,
      targetScore: userProvider.targetScore,
      targetNet: userProvider.targetNet,
    );
  }

  int get _totalLiveCorrect => _courseInputs.fold(0, (sum, c) => sum + c.correct);
  int get _totalLiveWrong => _courseInputs.fold(0, (sum, c) => sum + c.wrong);
  int get _totalLiveEmpty => _courseInputs.fold(0, (sum, c) => sum + c.empty);
  int get _totalLiveQuestions => _totalLiveCorrect + _totalLiveWrong + _totalLiveEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveMockExam() {
    if (!_formKey.currentState!.validate()) return;

    if (_totalLiveQuestions == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir derse ait doğru / yanlış sayısını girin.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final studyProvider = context.read<StudyProvider>();

    final totalExamLimit = PredefinedData.getTotalQuestionsForExam(userProvider.targetExam);
    if (_totalLiveQuestions > totalExamLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Toplam soru sayısı ($_totalLiveQuestions), ${userProvider.targetExam} sınavının resmi soru sınırını ($totalExamLimit) aşamaz!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    for (final c in _courseInputs) {
      if (c.isOverLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${c.courseName} için girilen toplam soru (${c.totalEntered}), sınavdaki resmi soru sınırını (${c.maxQuestions}) aşıyor! Lütfen düzeltin.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    final courseScores = _courseInputs.map((c) {
      return MockExamCourseScore(
        courseId: c.courseId,
        courseName: c.courseName,
        correctCount: c.correct,
        wrongCount: c.wrong,
        emptyCount: c.empty,
        netScore: c.calculateNet(_isLgs),
      );
    }).toList();

    final duration = int.tryParse(_durationController.text);
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    final estScore = MockExamModel.calculateEstimatedScore(userProvider.targetExam, courseScores);
    final advice = MockExamModel.generateCoachAdvice(
      targetExam: userProvider.targetExam,
      scores: courseScores,
      targetScore: userProvider.targetScore,
      targetNet: userProvider.targetNet,
    );

    if (widget.initialExam != null) {
      final updated = widget.initialExam!.copyWith(
        title: _titleController.text.trim(),
        examType: _examType,
        targetExam: userProvider.targetExam,
        date: _selectedDate,
        durationMinutes: duration,
        notes: notes,
        courseScores: courseScores,
        estimatedScore: estScore,
        coachAdvice: advice,
      );
      studyProvider.updateMockExam(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deneme başarıyla güncellendi! 🎯'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final newExam = MockExamModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        examType: _examType,
        targetExam: userProvider.targetExam,
        date: _selectedDate,
        durationMinutes: duration,
        notes: notes,
        courseScores: courseScores,
        estimatedScore: estScore,
        coachAdvice: advice,
      );
      studyProvider.addMockExam(newExam);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deneme kaydedildi! Toplam Net: ${_totalLiveNet.toStringAsFixed(2)} (~$estScore Puan) 🚀'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, keyboardHeight + 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Modal tutamacı
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
            const SizedBox(height: 12),

            // Modal Başlığı
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF4F46E5), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.initialExam != null ? 'Deneme Sınavını Düzenle' : 'Yeni Deneme Sınavı Ekle',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _isLgs ? 'Formül: 3 Yanlış 1 Doğruyu Götürür' : 'Formül: 4 Yanlış 1 Doğruyu Götürür',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
            const SizedBox(height: 12),

            // CANLI NET BANNER'I
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Canlı Toplam Net',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${_totalLiveNet.toStringAsFixed(2)} Net',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_totalLiveEstimatedScore > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6)),
                                ),
                                child: Text(
                                  '~$_totalLiveEstimatedScore Puan',
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_totalLiveCorrect D  |  $_totalLiveWrong Y  |  $_totalLiveEmpty B',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // İÇERİK SCROLL ALANI
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. YAYIN / DENEME ADI
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Deneme / Yayın Adı *',
                        hintText: 'Örn: Pegem TG-1, 3D Simülasyon, Özdebir',
                        prefixIcon: const Icon(Icons.menu_book_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Lütfen bir yayın / deneme adı girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Hızlı Yayın Etiketleri
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _publisherSuggestions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (ctx, i) {
                          final p = _publisherSuggestions[i];
                          return ActionChip(
                            label: Text(p, style: const TextStyle(fontSize: 11)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            onPressed: () {
                              if (_titleController.text.trim().isEmpty) {
                                _titleController.text = '$p TG-1';
                              } else {
                                _titleController.text = '$p ${_titleController.text}';
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 2. DENEME TÜRÜ, TARİH, SÜRE
                    Row(
                      children: [
                        // Genel Deneme / Branş Denemesi
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _examType,
                            decoration: InputDecoration(
                              labelText: 'Tür',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Genel Deneme', child: Text('Genel Deneme')),
                              DropdownMenuItem(value: 'Branş Denemesi', child: Text('Branş')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _examType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Tarih Seçici
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(14),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Tarih',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              child: Text(
                                DateFormat('dd.MM.yyyy').format(_selectedDate),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Süre (dk)
                        SizedBox(
                          width: 85,
                          child: TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Süre (dk)',
                              hintText: '130',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 3. DERS BAZLI GİRİŞ BÖLÜMÜ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ders Bazlı Sonuçlar (Doğru / Yanlış / Boş)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sınav Sınırı: ${PredefinedData.getTotalQuestionsForExam(context.read<UserProvider>().targetExam)} Soru',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ..._courseInputs.map((c) {
                      final net = c.calculateNet(_isLgs);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: c.isOverLimit
                                ? const Color(0xFFEF4444)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            width: c.isOverLimit ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Color(c.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.courseName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (c.maxQuestions > 0)
                                    Text(
                                      c.isOverLimit
                                          ? '⚠️ ${c.totalEntered}/${c.maxQuestions} Soru (Sınır Aşıldı!)'
                                          : 'Maks: ${c.maxQuestions} Soru (${c.totalEntered}/${c.maxQuestions})',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: c.isOverLimit
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF94A3B8),
                                        fontWeight: c.isOverLimit ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),

                            // D
                            _buildCountField(c.correctCtrl, 'D', Colors.green),
                            const SizedBox(width: 6),

                            // Y
                            _buildCountField(c.wrongCtrl, 'Y', Colors.redAccent),
                            const SizedBox(width: 6),

                            // B
                            _buildCountField(c.emptyCtrl, 'B', Colors.grey),
                            const SizedBox(width: 8),

                            // Net rozeti
                            Container(
                              width: 58,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: (net > 0 ? const Color(0xFF10B981) : Colors.grey)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${net.toStringAsFixed(1)}N',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: net > 0 ? const Color(0xFF10B981) : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),

                    // CANLI KOÇ TAVSİYESİ & ÖNERİ KUTUSU
                    if (_totalLiveQuestions > 0 && _liveCoachAdvice.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.psychology_rounded, color: Color(0xFF4F46E5), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Koçun Canlı Analizi & Ağırlık Tavsiyesi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4F46E5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _liveCoachAdvice,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.35,
                                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // 4. NOTLAR ALANI
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Deneme Notları / Değerlendirme',
                        hintText: 'Örn: Matematikte süre yetmedi, paragraf ful geldi.',
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // KAYDET BUTONU
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveMockExam,
                icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                label: Text(
                  widget.initialExam != null ? 'Değişiklikleri Kaydet' : 'Denemeyi Kaydet',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
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

  Widget _buildCountField(TextEditingController ctrl, String hint, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 42,
      height: 38,
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.6)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: color, width: 1.5),
          ),
        ),
      ),
    );
  }
}
