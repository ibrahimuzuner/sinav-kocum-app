class CourseModel {
  final String id;
  final String name;
  final int colorValue;
  final String iconName;
  final int targetDailyQuestions;

  const CourseModel({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconName = 'book',
    this.targetDailyQuestions = 30,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconName': iconName,
      'targetDailyQuestions': targetDailyQuestions,
    };
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int? ?? 0xFF4F46E5,
      iconName: json['iconName'] as String? ?? 'book',
      targetDailyQuestions: json['targetDailyQuestions'] as int? ?? 30,
    );
  }

  CourseModel copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? iconName,
    int? targetDailyQuestions,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      targetDailyQuestions: targetDailyQuestions ?? this.targetDailyQuestions,
    );
  }
}
