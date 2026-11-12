import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/assignment_model.dart';
import '../models/coach_message_model.dart';
import '../models/user_profile_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';

class UserProvider with ChangeNotifier {
  final StorageService _storage;
  final AppFirebaseService _firebaseService = AppFirebaseService();
  UserProfileModel? _userProfile;

  UserProvider(this._storage) {
    _loadProfile();
  }

  UserProfileModel? get userProfile => _userProfile;
  bool get isRegistered => _userProfile != null;

  String get displayName => _userProfile?.firstName ?? (isTeacher ? 'Öğretmen' : 'Öğrenci');
  String get fullName => _userProfile?.fullName ?? displayName;
  String get email => _userProfile?.email ?? '';
  String get targetExam => _userProfile?.targetExam ?? 'YKS';
  int get dailyTargetHours => _userProfile?.dailyTargetHours ?? 3;
  String get targetDepartment => _userProfile?.targetDepartment ?? 'Genel Başarı Hedefi';
  double get targetScore => _userProfile?.targetScore ?? 400.0;
  double get targetNet => _userProfile?.targetNet ?? 75.0;
  bool get isPremium => _userProfile?.isPremium ?? false;
  String get membershipPlan => _userProfile?.membershipPlan ?? '3 Ay Ücretsiz Deneme';
  bool get isEmailVerified => _userProfile?.isEmailVerified ?? false;
  String? get coachNote => _userProfile?.coachNote;
  DateTime? get coachNoteUpdatedAt => _userProfile?.coachNoteUpdatedAt;

  // Rol & Öğretmen-Öğrenci Sistemi
  String get role => _userProfile?.role ?? 'student';
  bool get isTeacher => _userProfile?.isTeacher ?? false;
  bool get isStudent => _userProfile?.isStudent ?? true;
  String? get teacherCode => _userProfile?.teacherCode;
  String? get teacherId {
    final t = _userProfile?.teacherId;
    return (t != null && t.isNotEmpty) ? t : null;
  }
  String? get teacherName {
    final n = _userProfile?.teacherName;
    return (n != null && n.isNotEmpty) ? n : null;
  }
  String? get teacherEmail {
    final e = _userProfile?.teacherEmail;
    return (e != null && e.isNotEmpty) ? e : null;
  }

  // İlk 3 Ay Ücretsiz Deneme & PRO Erişim
  DateTime get trialEndDate =>
      _userProfile?.effectiveTrialEndDate ?? DateTime.now().add(const Duration(days: 90));
  bool get isInFreeTrial => _userProfile?.isInFreeTrial ?? true;
  int get remainingTrialDays => _userProfile?.remainingTrialDays ?? 90;
  bool get hasProAccess => isAdmin || isPremium || isInFreeTrial;

  // Öğrenci Ödev & Mesaj Getters
  List<AssignmentModel> get studentAssignments => _userProfile?.assignments ?? [];
  int get pendingAssignmentsCount => _userProfile?.pendingAssignmentsCount ?? 0;
  List<CoachMessageModel> get studentMessages => _userProfile?.messages ?? [];
  int get unreadTeacherMessagesCount =>
      studentMessages.where((m) => m.senderRole == 'teacher' && !m.isRead).length;

  static const List<String> _adminEmails = [
    'ibrahimuzumer@hotmail.com',
    'ibrahimuzuner@hotmail.com',
    'ibrahim.uzuner@icloud.com',
    'ibrahimuzuner@icloud.com',
    'fearmynova@hotmail.com',
  ];

  bool get isAdmin {
    final currentEmail = _userProfile?.email.toLowerCase().trim() ?? '';
    return _adminEmails.contains(currentEmail);
  }

  void _loadProfile() {
    _userProfile = _storage.loadUserProfile();
    notifyListeners();

    // Arka planda Firebase'den güncel verileri (üyelik, ödevler, mesajlar vb.) kontrol et
    if (_userProfile != null) {
      syncCloudUserData();
    }
  }

