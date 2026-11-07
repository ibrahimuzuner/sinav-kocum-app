class MockExamCourseScore {
  final String courseId;
  final String courseName;
  final int correctCount;
  final int wrongCount;
  final int emptyCount;
  final double netScore;

  const MockExamCourseScore({
    required this.courseId,
    required this.courseName,
    required this.correctCount,
    required this.wrongCount,
    this.emptyCount = 0,
    required this.netScore,
  });

  int get totalQuestions => correctCount + wrongCount + emptyCount;

  static double calculateNet(int correct, int wrong, {bool isLgs = false}) {
    final penalty = isLgs ? 3.0 : 4.0;
    final net = correct - (wrong / penalty);
    return double.parse(net.toStringAsFixed(2));
  }

  MockExamCourseScore copyWith({
    String? courseId,
    String? courseName,
    int? correctCount,
    int? wrongCount,
    int? emptyCount,
    double? netScore,
  }) {
    return MockExamCourseScore(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      emptyCount: emptyCount ?? this.emptyCount,
      netScore: netScore ?? this.netScore,
    );
  }

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'courseName': courseName,
    'correctCount': correctCount,
    'wrongCount': wrongCount,
    'emptyCount': emptyCount,
    'netScore': netScore,
  };

  factory MockExamCourseScore.fromJson(Map<String, dynamic> json) => MockExamCourseScore(
    courseId: json['courseId'] as String? ?? '',
    courseName: json['courseName'] as String? ?? '',
    correctCount: json['correctCount'] as int? ?? 0,
    wrongCount: json['wrongCount'] as int? ?? 0,
    emptyCount: json['emptyCount'] as int? ?? 0,
    netScore: (json['netScore'] as num?)?.toDouble() ?? 0.0,
  );
}

class MockExamModel {
  final String id;
  final String title;
  final String examType; // "Genel Deneme" veya "Branş Denemesi"
  final String targetExam;
  final DateTime date;
  final int? durationMinutes;
  final String? notes;
  final List<MockExamCourseScore> courseScores;

  const MockExamModel({
    required this.id,
    required this.title,
    this.examType = 'Genel Deneme',
    required this.targetExam,
    required this.date,
    this.durationMinutes,
    this.notes,
    required this.courseScores,
  });

  int get totalCorrect => courseScores.fold(0, (sum, c) => sum + c.correctCount);
  int get totalWrong => courseScores.fold(0, (sum, c) => sum + c.wrongCount);
  int get totalEmpty => courseScores.fold(0, (sum, c) => sum + c.emptyCount);
  int get totalQuestions => totalCorrect + totalWrong + totalEmpty;

  double get totalNet {
    final sum = courseScores.fold(0.0, (acc, c) => acc + c.netScore);
    return double.parse(sum.toStringAsFixed(2));
  }

  double get accuracyRate {
    if (totalQuestions == 0) return 0.0;
    return double.parse(((totalCorrect / totalQuestions) * 100).toStringAsFixed(1));
  }

  MockExamModel copyWith({
    String? id,
    String? title,
    String? examType,
    String? targetExam,
    DateTime? date,
    int? durationMinutes,
    String? notes,
    List<MockExamCourseScore>? courseScores,
  }) {
    return MockExamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      examType: examType ?? this.examType,
      targetExam: targetExam ?? this.targetExam,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      courseScores: courseScores ?? this.courseScores,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'examType': examType,
    'targetExam': targetExam,
    'date': date.toIso8601String(),
    'durationMinutes': durationMinutes,
    'notes': notes,
    'courseScores': courseScores.map((c) => c.toJson()).toList(),
  };

  factory MockExamModel.fromJson(Map<String, dynamic> json) => MockExamModel(
    id: json['id'] as String,
    title: json['title'] as String? ?? 'Deneme Sınavı',
    examType: json['examType'] as String? ?? 'Genel Deneme',
    targetExam: json['targetExam'] as String? ?? 'Genel',
    date: DateTime.parse(json['date'] as String),
    durationMinutes: json['durationMinutes'] as int?,
    notes: json['notes'] as String?,
    courseScores: (json['courseScores'] as List<dynamic>?)
            ?.map((c) => MockExamCourseScore.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
