import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile_model.dart';

/// Firebase Cloud Firestore Senkronizasyon ve E-posta Doğrulama Servisi
/// Bu servis, öğrenci kayıtlarını, hedef bölüm ve puanlarını,
/// üyelik (Premium / Ücretsiz) durumunu Firebase Cloud Firestore'a senkronize eder
/// ve resmi e-posta doğrulama işlemlerini yürütür.
/// Hem yerel SDK hem de Web/Çapraz Platform için doğrudan Firestore REST API desteği içerir.
class AppFirebaseService {
  static final AppFirebaseService _instance = AppFirebaseService._internal();
  factory AppFirebaseService() => _instance;
  AppFirebaseService._internal();

  static const String _apiKey = 'AIzaSyB0gbVTJWYKLFQBUQWgbalCqg4qV1azOUE';
  static const String _projectId = 'sinavkocum-2e212';
  static const String _restBaseUrl =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

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
        debugPrint('AppFirebaseService: Henüz Firebase başlatılmamış (REST API devrede).');
      }
    } catch (e) {
      debugPrint('AppFirebaseService init hatası (REST API ile devam edilecek): $e');
      _isInitialized = false;
    }
  }

  /// Öğrenci profilini Firebase Cloud Firestore'a senkronize eder.
  Future<bool> syncUserProfile(UserProfileModel profile) async {
    final cleanEmail = profile.email.toLowerCase().trim();
    final docData = <String, dynamic>{
      'id': profile.id,
      'email': cleanEmail,
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
      'platform': kIsWeb ? 'web' : 'mobile',
    };

    // 1. Önce Firestore SDK ile dene
    if (_isInitialized && _firestore != null) {
      try {
        final sdkData = Map<String, dynamic>.from(docData);
        sdkData['lastActiveAt'] = FieldValue.serverTimestamp();

        await _firestore!
            .collection('users')
            .doc(profile.id)
            .set(sdkData, SetOptions(merge: true));

        if (cleanEmail.isNotEmpty) {
          final emailDocId = cleanEmail.replaceAll('.', '_');
          await _firestore!.collection('user_emails').doc(emailDocId).set({
            'userId': profile.id,
            'email': cleanEmail,
            'fullName': profile.fullName,
            'targetDepartment': profile.targetDepartment,
            'isPremium': profile.isPremium,
            'isEmailVerified': profile.isEmailVerified,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        debugPrint('AppFirebaseService: Öğrenci profili SDK ile Firestore\'a yüklendi: $cleanEmail');
        return true;
      } catch (e) {
        debugPrint('AppFirebaseService: SDK senkronizasyon hatası, REST deneniyor: $e');
      }
    }

    // 2. SDK yoksa veya başarısız olduysa Firestore REST API ile kaydet
    try {
      final userUri = Uri.parse('$_restBaseUrl/users/${profile.id}?key=$_apiKey');
      final restFields = _toFirestoreRestFields(docData);
      final resp = await http.patch(
        userUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': restFields}),
      );

      if (cleanEmail.isNotEmpty) {
        final emailDocId = cleanEmail.replaceAll('.', '_');
        final emailUri = Uri.parse('$_restBaseUrl/user_emails/$emailDocId?key=$_apiKey');
        final emailFields = _toFirestoreRestFields({
          'userId': profile.id,
          'email': cleanEmail,
          'fullName': profile.fullName,
          'targetDepartment': profile.targetDepartment,
          'isPremium': profile.isPremium,
          'isEmailVerified': profile.isEmailVerified,
        });
        await http.patch(
          emailUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'fields': emailFields}),
        );
      }

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        debugPrint('AppFirebaseService: Öğrenci profili REST API ile Firestore\'a yüklendi: $cleanEmail');
        return true;
      }
    } catch (e) {
      debugPrint('AppFirebaseService: REST sync hatası: $e');
    }

    return false;
  }

  /// E-posta adresine göre Firestore'dan öğrenci profili sorgular.
  Future<UserProfileModel?> fetchProfileByEmail(String email) async {
    final cleanEmail = email.toLowerCase().trim();

    // 1. Önce Firestore SDK ile dene
    if (_isInitialized && _firestore != null) {
      try {
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
        debugPrint('AppFirebaseService SDK fetch hatası, REST deneniyor: $e');
      }
    }

    // 2. REST API ile user_emails indeksinden doğrudan getir
    try {
      final emailDocId = cleanEmail.replaceAll('.', '_');
      final emailUri = Uri.parse('$_restBaseUrl/user_emails/$emailDocId?key=$_apiKey');
      final emailResp = await http.get(emailUri);

      if (emailResp.statusCode == 200) {
        final emailData = jsonDecode(emailResp.body) as Map<String, dynamic>;
        final flatEmail = _flattenFirestoreFields(emailData['fields'] as Map<String, dynamic>? ?? {});
        final userId = flatEmail['userId'] as String?;

        if (userId != null && userId.isNotEmpty) {
          final userUri = Uri.parse('$_restBaseUrl/users/$userId?key=$_apiKey');
          final userResp = await http.get(userUri);
          if (userResp.statusCode == 200) {
            final userData = jsonDecode(userResp.body) as Map<String, dynamic>;
            final flatUser = _flattenFirestoreFields(userData['fields'] as Map<String, dynamic>? ?? {});
            debugPrint('AppFirebaseService: Profil REST user_emails ile bulundu: $cleanEmail');
            return UserProfileModel.fromJson(flatUser);
          }
        }
      }

      // 3. user_emails'de bulunamadıysa users koleksiyonunu tara
      final allUsersUri = Uri.parse('$_restBaseUrl/users?key=$_apiKey');
      final allUsersResp = await http.get(allUsersUri);
      if (allUsersResp.statusCode == 200) {
        final allUsersData = jsonDecode(allUsersResp.body) as Map<String, dynamic>;
        final docs = allUsersData['documents'] as List? ?? [];
        for (final doc in docs) {
          if (doc is Map && doc.containsKey('fields')) {
            final flat = _flattenFirestoreFields(doc['fields'] as Map<String, dynamic>);
            final docEmail = (flat['email'] as String? ?? '').toLowerCase().trim();
            if (docEmail == cleanEmail) {
              debugPrint('AppFirebaseService: Profil REST users taraması ile bulundu: $cleanEmail');
              return UserProfileModel.fromJson(flat);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('AppFirebaseService REST fetch hatası: $e');
    }

    return null;
  }

  /// Öğrencinin Premium üyelik durumunu Firebase'den anlık sorgular.
  Future<bool> checkPremiumStatus(String userId) async {
    if (_isInitialized && _firestore != null) {
      try {
        final doc = await _firestore!.collection('users').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          return data['isPremium'] as bool? ?? false;
        }
      } catch (e) {
        debugPrint('AppFirebaseService checkPremiumStatus SDK hatası: $e');
      }
    }

    try {
      final userUri = Uri.parse('$_restBaseUrl/users/$userId?key=$_apiKey');
      final resp = await http.get(userUri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final flat = _flattenFirestoreFields(data['fields'] as Map<String, dynamic>? ?? {});
        return flat['isPremium'] as bool? ?? false;
      }
    } catch (e) {
      debugPrint('AppFirebaseService checkPremiumStatus REST hatası: $e');
    }

    return false;
  }

  /// Yönetici için tüm kayıtlı öğrencileri Firestore'dan çeker
  Future<List<UserProfileModel>> fetchAllUsers() async {
    final List<UserProfileModel> users = [];

    // 1. SDK ile dene
    if (_isInitialized && _firestore != null) {
      try {
        final snap = await _firestore!.collection('users').get();
        for (final doc in snap.docs) {
          users.add(UserProfileModel.fromJson(doc.data()));
        }
        if (users.isNotEmpty) {
          users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return users;
        }
      } catch (e) {
        debugPrint('AppFirebaseService fetchAllUsers SDK hatası: $e');
      }
    }

    // 2. REST API ile getir
    try {
      final uri = Uri.parse('$_restBaseUrl/users?key=$_apiKey');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final docs = data['documents'] as List? ?? [];
        for (final doc in docs) {
          if (doc is Map && doc.containsKey('fields')) {
            final flat = _flattenFirestoreFields(doc['fields'] as Map<String, dynamic>);
            users.add(UserProfileModel.fromJson(flat));
          }
        }
      }
    } catch (e) {
      debugPrint('AppFirebaseService fetchAllUsers REST hatası: $e');
    }

    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return users;
  }

  /// Öğrencinin Premium üyelik durumunu günceller (Admin yetkisi)
  Future<bool> setStudentPremiumStatus({
    required String userId,
    required String email,
    required bool isPremium,
  }) async {
    final plan = isPremium ? 'Premium' : 'Ücretsiz';

    // 1. SDK
    if (_isInitialized && _firestore != null) {
      try {
        await _firestore!.collection('users').doc(userId).set({
          'isPremium': isPremium,
          'membershipPlan': plan,
        }, SetOptions(merge: true));

        final cleanEmail = email.toLowerCase().trim();
        if (cleanEmail.isNotEmpty) {
          final docId = cleanEmail.replaceAll('.', '_');
          await _firestore!.collection('user_emails').doc(docId).set({
            'isPremium': isPremium,
          }, SetOptions(merge: true));
        }
        return true;
      } catch (e) {
        debugPrint('setStudentPremiumStatus SDK hatası: $e');
      }
    }

    // 2. REST API
    try {
      final userUri = Uri.parse(
        '$_restBaseUrl/users/$userId?updateMask.fieldPaths=isPremium&updateMask.fieldPaths=membershipPlan&key=$_apiKey',
      );
      final resp = await http.patch(
        userUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fields': {
            'isPremium': {'booleanValue': isPremium},
            'membershipPlan': {'stringValue': plan},
          }
        }),
      );

      final cleanEmail = email.toLowerCase().trim();
      if (cleanEmail.isNotEmpty) {
        final docId = cleanEmail.replaceAll('.', '_');
        final emailUri = Uri.parse(
          '$_restBaseUrl/user_emails/$docId?updateMask.fieldPaths=isPremium&key=$_apiKey',
        );
        await http.patch(
          emailUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'fields': {
              'isPremium': {'booleanValue': isPremium},
            }
          }),
        );
      }

      return resp.statusCode == 200;
    } catch (e) {
      debugPrint('setStudentPremiumStatus REST hatası: $e');
    }
    return false;
  }

  /// Firebase Auth üzerinden e-posta doğrulama linki gönderir (Evrensel HTTP)
  Future<bool> sendVerificationEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = email.trim();
      final pwd = password.isNotEmpty ? password : 'S1navKocum2026!';

      String? idToken;
      final signUpUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey');
      final signUpResp = await http.post(
        signUpUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': cleanEmail,
          'password': pwd,
          'returnSecureToken': true,
        }),
      );

      final signUpData = jsonDecode(signUpResp.body) as Map<String, dynamic>;
      idToken = signUpData['idToken'] as String?;

      if (idToken == null) {
        final signInUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey');
        final signInResp = await http.post(
          signInUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': cleanEmail,
            'password': pwd,
            'returnSecureToken': true,
          }),
        );
        final signInData = jsonDecode(signInResp.body) as Map<String, dynamic>;
        idToken = signInData['idToken'] as String?;
      }

      if (idToken != null) {
        final oobUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey');
        final oobResp = await http.post(
          oobUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'requestType': 'VERIFY_EMAIL',
            'idToken': idToken,
          }),
        );
        debugPrint('Firebase sendVerificationEmail yanıtı: ${oobResp.statusCode}');
        return oobResp.statusCode == 200;
      }
    } catch (e) {
      debugPrint('sendVerificationEmail hatası: $e');
    }
    return false;
  }

  /// Öğrencinin e-postayı onaylayıp onaylamadığını kontrol eder
  Future<bool> checkEmailVerified({
    required String email,
    required String password,
  }) async {
    try {
      final cleanEmail = email.trim();
      final pwd = password.isNotEmpty ? password : 'S1navKocum2026!';

      final signInUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey');
      final signInResp = await http.post(
        signInUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': cleanEmail,
          'password': pwd,
          'returnSecureToken': true,
        }),
      );

      final signInData = jsonDecode(signInResp.body) as Map<String, dynamic>;
      final idToken = signInData['idToken'] as String?;

      if (idToken != null) {
        final lookupUri = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$_apiKey');
        final lookupResp = await http.post(
          lookupUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'idToken': idToken}),
        );
        final lookupData = jsonDecode(lookupResp.body) as Map<String, dynamic>;
        final users = lookupData['users'] as List?;
        if (users != null && users.isNotEmpty) {
          return users.first['emailVerified'] as bool? ?? false;
        }
      }
    } catch (e) {
      debugPrint('checkEmailVerified hatası: $e');
    }
    return false;
  }

  /// Firestore REST API JSON formatını standart Dart Map'e dönüştürür
  static Map<String, dynamic> _flattenFirestoreFields(Map<String, dynamic> fields) {
    final result = <String, dynamic>{};
    fields.forEach((key, val) {
      if (val is Map) {
        if (val.containsKey('stringValue')) {
          result[key] = val['stringValue'];
        } else if (val.containsKey('booleanValue')) {
          result[key] = val['booleanValue'];
        } else if (val.containsKey('integerValue')) {
          result[key] = int.tryParse(val['integerValue'].toString()) ?? 0;
        } else if (val.containsKey('doubleValue')) {
          result[key] = (val['doubleValue'] as num).toDouble();
        } else if (val.containsKey('timestampValue')) {
          result[key] = val['timestampValue'];
        }
      } else {
        result[key] = val;
      }
    });
    return result;
  }

  /// Dart Map'i Firestore REST API formatına dönüştürür
  static Map<String, dynamic> _toFirestoreRestFields(Map<String, dynamic> data) {
    final fields = <String, dynamic>{};
    data.forEach((key, val) {
      if (val is String) {
        fields[key] = {'stringValue': val};
      } else if (val is bool) {
        fields[key] = {'booleanValue': val};
      } else if (val is int) {
        fields[key] = {'integerValue': val.toString()};
      } else if (val is double) {
        fields[key] = {'doubleValue': val};
      }
    });
    return fields;
  }
}