  Future<void> syncCloudUserData() async {
    try {
      if (_userProfile == null) return;
      final cloudData = await _firebaseService.fetchCloudUserData(_userProfile!.id);
      if (cloudData != null && _userProfile != null) {
        final cloudPremium = cloudData['isPremium'] as bool? ?? _userProfile!.isPremium;
        final cloudPlan = cloudData['membershipPlan'] as String? ?? _userProfile!.membershipPlan;
        final cloudCoachNote = cloudData['coachNote'] as String?;
        final cloudNoteUpdatedStr = cloudData['coachNoteUpdatedAt'] as String?;
        final cloudNoteDate = cloudNoteUpdatedStr != null && cloudNoteUpdatedStr.isNotEmpty
            ? DateTime.tryParse(cloudNoteUpdatedStr)
            : _userProfile!.coachNoteUpdatedAt;

        final cloudRole = cloudData['role'] as String?;
        final cloudTeacherCode = cloudData['teacherCode'] as String?;
        final cloudTeacherId = cloudData['teacherId'] as String?;
        final cloudTeacherName = cloudData['teacherName'] as String?;
        final cloudTeacherEmail = cloudData['teacherEmail'] as String?;
        final cloudTrialStr = cloudData['trialEndsAt'] as String?;
        final cloudTrialDate = cloudTrialStr != null && cloudTrialStr.isNotEmpty
            ? DateTime.tryParse(cloudTrialStr)
            : null;
        final cloudAssignments = cloudData['assignmentsJson'] as String?;
        final cloudMessages = cloudData['messagesJson'] as String?;
        final cloudStudyStats = cloudData['studyStatsJson'] as String?;

        _userProfile = _userProfile!.copyWith(
          isPremium: cloudPremium,
          membershipPlan: cloudPlan,
          coachNote: (cloudCoachNote != null && cloudCoachNote.isNotEmpty)
              ? cloudCoachNote
              : _userProfile!.coachNote,
          coachNoteUpdatedAt: cloudNoteDate,
          role: (cloudRole != null && cloudRole.isNotEmpty) ? cloudRole : _userProfile!.role,
          teacherCode: (cloudTeacherCode != null && cloudTeacherCode.isNotEmpty)
              ? cloudTeacherCode
              : _userProfile!.teacherCode,
          teacherId: cloudTeacherId ?? _userProfile!.teacherId,
          teacherName: cloudTeacherName ?? _userProfile!.teacherName,
          teacherEmail: cloudTeacherEmail ?? _userProfile!.teacherEmail,
          trialEndsAt: cloudTrialDate ?? _userProfile!.trialEndsAt,
          assignmentsJson: cloudAssignments ?? _userProfile!.assignmentsJson,
          messagesJson: cloudMessages ?? _userProfile!.messagesJson,
          studyStatsJson: cloudStudyStats ?? _userProfile!.studyStatsJson,
        );
        await _storage.saveUserProfile(_userProfile!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Cloud syncUserData hatası: $e');
    }
  }

  String _generateTeacherCode() {
    final rng = Random();
    final numPart = 1000 + rng.nextInt(9000);
    return 'KOC-$numPart';
  }

  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required DateTime birthDate,
    required String targetExam,
    required int dailyTargetHours,
    String? targetDepartment,
    double? targetScore,
    double? targetNet,
    String? password,
    String role = 'student',
    String? teacherCodeInput,
  }) async {
    final now = DateTime.now();
    final cleanEmail = email.trim();
    final generatedCode = role == 'teacher' ? _generateTeacherCode() : null;

    String? linkedTeacherId;
    String? linkedTeacherName;
    String? linkedTeacherEmail;

    // Öğrenci olarak kayıt olunuyorsa koç kodu veya bekleyen öğretmen daveti kontrol et
    if (role != 'teacher') {
      if (teacherCodeInput != null && teacherCodeInput.trim().isNotEmpty) {
        final teacher = await _firebaseService.findTeacherByCode(teacherCodeInput.trim());
        if (teacher != null) {
          linkedTeacherId = teacher.id;
          linkedTeacherName = teacher.fullName;
          linkedTeacherEmail = teacher.email;
        }
      }
      if (linkedTeacherId == null) {
        final invite = await _firebaseService.checkPendingTeacherInvite(cleanEmail);
        if (invite != null) {
          linkedTeacherId = invite['teacherId'];
          linkedTeacherName = invite['teacherName'];
          linkedTeacherEmail = invite['teacherEmail'];
        }
      }
    }

    final newProfile = UserProfileModel(
      id: const Uuid().v4(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: cleanEmail,
      birthDate: birthDate,
      targetExam: targetExam,
      dailyTargetHours: dailyTargetHours,
      targetDepartment: targetDepartment ?? (role == 'teacher' ? 'Öğretmen / Eğitim Koçu' : 'Genel Başarı Hedefi'),
      targetScore: targetScore ?? 400.0,
      targetNet: targetNet ?? 75.0,
      createdAt: now,
      trialEndsAt: now.add(const Duration(days: 90)),
      isPremium: false,
      membershipPlan: '3 Ay Ücretsiz Deneme',
      isEmailVerified: false,
      role: role,
      teacherCode: generatedCode,
      teacherId: linkedTeacherId,
      teacherName: linkedTeacherName,
      teacherEmail: linkedTeacherEmail,
    );

    _userProfile = newProfile;
    await _storage.saveUserProfile(newProfile);
    notifyListeners();

    // Cloud Firestore'a kaydet (Arka planda çalışır, arayüzü bekletmez)
    _firebaseService.syncUserProfile(newProfile).then((success) {
      if (success) {
        debugPrint('Kullanıcı kaydı Firestore\'a aktarıldı: ${newProfile.email} (${newProfile.role})');
      }
    });

    // Resmi e-posta doğrulama linki gönder
    if (password != null && password.isNotEmpty) {
      _firebaseService.sendVerificationEmail(
        email: newProfile.email,
        password: password,
      );
    }
  }

  /// Öğrenci Koç Kodu ile bir öğretmene bağlanır
  Future<String?> connectWithTeacherCode(String code) async {
    if (_userProfile == null) return 'Oturum bulunamadı.';
    final teacher = await _firebaseService.findTeacherByCode(code);
    if (teacher == null) {
      return 'Bu Koç Kodu ile eşleşen bir öğretmen bulunamadı. Kodu kontrol edin.';
    }
    if (teacher.id == _userProfile!.id) {
      return 'Kendi hesabınızı öğretmen olarak bağlayamazsınız.';
    }

    final ok = await _firebaseService.assignTeacherToStudent(
      studentId: _userProfile!.id,
      teacher: teacher,
    );
    if (!ok) {
      return 'Bağlantı kurulurken bir hata oluştu, lütfen internet bağlantınızı kontrol edin.';
    }

    _userProfile = _userProfile!.copyWith(
      teacherId: teacher.id,
      teacherName: teacher.fullName,
      teacherEmail: teacher.email,
    );
    await _storage.saveUserProfile(_userProfile!);
    notifyListeners();
    return null; // Başarılı
  }

  /// Öğrenci öğretmen bağlantısını kaldırır
  Future<void> disconnectTeacher() async {
    if (_userProfile == null) return;
    await _firebaseService.unlinkStudentFromTeacher(_userProfile!.id);
    _userProfile = _userProfile!.copyWith(clearTeacher: true);
    await _storage.saveUserProfile(_userProfile!);
    notifyListeners();
  }

  /// Öğrenci kendisine verilen ödevi tamamlandı olarak işaretler/kaldırır
  Future<void> toggleMyAssignmentCompleted(String assignmentId) async {
    if (_userProfile == null) return;
    // Yerel optimistik güncelleme
    final current = studentAssignments;
    final optimistic = current.map((a) {
      if (a.id == assignmentId) {
        final next = !a.isCompleted;
        return a.copyWith(
          isCompleted: next,
          completedAt: next ? DateTime.now() : null,
        );
      }
      return a;
    }).toList();

    _userProfile = _userProfile!.copyWith(
      assignmentsJson: jsonEncode(optimistic.map((e) => e.toJson()).toList()),
    );
    await _storage.saveUserProfile(_userProfile!);
    notifyListeners();

    // Bulut senkronizasyonu
    final cloudUpdated = await _firebaseService.toggleStudentAssignment(
      studentId: _userProfile!.id,
      assignmentId: assignmentId,
    );
    if (cloudUpdated != null && _userProfile != null) {
      _userProfile = _userProfile!.copyWith(
        assignmentsJson: jsonEncode(cloudUpdated.map((e) => e.toJson()).toList()),
      );
      await _storage.saveUserProfile(_userProfile!);
      notifyListeners();
    }
  }

  /// Öğrenci öğretmenine mesaj gönderir
  Future<bool> sendMessageToMyTeacher(String text) async {
    if (_userProfile == null || text.trim().isEmpty) return false;
    final msg = CoachMessageModel(
      id: const Uuid().v4(),
      senderId: _userProfile!.id,
      senderName: _userProfile!.fullName,
      senderRole: 'student',
      message: text.trim(),
      createdAt: DateTime.now(),
      isRead: false,
    );

    final optimistic = [...studentMessages, msg];
    _userProfile = _userProfile!.copyWith(
      messagesJson: jsonEncode(optimistic.map((e) => e.toJson()).toList()),
    );
    await _storage.saveUserProfile(_userProfile!);
    notifyListeners();

    final cloudUpdated = await _firebaseService.sendCoachMessage(
      studentId: _userProfile!.id,
      message: msg,
    );
    if (cloudUpdated != null && _userProfile != null) {
      _userProfile = _userProfile!.copyWith(
        messagesJson: jsonEncode(cloudUpdated.map((e) => e.toJson()).toList()),
      );
      await _storage.saveUserProfile(_userProfile!);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Öğretmenden gelen mesajları okundu olarak işaretler
  Future<void> markTeacherMessagesAsRead() async {
    if (_userProfile == null || unreadTeacherMessagesCount == 0) return;
    final updated = studentMessages.map((m) {
      if (m.senderRole == 'teacher' && !m.isRead) {
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();

    _userProfile = _userProfile!.copyWith(
      messagesJson: jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
    await _storage.saveUserProfile(_userProfile!);
    notifyListeners();

    await _firebaseService.markMessagesAsRead(
      studentId: _userProfile!.id,
      readerRole: 'student',
    );
  }

  Future<bool> sendVerificationEmail([String? password]) async {
    if (_userProfile == null) return false;
    return await _firebaseService.sendVerificationEmail(
      email: _userProfile!.email,
      password: password ?? '',
    );
  }

  Future<bool> checkEmailVerification([String? password]) async {
    if (_userProfile == null) return false;
    final isVerified = await _firebaseService.checkEmailVerified(
      email: _userProfile!.email,
      password: password ?? '',
    );
    if (isVerified && !_userProfile!.isEmailVerified) {
      await setEmailVerified(true);
    }
    return isVerified;
  }

  List<UserProfileModel> get savedProfiles => _storage.loadAllUserProfiles();
  String? get lastSocialEmail => _storage.getLastSocialEmail();

  UserProfileModel? findProfileByEmail(String email) {
    return _storage.findProfileByEmail(email);
  }

  Future<void> loginAsUser(UserProfileModel profile) async {
    _userProfile = profile;
    await _storage.saveUserProfile(profile);
    notifyListeners();

    _firebaseService.syncUserProfile(profile);
    syncCloudUserData();
  }

  /// E-posta ile giriş yap (Önce yerel hafıza, yoksa Firestore bulutundan getir)
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    // 1. Önce yerelde kayıtlı mı kontrol et
    final existing = _storage.findProfileByEmail(cleanEmail);
    if (existing != null) {
      _userProfile = existing;
      await _storage.saveUserProfile(existing);
      notifyListeners();
      syncCloudUserData();
      return true;
    }

    // 2. Yerelde yoksa Firestore bulutundan sorgula
    try {
      final cloudProfile = await _firebaseService.fetchProfileByEmail(cleanEmail);
      if (cloudProfile != null) {
        _userProfile = cloudProfile;
        await _storage.saveUserProfile(cloudProfile);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Cloud profil getirme hatası: $e');
    }

    return false;
  }

  /// Apple veya Google ile doğrudan giriş yapma (Eğer kayıtlıysa)
  Future<bool> loginWithSocialEmail(String email) async {
    // 1. Yerelde ara
    final existing = _storage.findProfileByEmail(email);
    if (existing != null) {
      _userProfile = existing;
      await _storage.saveUserProfile(existing);
      notifyListeners();
      syncCloudUserData();
      return true;
    }

    // 2. Cloud Firestore'dan ara
    try {
      final cloudProfile = await _firebaseService.fetchProfileByEmail(email);
      if (cloudProfile != null) {
        _userProfile = cloudProfile;
        await _storage.saveUserProfile(cloudProfile);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Sosyal giriş bulut sorgulama hatası: $e');
    }

    return false;
  }

  Future<void> updateProfile(UserProfileModel updated) async {
    _userProfile = updated;
    await _storage.saveUserProfile(updated);
    notifyListeners();

    // Firestore güncellemesi
    _firebaseService.syncUserProfile(updated);
  }

  Future<void> setEmailVerified(bool verified) async {
    if (_userProfile == null) return;
    final updated = _userProfile!.copyWith(isEmailVerified: verified);
    await updateProfile(updated);
  }

  Future<void> logout() async {
    _userProfile = null;
    await _storage.clearUserProfile();
    notifyListeners();
  }
}
