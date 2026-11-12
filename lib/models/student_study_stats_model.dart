class StudentStudyStatsModel {
  final int todayStudyMinutes;
  final int todaySolvedQuestions;
  final double todayNetScore;
  final int totalStudyMinutes;
  final int totalSolvedQuestions;
  final int streakDays;
  final int mockExamCount;
  final String? latestMockTitle;
  final double? latestMockNet;
  final double highestMockNet;
  final DateTime? lastStudiedAt;
  final List<String> recentActivities;

  const StudentStudyStatsModel({
    this.todayStudyMinutes = 0,
    this.todaySolvedQuestions = 0,
    this.todayNetScore = 0.0,
    this.totalStudyMinutes = 0,
    this.totalSolvedQuestions = 0,
    this.streakDays = 0,
    this.mockExamCount = 0,
    this.latestMockTitle,
    this.latestMockNet,
    this.highestMockNet = 0.0,
    this.lastStudiedAt,
    this.recentActivities = const [],
  });

  bool get studiedToday => todayStudyMinutes > 0 || todaySolvedQuestions > 0;

  Map<String, dynamic> toJson() {
    return {
      'todayStudyMinutes': todayStudyMinutes,
      'todaySolvedQuestions': todaySolvedQuestions,
      'todayNetScore': todayNetScore,
      'totalStudyMinutes': totalStudyMinutes,
      'totalSolvedQuestions': totalSolvedQuestions,
      'streakDays': streakDays,
      'mockExamCount': mockExamCount,
      'latestMockTitle': latestMockTitle,
      'latestMockNet': latestMockNet,
      'highestMockNet': highestMockNet,
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
      'recentActivities': recentActivities,
    };
  }

  factory StudentStudyStatsModel.fromJson(Map<String, dynamic> json) {
    final rawActivities = json['recentActivities'];
    final List<String> activities = [];
    if (rawActivities is List) {
      for (final item in rawActivities) {
        if (item != null) activities.add(item.toString());
      }
    }

    return StudentStudyStatsModel(
      todayStudyMinutes: (json['todayStudyMinutes'] as num?)?.toInt() ?? 0,
      todaySolvedQuestions: (json['todaySolvedQuestions'] as num?)?.toInt() ?? 0,
      todayNetScore: (json['todayNetScore'] as num?)?.toDouble() ?? 0.0,
      totalStudyMinutes: (json['totalStudyMinutes'] as num?)?.toInt() ?? 0,
      totalSolvedQuestions: (json['totalSolvedQuestions'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      mockExamCount: (json['mockExamCount'] as num?)?.toInt() ?? 0,
      latestMockTitle: json['latestMockTitle'] as String?,
      latestMockNet: (json['latestMockNet'] as num?)?.toDouble(),
      highestMockNet: (json['highestMockNet'] as num?)?.toDouble() ?? 0.0,
      lastStudiedAt: json['lastStudiedAt'] != null
          ? DateTime.tryParse(json['lastStudiedAt'] as String)
          : null,
      recentActivities: activities,
    );
  }
}
