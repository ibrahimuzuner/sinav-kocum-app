/// Kurum / Organizasyon Modeli (Dershane, Koçluk Merkezi, Kurs)
class InstitutionModel {
  final String id;
  final String name; // Kurum Adı (örn: Kuzey Akademi Koçluk Merkezi)
  final String code; // Katılım Kodu (örn: KRM-841920)
  final String ownerCoachId; // Kurum Kurucusu / Yöneticisi Koç ID
  final String ownerCoachName;
  final String ownerCoachEmail;
  final String status; // 'pending' (onay bekliyor), 'approved' (aktif), 'rejected' (reddedildi), 'suspended' (askıda)
  final String? logoBase64; // Kurum Logosu (Base64 formatında veya URL)
  final String? city; // Şehir (örn: Ankara)
  final String? phone; // Kurum Telefonu
  final String? description; // Kurum Hakkında / Slogan
  final DateTime createdAt;
  final DateTime? approvedAt;
  final List<String> coachIds; // Kuruma bağlı koçların ID listesi
  final List<String> pendingCoachIds; // Kuruma katılmak için onay bekleyen koç ID listesi
  final List<String> studentIds; // Kuruma bağlı öğrencilerin ID listesi
  final String? adminNote; // Süper yöneticinin notu

  const InstitutionModel({
    required this.id,
    required this.name,
    required this.code,
    required this.ownerCoachId,
    required this.ownerCoachName,
    required this.ownerCoachEmail,
    this.status = 'pending',
    this.logoBase64,
    this.city,
    this.phone,
    this.description,
    required this.createdAt,
    this.approvedAt,
    this.coachIds = const [],
    this.pendingCoachIds = const [],
    this.studentIds = const [],
    this.adminNote,
  });

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isSuspended => status == 'suspended';
  bool get isRejected => status == 'rejected';

  int get coachCount => coachIds.length;
  int get pendingCoachCount => pendingCoachIds.length;
  int get studentCount => studentIds.length;

  bool isOwner(String coachId) => ownerCoachId == coachId;
  bool isMember(String coachId) => coachIds.contains(coachId);
  bool isPendingCoach(String coachId) => pendingCoachIds.contains(coachId);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'ownerCoachId': ownerCoachId,
      'ownerCoachName': ownerCoachName,
      'ownerCoachEmail': ownerCoachEmail,
      'status': status,
      'logoBase64': logoBase64,
      'city': city,
      'phone': phone,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'coachIds': coachIds,
      'pendingCoachIds': pendingCoachIds,
      'studentIds': studentIds,
      'adminNote': adminNote,
    };
  }

  factory InstitutionModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    final created = json['createdAt'] != null
        ? (DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now())
        : DateTime.now();

    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return InstitutionModel(
      id: docId ?? (json['id'] as String? ?? ''),
      name: json['name'] as String? ?? 'Kurum Adı',
      code: json['code'] as String? ?? '',
      ownerCoachId: json['ownerCoachId'] as String? ?? '',
      ownerCoachName: json['ownerCoachName'] as String? ?? '',
      ownerCoachEmail: json['ownerCoachEmail'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      logoBase64: json['logoBase64'] as String?,
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      createdAt: created,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'] as String)
          : null,
      coachIds: parseStringList(json['coachIds']),
      pendingCoachIds: parseStringList(json['pendingCoachIds']),
      studentIds: parseStringList(json['studentIds']),
      adminNote: json['adminNote'] as String?,
    );
  }

  InstitutionModel copyWith({
    String? id,
    String? name,
    String? code,
    String? ownerCoachId,
    String? ownerCoachName,
    String? ownerCoachEmail,
    String? status,
    String? logoBase64,
    bool clearLogo = false,
    String? city,
    String? phone,
    String? description,
    DateTime? createdAt,
    DateTime? approvedAt,
    List<String>? coachIds,
    List<String>? pendingCoachIds,
    List<String>? studentIds,
    String? adminNote,
  }) {
    return InstitutionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      ownerCoachId: ownerCoachId ?? this.ownerCoachId,
      ownerCoachName: ownerCoachName ?? this.ownerCoachName,
      ownerCoachEmail: ownerCoachEmail ?? this.ownerCoachEmail,
      status: status ?? this.status,
      logoBase64: clearLogo ? null : (logoBase64 ?? this.logoBase64),
      city: city ?? this.city,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      coachIds: coachIds ?? this.coachIds,
      pendingCoachIds: pendingCoachIds ?? this.pendingCoachIds,
      studentIds: studentIds ?? this.studentIds,
      adminNote: adminNote ?? this.adminNote,
    );
  }
}
