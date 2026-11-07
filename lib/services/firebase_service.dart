import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';

/// Firebase Cloud Firestore Senkronizasyon ve E-posta Doğrulama Servisi
/// Bu servis, öğrenci kayıtlarını, hedef bölüm ve puanlarını,
/// üyelik (Premium / Ücretsiz) durumunu Firebase Cloud Firestore'a senkronize eder
/// ve resmi e-posta doğrulama işlemlerini yürütür.
class AppFirebaseService {
  static final AppFirebaseService _instance = AppFirebaseService._internal();
  factory AppFirebaseService() => _instance;
  AppFirebaseService._internal();

  static const String _apiKey = 'AIzaSyB0gbVTJWYKLFQBUQWgbalCqg4qV1azOUE';

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseFirestore? _firestore;

  /// Firebase başlatma kontrolü
  Future<void> init() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isInitialized = true;
        debugPrint('AppFirebaseService: Firebase Firestore başarıyla bağlandı ve hazır.');
      } else {
        debugPrint('AppFirebaseService: Henüz Firebase başlatılmamış.');
      }
    } catch (e) {
      debugPrint('AppFirebaseService init hatası: $e');
      _isInitialized = false;
    }
  }

  /// Öğrenci profilini Firebase Cloud Firestore'a senkronize eder.
  /// Bu sayede Firebase Console üzerinden tüm kayıtları, hedef bölümleri ve
  /// üyelik durumlarını canlı olarak görebilirsiniz.
  Future<bool> syncUserProfile(UserProfileModel profile) async {
    try {
      if (!_isInitialized || _firestore == null) {
        await init();
        if (!_isInitialized || _firestore == null) {
          debugPrint('AppFirebaseService: Çevrimdışı moddasınız, profil Firestore\'a yazılamadı.');
          return false;
        }
      }

      final docData = <String, dynamic>{
        'id': profile.id,
        'email': profile.email.toLowerCase().trim(),
        'firstName': profile.firstName,
        'lastName': profile.lastName,
        'fullName': profile.fullName,
        'birthDate': profile.birthDate.toIso8601String(),
        'targetExam': profile.targetExam,
        'targetDepartment': profile.targetDepartment,
        'targetScore': profile.targetScore,
        'targetNet': profile.targetNet,
        'dailyTargetHours': profile.dailyTargetHours,
        'isPremium': profile.isPremium,
        'membershipPlan': profile.membershipPlan,
        'isEmailVerified': profile.isEmailVerified,
        'createdAt': profile.createdAt.toIso8601String(),
        'lastActiveAt': FieldValue.serverTimestamp(),
        'platform': 'android',
      };

      // 1. users koleksiyonuna profil ID'si ile kaydet
      await _firestore!
          .collection('users')
          .doc(profile.id)
          .set(docData, SetOptions(merge: true));

      // 2. Kolay arama için e-posta indeksi oluştur (e-posta doluysa)
      if (profile.email.isNotEmpty) {
        final emailDocId = profile.email.toLowerCase().replaceAll('.', '_');
        await _firestore!
            .collection('user_emails')
            .doc(emailDocId)
            .set({
          'userId': profile.id,
          'email': profile.email.toLowerCase(),
          'fullName': profile.fullName,
          'targetDepartment': profile.targetDepartment,
          'isPremium': profile.isPremium,
          'isEmailVerified': profile.isEmailVerified,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      debugPrint('AppFirebaseService: Öğrenci profili Firestore\'a başarıyla yüklendi: ${profile.email}');
      return true;
    } catch (e) {
      debugPrint('AppFirebaseService: Firestore senkronizasyon hatası (Çevrimdışı devam ediliyor): $e');
      return false;
    }
  }

  /// E-posta adresine göre Firestore'dan öğrenci profili sorgular.
  Future<UserProfileModel?> fetchProfileByEmail(String email) async {
    try {
      if (!_isInitialized || _firestore == null) await init();
      if (_firestore == null) return null;

      final cleanEmail = email.toLowerCase().trim();
      final querySnapshot = await _firestore!
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return UserProfileModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('AppFirebaseService fetchProfileByEmail hatası: $e');
    }
    return null;
  }

  /// Öğrencinin Premium üyelik durumunu Firebase'den anlık sorgular.
  Future<bool> checkPremiumStatus(String userId) async {
    try {
      if (!_isInitialized || _firestore == null) await init();
      if (_firestore == null) return false;

      final doc = await _firestore!.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return data['isPremium'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('AppFirebaseService checkPremiumStatus hatası: $e');
    }
    return false;
  }

  /// Firebase Auth üzerinden öğrencinin e-posta adresine resmi doğrulama linki gönderir
  Future<bool> sendVerificationEmail({
    required String email,
    required String password,
  }) async {
    try {
      final client = HttpClient();
      final cleanEmail = email.trim();
      final pwd = password.isNotEmpty ? password : 'S1navKocum2026!';

      // 1. Önce hesap oluştur veya var olan hesaba giriş yap
      String? idToken;
      final signUpUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey');
      final signUpReq = await client.postUrl(signUpUri);
      signUpReq.headers.set('Content-Type', 'application/json');
      signUpReq.write(jsonEncode({
        'email': cleanEmail,
        'password': pwd,
        'returnSecureToken': true,
      }));
      final signUpResp = await signUpReq.close();
      final signUpBody = await signUpResp.transform(utf8.decoder).join();
      final signUpData = jsonDecode(signUpBody) as Map<String, dynamic>;
      idToken = signUpData['idToken'] as String?;

      if (idToken == null) {
        // Zaten kayıtlıysa signIn ile token al
        final signInUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey');
        final signInReq = await client.postUrl(signInUri);
        signInReq.headers.set('Content-Type', 'application/json');
        signInReq.write(jsonEncode({
          'email': cleanEmail,
          'password': pwd,
          'returnSecureToken': true,
        }));
        final signInResp = await signInReq.close();
        final signInBody = await signInResp.transform(utf8.decoder).join();
        final signInData = jsonDecode(signInBody) as Map<String, dynamic>;
        idToken = signInData['idToken'] as String?;
      }

      if (idToken != null) {
        // 2. Doğrulama linki gönder (sendOobCode)
        final oobUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey');
        final oobReq = await client.postUrl(oobUri);
        oobReq.headers.set('Content-Type', 'application/json');
        oobReq.write(jsonEncode({
          'requestType': 'VERIFY_EMAIL',
          'idToken': idToken,
        }));
        final oobResp = await oobReq.close();
        debugPrint('Firebase sendVerificationEmail yanıtı: ${oobResp.statusCode}');
        return oobResp.statusCode == 200;
      }
    } catch (e) {
      debugPrint('sendVerificationEmail hatası: $e');
    }
    return false;
  }

  /// Öğrencinin e-postayı onaylayıp onaylamadığını Firebase Auth'tan kontrol eder
  Future<bool> checkEmailVerified({
    required String email,
    required String password,
  }) async {
    try {
      final client = HttpClient();
      final cleanEmail = email.trim();
      final pwd = password.isNotEmpty ? password : 'S1navKocum2026!';

      final signInUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey');
      final signInReq = await client.postUrl(signInUri);
      signInReq.headers.set('Content-Type', 'application/json');
      signInReq.write(jsonEncode({
        'email': cleanEmail,
        'password': pwd,
        'returnSecureToken': true,
      }));
      final signInResp = await signInReq.close();
      final signInBody = await signInResp.transform(utf8.decoder).join();
      final signInData = jsonDecode(signInBody) as Map<String, dynamic>;
      final idToken = signInData['idToken'] as String?;

      if (idToken != null) {
        final lookupUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey');
        final lookupReq = await client.postUrl(lookupUri);
        lookupReq.headers.set('Content-Type', 'application/json');
        lookupReq.write(jsonEncode({
          'idToken': idToken,
        }));
        final lookupResp = await lookupReq.close();
        final lookupBody = await lookupResp.transform(utf8.decoder).join();
        final lookupData = jsonDecode(lookupBody) as Map<String, dynamic>;
        final users = lookupData['users'] as List?;
        if (users != null && users.isNotEmpty) {
          final isVerified = users.first['emailVerified'] as bool? ?? false;
          return isVerified;
        }
      }
    } catch (e) {
      debugPrint('checkEmailVerified hatası: $e');
    }
    return false;
  }
}
