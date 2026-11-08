import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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

  String get displayName => _userProfile?.firstName ?? 'Öğrenci';
  String get email => _userProfile?.email ?? '';
  String get targetExam => _userProfile?.targetExam ?? 'YKS';
  int get dailyTargetHours => _userProfile?.dailyTargetHours ?? 3;
  String get targetDepartment => _userProfile?.targetDepartment ?? 'Genel Başarı Hedefi';
  double get targetScore => _userProfile?.targetScore ?? 400.0;
  double get targetNet => _userProfile?.targetNet ?? 75.0;
  bool get isPremium => _userProfile?.isPremium ?? false;
  String get membershipPlan => _userProfile?.membershipPlan ?? 'Ücretsiz';
  bool get isEmailVerified => _userProfile?.isEmailVerified ?? false;
  String? get coachNote => _userProfile?.coachNote;
  DateTime? get coachNoteUpdatedAt => _userProfile?.coachNoteUpdatedAt;

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

    // Arka planda Firebase'den Premium / üyelik ve koçluk durumunu kontrol et
    if (_userProfile != null) {
      syncCloudUserData();
    }
  }

  Future<void> syncCloudUserData() async {
    try {
      if (_userProfile == null) return;
      final cloudData = await _firebaseService.fetchCloudUserData(_userProfile!.id);
      if (cloudData != null && _userProfile != null) {
        final cloudPremium = cloudData['isPremium'] as bool? ?? false;
        final cloudPlan = cloudData['membershipPlan'] as String? ?? (cloudPremium ? 'Premium' : 'Ücretsiz');
        final cloudCoachNote = cloudData['coachNote'] as String?;
        final cloudNoteUpdatedStr = cloudData['coachNoteUpdatedAt'] as String?;
        final cloudNoteDate = cloudNoteUpdatedStr != null ? DateTime.tryParse(cloudNoteUpdatedStr) : null;

        if (cloudPremium != _userProfile!.isPremium ||
            cloudCoachNote != _userProfile!.coachNote ||
            cloudPlan != _userProfile!.membershipPlan) {
          _userProfile = _userProfile!.copyWith(
            isPremium: cloudPremium,
            membershipPlan: cloudPlan,
            coachNote: cloudCoachNote,
            coachNoteUpdatedAt: cloudNoteDate,
          );
          await _storage.saveUserProfile(_userProfile!);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Cloud syncUserData hatası: $e');
    }
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
  }) async {
    final newProfile = UserProfileModel(
      id: const Uuid().v4(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      birthDate: birthDate,
      targetExam: targetExam,
      dailyTargetHours: dailyTargetHours,
      targetDepartment: targetDepartment ?? 'Genel Başarı Hedefi',
      targetScore: targetScore ?? 400.0,
      targetNet: targetNet ?? 75.0,
      createdAt: DateTime.now(),
      isPremium: false,
      membershipPlan: 'Ücretsiz',
      isEmailVerified: false,
    );

    _userProfile = newProfile;
    await _storage.saveUserProfile(newProfile);
    notifyListeners();

    // Cloud Firestore'a kaydet (Arka planda çalışır, arayüzü bekletmez)
    _firebaseService.syncUserProfile(newProfile).then((success) {
      if (success) {
        debugPrint('Kullanıcı kaydı başarıyla Firestore bulut veritabanına aktarıldı: ${newProfile.email}');
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

  UserProfileModel? findProfileByEmail(String email) {
    return _storage.findProfileByEmail(email);
  }

  Future<void> loginAsUser(UserProfileModel profile) async {
    _userProfile = profile;
    await _storage.saveUserProfile(profile);
    notifyListeners();

    // Firestore senkronizasyonu
    _firebaseService.syncUserProfile(profile);
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
      _firebaseService.syncUserProfile(existing);
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
      _firebaseService.syncUserProfile(existing);
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
