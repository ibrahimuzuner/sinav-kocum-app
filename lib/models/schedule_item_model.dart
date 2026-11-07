class ScheduleItemModel {
  final String id;
  final int dayOfWeek; // 1 = Pazartesi, 2 = Salı ... 7 = Pazar
  final String courseId;
  final String courseName;
  final String topicName;
  final int targetMinutes;
  final int targetQuestions;
  final bool isCompleted;
  final DateTime? completedDate;
  final String activityType; // 'hybrid' (Video/Tekrar + Soru), 'practice' (Sadece Soru), 'lecture' (Konu Ağırlıklı)
  final int lectureMinutes; // Video ders / konu tekrar süresi (örn: 30 dk)
  final int practiceMinutes; // Soru çözme süresi (örn: 30 dk)

  const ScheduleItemModel({
    required this.id,
    required this.dayOfWeek,
    required this.courseId,
    required this.courseName,
    required this.topicName,
    this.targetMinutes = 60,
    this.targetQuestions = 30,
    this.isCompleted = false,
    this.completedDate,
    this.activityType = 'hybrid',
    this.lectureMinutes = 30,
    this.practiceMinutes = 30,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'courseId': courseId,
      'courseName': courseName,
      'topicName': topicName,
      'targetMinutes': targetMinutes,
      'targetQuestions': targetQuestions,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'activityType': activityType,
      'lectureMinutes': lectureMinutes,
      'practiceMinutes': practiceMinutes,
    };
  }

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return ScheduleItemModel(
      id: json['id'] as String,
      dayOfWeek: json['dayOfWeek'] as int? ?? 1,
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String? ?? 'Ders',
      topicName: json['topicName'] as String? ?? '',
      targetMinutes: json['targetMinutes'] as int? ?? 60,
      targetQuestions: json['targetQuestions'] as int? ?? 30,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.tryParse(json['completedDate'] as String)
          : null,
      activityType: json['activityType'] as String? ?? 'hybrid',
      lectureMinutes: json['lectureMinutes'] as int? ?? 30,
      practiceMinutes: json['practiceMinutes'] as int? ?? 30,
    );
  }

  ScheduleItemModel copyWith({
    String? id,
    int? dayOfWeek,
    String? courseId,
    String? courseName,
    String? topicName,
    int? targetMinutes,
    int? targetQuestions,
    bool? isCompleted,
    DateTime? completedDate,
    String? activityType,
    int? lectureMinutes,
    int? practiceMinutes,
  }) {
    return ScheduleItemModel(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      topicName: topicName ?? this.topicName,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      targetQuestions: targetQuestions ?? this.targetQuestions,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      activityType: activityType ?? this.activityType,
      lectureMinutes: lectureMinutes ?? this.lectureMinutes,
      practiceMinutes: practiceMinutes ?? this.practiceMinutes,
    );
  }
}
