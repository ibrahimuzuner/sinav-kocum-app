class AssignmentModel {
  final String id;
  final String teacherId;
  final String teacherName;
  final String studentId;
  final String courseName;
  final String title;
  final String description;
  final int targetQuestions;
  final int targetMinutes;
  final DateTime dueDate;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;

  const AssignmentModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.studentId,
    required this.courseName,
    required this.title,
    this.description = '',
    this.targetQuestions = 0,
    this.targetMinutes = 0,
    required this.dueDate,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
  });

  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return today.isAfter(dueDay);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'studentId': studentId,
      'courseName': courseName,
      'title': title,
      'description': description,
      'targetQuestions': targetQuestions,
      'targetMinutes': targetMinutes,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
      teacherName: json['teacherName'] as String? ?? 'Öğretmen',
      studentId: json['studentId'] as String? ?? '',
      courseName: json['courseName'] as String? ?? 'Genel',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetQuestions: (json['targetQuestions'] as num?)?.toInt() ?? 0,
      targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 0,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String) ?? DateTime.now().add(const Duration(days: 3))
          : DateTime.now().add(const Duration(days: 3)),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }

  AssignmentModel copyWith({
    String? id,
    String? teacherId,
    String? teacherName,
    String? studentId,
    String? courseName,
    String? title,
    String? description,
    int? targetQuestions,
    int? targetMinutes,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      studentId: studentId ?? this.studentId,
      courseName: courseName ?? this.courseName,
      title: title ?? this.title,
      description: description ?? this.description,
      targetQuestions: targetQuestions ?? this.targetQuestions,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
