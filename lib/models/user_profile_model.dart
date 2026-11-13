import 'dart:convert';
import 'assignment_model.dart';
import 'coach_message_model.dart';
import 'student_study_stats_model.dart';

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
  final String membershipPlan; // Üyelik planı ('3 Ay Ücretsiz Deneme', 'Öğrenci PRO', 'Öğretmen PRO', 'Ücretsiz')
  final bool isEmailVerified; // E-posta adresi doğrulandı mı?
  final String? coachNote; // Koçun öğrenciye özel haftalık değerlendirmesi / tavsiyesi
  final DateTime? coachNoteUpdatedAt;

  // Yeni Rol, 3 Ay Ücretsiz Deneme & Öğretmen-Öğrenci Sistemi Alanları
  final String role; // 'student' veya 'teacher'
  final String? teacherCode; // Öğretmenlerin paylaşacağı koç kodu (örn: KOC-4829)
  final String? teacherId; // Öğrencinin bağlı olduğu öğretmenin ID'si
  final String? teacherName; // Öğrencinin bağlı olduğu öğretmenin adı
  final String? teacherEmail; // Öğrencinin bağlı olduğu öğretmenin e-postası
  final DateTime? trialEndsAt; // İlk 3 ay (90 gün) ücretsiz deneme bitiş tarihi
  final String? studyStatsJson; // Öğrencinin çalışma özeti JSON verisi
  final String? assignmentsJson; // Öğretmenin verdiği ödevler JSON listesi
  final String? messagesJson; // Öğretmen-Öğrenci mesajları JSON listesi

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
    this.membershipPlan = '3 Ay Ücretsiz Deneme',
    this.isEmailVerified = false,
    this.coachNote,
    this.coachNoteUpdatedAt,
    this.role = 'student',
    this.teacherCode,
    this.teacherId,
    this.teacherName,
    this.teacherEmail,
    this.trialEndsAt,
    this.studyStatsJson,
    this.assignmentsJson,
    this.messagesJson,
  });

  String get fullName => '$firstName $lastName'.trim();

  bool get isTeacher => role == 'teacher';
  bool get isStudent => role != 'teacher';

  /// İlk 3 ay (90 gün) ücretsiz deneme bitiş tarihi
  DateTime get effectiveTrialEndDate =>
      trialEndsAt ?? createdAt.add(const Duration(days: 90));

  /// Kullanıcı şu an 3 aylık ücretsiz deneme süresinde mi?
  bool get isInFreeTrial => DateTime.now().isBefore(effectiveTrialEndDate);

  /// Ücretsiz deneme süresinden kalan gün sayısı
  int get remainingTrialDays {
    final diffHours = effectiveTrialEndDate.difference(DateTime.now()).inHours;
    if (diffHours <= 0) return 0;
    return (diffHours / 24).ceil();
  }

  /// PRO özelliklere erişim var mı? (İlk 3 ay ücretsiz veya Premium üye)
  bool get hasProAccess => isPremium || isInFreeTrial;

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  StudentStudyStatsModel get studyStats {
    if (studyStatsJson == null || studyStatsJson!.isEmpty) {
      return const StudentStudyStatsModel();
    }
    try {
      final decoded = jsonDecode(studyStatsJson!);
      if (decoded is Map<String, dynamic>) {
        return StudentStudyStatsModel.fromJson(decoded);
      }
    } catch (_) {}
    return const StudentStudyStatsModel();
  }

  List<AssignmentModel> get assignments {
    if (assignmentsJson == null || assignmentsJson!.isEmpty) return [];
    try {
      final decoded = jsonDecode(assignmentsJson!);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => AssignmentModel.fromJson(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  int get pendingAssignmentsCount =>
      assignments.where((a) => !a.isCompleted).length;

  List<CoachMessageModel> get messages {
    if (messagesJson == null || messagesJson!.isEmpty) return [];
    try {
      final decoded = jsonDecode(messagesJson!);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => CoachMessageModel.fromJson(e))
            .toList();
      }
    } catch (_) {}
    return [];
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
      'role': role,
      'teacherCode': teacherCode,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'teacherEmail': teacherEmail,
      'trialEndsAt': effectiveTrialEndDate.toIso8601String(),
      'studyStatsJson': studyStatsJson,
      'assignmentsJson': assignmentsJson,
      'messagesJson': messagesJson,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] != null
        ? (DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now())
        : DateTime.now();

    return UserProfileModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      birthDate: json['birthDate'] != null
          ? (DateTime.tryParse(json['birthDate'] as String) ?? DateTime(2006, 1, 1))
          : DateTime(2006, 1, 1),
      targetExam: json['targetExam'] as String? ?? 'YKS (Sayısal)',
      dailyTargetHours: (json['dailyTargetHours'] as num?)?.toInt() ?? 3,
      targetDepartment: json['targetDepartment'] as String? ?? 'Genel Başarı Hedefi',
      targetScore: (json['targetScore'] as num?)?.toDouble() ?? 400.0,
      targetNet: (json['targetNet'] as num?)?.toDouble() ?? 75.0,
      createdAt: created,
      isPremium: json['isPremium'] as bool? ?? false,
      membershipPlan: json['membershipPlan'] as String? ?? '3 Ay Ücretsiz Deneme',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      coachNote: json['coachNote'] as String?,
      coachNoteUpdatedAt: json['coachNoteUpdatedAt'] != null
          ? DateTime.tryParse(json['coachNoteUpdatedAt'] as String)
          : null,
      role: json['role'] as String? ?? 'student',
      teacherCode: json['teacherCode'] as String?,
      teacherId: json['teacherId'] as String?,
      teacherName: json['teacherName'] as String?,
      teacherEmail: json['teacherEmail'] as String?,
      trialEndsAt: json['trialEndsAt'] != null
          ? DateTime.tryParse(json['trialEndsAt'] as String)
          : created.add(const Duration(days: 90)),
      studyStatsJson: json['studyStatsJson'] as String?,
      assignmentsJson: json['assignmentsJson'] as String?,
      messagesJson: json['messagesJson'] as String?,
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
    String? role,
    String? teacherCode,
    String? teacherId,
    String? teacherName,
    String? teacherEmail,
    bool clearTeacher = false,
    DateTime? trialEndsAt,
    String? studyStatsJson,
    String? assignmentsJson,
    String? messagesJson,
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
      role: role ?? this.role,
      teacherCode: teacherCode ?? this.teacherCode,
      teacherId: clearTeacher ? null : (teacherId ?? this.teacherId),
      teacherName: clearTeacher ? null : (teacherName ?? this.teacherName),
      teacherEmail: clearTeacher ? null : (teacherEmail ?? this.teacherEmail),
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      studyStatsJson: studyStatsJson ?? this.studyStatsJson,
      assignmentsJson: assignmentsJson ?? this.assignmentsJson,
      messagesJson: messagesJson ?? this.messagesJson,
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
    'AGS (Milli Eğitim Akademisi Giriş Sınavı)',
    'HMGS (Hukuk Mesleklerine Giriş Sınavı)',
    'İYÖS (İdari Yargı Ön Sınavı)',
    'KPSS (Genel Yetenek - Kültür)',
    'KPSS (Eğitim Bilimleri)',
    'KPSS (Alan Bilgisi)',
    'KPSS (Ön Lisans)',
    'KPSS (Ortaöğretim)',
    'DGS (Dikey Geçiş)',
    'ALES',
    'MSÜ (Milli Savunma Üniversitesi)',
    'YDS / YÖKDİL',
    'TUS',
    'DUS (Diş Hekimliğinde Uzmanlık)',
    'EKPSS',
    'Genel Sınav Hazırlığı',
  ];
}
