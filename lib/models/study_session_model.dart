class StudySessionModel {
  final String id;
  final String? courseId;
  final String? courseName;
  final String? topicName;
  final int durationSeconds;
  final DateTime date;
  final String mode; // 'stopwatch' or 'pomodoro'
  final String? notes;

  const StudySessionModel({
    required this.id,
    this.courseId,
    this.courseName,
    this.topicName,
    required this.durationSeconds,
    required this.date,
    this.mode = 'stopwatch',
    this.notes,
  });

  int get durationMinutes => (durationSeconds / 60).round();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'topicName': topicName,
      'durationSeconds': durationSeconds,
      'date': date.toIso8601String(),
      'mode': mode,
      'notes': notes,
    };
  }

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String?,
      courseName: json['courseName'] as String?,
      topicName: json['topicName'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      date: DateTime.parse(json['date'] as String),
      mode: json['mode'] as String? ?? 'stopwatch',
      notes: json['notes'] as String?,
    );
  }
}
