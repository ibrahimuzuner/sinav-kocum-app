class UserProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime birthDate;
  final String targetExam;
  final int dailyTargetHours; // Günlük hedef saat (örn: 3)
  final String targetDepartment; // Hedeflenen bölüm / program (örn: Tıp Fakültesi, Hukuk, KPSS Atama)
  final double targetScore; // Hedef taban puan (örn: 505.0)
  final double targetNet; // Hedeflenen toplam net (örn: 105.0)
  final DateTime createdAt;
  final bool isPremium; // Ücretli / Premium üyelik durumu
  final String membershipPlan; // Üyelik planı ('Ücretsiz', 'Premium', 'Koçluk')
  final bool isEmailVerified; // E-posta adresi doğrulandı mı?
  final String? coachNote; // Koçun öğrenciye özel haftalık değerlendirmesi / tavsiyesi
  final DateTime? coachNoteUpdatedAt;

  const UserProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.targetExam,
    this.dailyTargetHours = 3,
    this.targetDepartment = 'Genel Başarı Hedefi',
    this.targetScore = 400.0,
    this.targetNet = 75.0,
    required this.createdAt,
    this.isPremium = false,
    this.membershipPlan = 'Ücretsiz',
    this.isEmailVerified = false,
    this.coachNote,
    this.coachNoteUpdatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'birthDate': birthDate.toIso8601String(),
      'targetExam': targetExam,
      'dailyTargetHours': dailyTargetHours,
      'targetDepartment': targetDepartment,
      'targetScore': targetScore,
      'targetNet': targetNet,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'membershipPlan': membershipPlan,
      'isEmailVerified': isEmailVerified,
      'coachNote': coachNote,
      'coachNoteUpdatedAt': coachNoteUpdatedAt?.toIso8601String(),
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : DateTime(2006, 1, 1),
      targetExam: json['targetExam'] as String? ?? 'YKS (Sayısal)',
      dailyTargetHours: json['dailyTargetHours'] as int? ?? 3,
      targetDepartment: json['targetDepartment'] as String? ?? 'Genel Başarı Hedefi',
      targetScore: (json['targetScore'] as num?)?.toDouble() ?? 400.0,
      targetNet: (json['targetNet'] as num?)?.toDouble() ?? 75.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isPremium: json['isPremium'] as bool? ?? false,
      membershipPlan: json['membershipPlan'] as String? ?? 'Ücretsiz',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      coachNote: json['coachNote'] as String?,
      coachNoteUpdatedAt: json['coachNoteUpdatedAt'] != null
          ? DateTime.tryParse(json['coachNoteUpdatedAt'] as String)
          : null,
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? birthDate,
    String? targetExam,
    int? dailyTargetHours,
    String? targetDepartment,
    double? targetScore,
    double? targetNet,
    DateTime? createdAt,
    bool? isPremium,
    String? membershipPlan,
    bool? isEmailVerified,
    String? coachNote,
    DateTime? coachNoteUpdatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      targetExam: targetExam ?? this.targetExam,
      dailyTargetHours: dailyTargetHours ?? this.dailyTargetHours,
      targetDepartment: targetDepartment ?? this.targetDepartment,
      targetScore: targetScore ?? this.targetScore,
      targetNet: targetNet ?? this.targetNet,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
      membershipPlan: membershipPlan ?? this.membershipPlan,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      coachNote: coachNote ?? this.coachNote,
      coachNoteUpdatedAt: coachNoteUpdatedAt ?? this.coachNoteUpdatedAt,
    );
  }
}

class ExamTypes {
  static const List<String> availableExams = [
    'YKS (Sayısal)',
    'YKS (Eşit Ağırlık)',
    'YKS (Sözel)',
    'YKS (Dil)',
    'LGS (Lise Giriş)',
    'KPSS (Genel Yetenek - Kültür)',
    'KPSS (Alan Bilgisi)',
    'DGS (Dikey Geçiş)',
    'ALES',
    'TUS',
    'Genel Sınav Hazırlığı',
  ];
}
