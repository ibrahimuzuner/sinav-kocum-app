class QuestionLogModel {
  final String id;
  final String courseId;
  final String courseName;
  final String? topicId;
  final String? topicName;
  final int correctCount;
  final int wrongCount;
  final int emptyCount;
  final DateTime date;
  final int? durationMinutes;
  final String? notes;

  const QuestionLogModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    this.topicId,
    this.topicName,
    required this.correctCount,
    required this.wrongCount,
    this.emptyCount = 0,
    required this.date,
    this.durationMinutes,
    this.notes,
  });

  int get totalQuestions => correctCount + wrongCount + emptyCount;

  /// Net = Doğru - (Yanlış / 4)
  double get netScore {
    final net = correctCount - (wrongCount / 4.0);
    return net < 0 ? 0.0 : double.parse(net.toStringAsFixed(2));
  }

  /// Doğruluk oranı (%)
  double get accuracyRate {
    if (totalQuestions == 0) return 0.0;
    return double.parse(((correctCount / totalQuestions) * 100).toStringAsFixed(1));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'topicId': topicId,
      'topicName': topicName,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'emptyCount': emptyCount,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'notes': notes,
    };
  }

  factory QuestionLogModel.fromJson(Map<String, dynamic> json) {
    return QuestionLogModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String? ?? 'Ders',
      topicId: json['topicId'] as String?,
      topicName: json['topicName'] as String?,
      correctCount: json['correctCount'] as int? ?? 0,
      wrongCount: json['wrongCount'] as int? ?? 0,
      emptyCount: json['emptyCount'] as int? ?? 0,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int?,
      notes: json['notes'] as String?,
    );
  }

  QuestionLogModel copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? topicId,
    String? topicName,
    int? correctCount,
    int? wrongCount,
    int? emptyCount,
    DateTime? date,
    int? durationMinutes,
    String? notes,
  }) {
    return QuestionLogModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      emptyCount: emptyCount ?? this.emptyCount,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
    );
  }
}
