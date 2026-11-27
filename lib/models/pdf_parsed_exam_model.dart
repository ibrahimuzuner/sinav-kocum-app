import 'mock_exam_model.dart';
import 'user_profile_model.dart';

/// PDF'ten ayrıştırılan tek bir öğrencinin deneme sınavı sonucu
class ParsedStudentExam {
  final String rawStudentName;
  final String normalizedStudentName;
  String examTitle;
  String targetExam; // TYT, AYT, YKS, LGS, KPSS vb.
  final double score;
  final int totalQuestions;
  final int totalCorrect;
  final int totalWrong;
  final int totalEmpty;
  final double totalNet;
  final List<MockExamCourseScore> courseScores;
  final int? generalRank;
  final int? schoolRank;

  // Arayüzde öğrenci eşleme durumu
  UserProfileModel? matchedStudent;
  bool isSelected;

  ParsedStudentExam({
    required this.rawStudentName,
    required this.normalizedStudentName,
    required this.examTitle,
    this.targetExam = 'TYT',
    required this.score,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalEmpty,
    required this.totalNet,
    required this.courseScores,
    this.generalRank,
    this.schoolRank,
    this.matchedStudent,
    this.isSelected = true,
  });

  /// Bu ayrıştırılmış sonucu kaydedilebilir MockExamModel nesnesine dönüştürür
  MockExamModel toMockExamModel({required String id, DateTime? examDate}) {
    final rankNotes = <String>[];
    if (generalRank != null && generalRank! > 0) {
      rankNotes.add('Genel Sıra: $generalRank');
    }
    if (schoolRank != null && schoolRank! > 0) {
      rankNotes.add('Kurum Sırası: $schoolRank');
    }
    final noteSuffix = rankNotes.isNotEmpty ? ' (${rankNotes.join(', ')})' : '';

    return MockExamModel(
      id: id,
      title: examTitle,
      examType: 'Genel Deneme',
      targetExam: targetExam,
      date: examDate ?? DateTime.now(),
      notes: 'Optik PDF aktarımı ile otomatik kaydedildi$noteSuffix.',
      courseScores: courseScores,
      estimatedScore: score > 0 ? score : null,
      coachAdvice: 'PDF sonuç karnesi başarıyla işlendi. En çok odaklanılması gereken dersler ve konu netleri incelendi.',
    );
  }
}
