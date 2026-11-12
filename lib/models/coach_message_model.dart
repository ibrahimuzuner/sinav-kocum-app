class CoachMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole; // 'teacher' or 'student'
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const CoachMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  bool get isFromTeacher => senderRole == 'teacher';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory CoachMessageModel.fromJson(Map<String, dynamic> json) {
    return CoachMessageModel(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      senderRole: json['senderRole'] as String? ?? 'teacher',
      message: json['message'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  CoachMessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return CoachMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
