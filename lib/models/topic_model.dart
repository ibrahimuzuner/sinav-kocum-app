class TopicModel {
  final String id;
  final String courseId;
  final String name;
  final bool isCompleted;

  const TopicModel({
    required this.id,
    required this.courseId,
    required this.name,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'name': name,
      'isCompleted': isCompleted,
    };
  }

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      name: json['name'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  TopicModel copyWith({
    String? id,
    String? courseId,
    String? name,
    bool? isCompleted,
  }) {
    return TopicModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
