class TargetDepartmentModel {
  final String id;
  final String name;
  final String examType;
  final double baseScore;
  final double targetNet;
  final int recommendedHours;
  final String category;
  final String description;
  final Map<String, double>? targetCourseNets;

  const TargetDepartmentModel({
    required this.id,
    required this.name,
    required this.examType,
    required this.baseScore,
    required this.targetNet,
    this.recommendedHours = 4,
    this.category = 'Genel',
    this.description = '',
    this.targetCourseNets,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'examType': examType,
    'baseScore': baseScore,
    'targetNet': targetNet,
    'recommendedHours': recommendedHours,
    'category': category,
    'description': description,
    'targetCourseNets': targetCourseNets,
  };

  factory TargetDepartmentModel.fromJson(Map<String, dynamic> json) => TargetDepartmentModel(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    examType: json['examType'] as String? ?? 'YKS (Sayısal)',
    baseScore: (json['baseScore'] as num?)?.toDouble() ?? 400.0,
    targetNet: (json['targetNet'] as num?)?.toDouble() ?? 75.0,
    recommendedHours: json['recommendedHours'] as int? ?? 4,
    category: json['category'] as String? ?? 'Genel',
    description: json['description'] as String? ?? '',
    targetCourseNets: (json['targetCourseNets'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    ),
  );
}
