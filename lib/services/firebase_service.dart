import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/assignment_model.dart';
import '../models/coach_message_model.dart';
import '../models/student_study_stats_model.dart';
import '../models/user_profile_model.dart';

/// Firebase Cloud Firestore Senkronizasyon ve E-posta Doğrulama Servisi
/// Bu servis, öğrenci ve öğretmen kayıtlarını, hedef bölüm ve puanlarını,
/// 3 aylık deneme ve üyelik durumunu, ödevleri, mesajları ve çalışma istatistiklerini
/// Firebase Cloud Firestore'a senkronize eder.
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

  /// Ortak alan güncelleme yardımcısı (hem SDK hem REST API için tek alan/çoklu alan updateMask desteği)
  Future<bool> _patchUserFields(String userId, Map<String, dynamic> fields) async {
    if (userId.isEmpty || fields.isEmpty) return false;

    if (_isInitialized && _firestore != null) {
      try {
        await _firestore!.collection('users').doc(userId).set(
              fields,
              SetOptions(merge: true),
            );
        return true;
      } catch (e) {
        debugPrint('_patchUserFields SDK hatası, REST deneniyor: $e');
      }
    }

    try {
      final maskParams = fields.keys
          .map((k) => 'updateMask.fieldPaths=${Uri.encodeComponent(k)}')
          .join('&');
      final uri = Uri.parse('$_restBaseUrl/users/$userId?$maskParams&key=$_apiKey');
      final restFields = _toFirestoreRestFields(fields);
      final resp = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fields': restFields}),
      );
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      debugPrint('_patchUserFields REST hatası: $e');
    }
    return false;
  }

  /// Öğrenci veya Öğretmen profilini Firebase Cloud Firestore'a senkronize eder.
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
      'coachNote': profile.coachNote ?? '',
      'coachNoteUpdatedAt': profile.coachNoteUpdatedAt?.toIso8601String() ?? '',
      'createdAt': profile.createdAt.toIso8601String(),
      'role': profile.role,
      'teacherCode': profile.teacherCode ?? '',
      'teacherId': profile.teacherId ?? '',
      'teacherName': profile.teacherName ?? '',
      'teacherEmail': profile.teacherEmail ?? '',
      'trialEndsAt': profile.effectiveTrialEndDate.toIso8601String(),
      if (profile.studyStatsJson != null) 'studyStatsJson': profile.studyStatsJson,
      if (profile.assignmentsJson != null) 'assignmentsJson': profile.assignmentsJson,
      if (profile.messagesJson != null) 'messagesJson': profile.messagesJson,
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
            'role': profile.role,
            'teacherCode': profile.teacherCode ?? '',
            'teacherId': profile.teacherId ?? '',
            'targetDepartment': profile.targetDepartment,
            'isPremium': profile.isPremium,
            'isEmailVerified': profile.isEmailVerified,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        debugPrint('AppFirebaseService: Profil SDK ile Firestore\'a yüklendi: $cleanEmail');
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
          'role': profile.role,
          'teacherCode': profile.teacherCode ?? '',
          'teacherId': profile.teacherId ?? '',
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
        debugPrint('AppFirebaseService: Profil REST API ile Firestore\'a yüklendi: $cleanEmail');
        return true;
      }
    } catch (e) {
      debugPrint('AppFirebaseService: REST sync hatası: $e');
    }

    return false;
  }

  /// Öğrencinin anlık çalışma istatistik özetini buluta kaydeder
  Future<bool> syncStudentStudyStats(String userId, StudentStudyStatsModel stats) async {
    final jsonStr = jsonEncode(stats.toJson());
    return _patchUserFields(userId, {'studyStatsJson': jsonStr});
  }

  /// E-posta adresine göre Firestore'dan kullanıcı profili sorgular.
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
            return UserProfileModel.fromJson(flatUser);
          }
        }
      }

      // 3. user_emails'de bulunamadıysa users koleksiyonunu tara
      final allUsers = await fetchAllUsers();
      for (final u in allUsers) {
        if (u.email.toLowerCase().trim() == cleanEmail) {
          return u;
        }
      }
    } catch (e) {
      debugPrint('AppFirebaseService REST fetch hatası: $e');
    }

    return null;
  }

  /// Kullanıcının güncel bulut bilgilerini çeker (isPremium, coachNote, ödevler, mesajlar vb.)
  Future<Map<String, dynamic>?> fetchCloudUserData(String userId) async {
    if (_isInitialized && _firestore != null) {
      try {
        final doc = await _firestore!.collection('users').doc(userId).get();
        if (doc.exists && doc.data() != null) {
          return doc.data();
        }
      } catch (e) {
        debugPrint('fetchCloudUserData SDK hatası: $e');
      }
    }

    try {
      final userUri = Uri.parse('$_restBaseUrl/users/$userId?key=$_apiKey');
      final resp = await http.get(userUri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return _flattenFirestoreFields(data['fields'] as Map<String, dynamic>? ?? {});
      }
    } catch (e) {
      debugPrint('fetchCloudUserData REST hatası: $e');
    }
    return null;
  }

  /// Tüm kayıtlı kullanıcıları Firestore'dan çeker
  Future<List<UserProfileModel>> fetchAllUsers() async {
    final List<UserProfileModel> users = [];

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

    try {
      final uri = Uri.parse('$_restBaseUrl/users?pageSize=200&key=$_apiKey');
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

  /// Koç Kodu ile Öğretmeni bulur
  Future<UserProfileModel?> findTeacherByCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;

    if (_isInitialized && _firestore != null) {
      try {
        final snap = await _firestore!
            .collection('users')
            .where('teacherCode', isEqualTo: cleanCode)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          return UserProfileModel.fromJson(snap.docs.first.data());
        }
      } catch (e) {
        debugPrint('findTeacherByCode SDK hatası: $e');
      }
    }

    final allUsers = await fetchAllUsers();
    for (final u in allUsers) {
      if (u.isTeacher && (u.teacherCode ?? '').trim().toUpperCase() == cleanCode) {
        return u;
      }
    }
    return null;
  }

  /// Öğretmene bağlı tüm öğrencileri getirir
  Future<List<UserProfileModel>> fetchStudentsForTeacher(String teacherId) async {
    if (teacherId.isEmpty) return [];
    final all = await fetchAllUsers();
    return all
        .where((u) => u.teacherId == teacherId && u.id != teacherId)
        .toList();
  }

  /// Öğretmen, e-posta adresi ile öğrenciyi kendi altına ekler
  /// Dönüş: {'status': 'linked' | 'invited' | 'already_linked' | 'is_teacher' | 'error', 'student': UserProfileModel?}
  Future<Map<String, dynamic>> linkStudentToTeacherByEmail({
    required String studentEmail,
    required UserProfileModel teacher,
  }) async {
    final cleanEmail = studentEmail.toLowerCase().trim();
    if (cleanEmail.isEmpty) return {'status': 'error'};

    final student = await fetchProfileByEmail(cleanEmail);

    if (student != null) {
      if (student.id == teacher.id || student.isTeacher) {
        return {'status': 'is_teacher'};
      }
      if (student.teacherId == teacher.id) {
        return {'status': 'already_linked', 'student': student};
      }

      final ok = await _patchUserFields(student.id, {
        'teacherId': teacher.id,
        'teacherName': teacher.fullName,
        'teacherEmail': teacher.email,
      });

      if (ok) {
        final updated = student.copyWith(
          teacherId: teacher.id,
          teacherName: teacher.fullName,
          teacherEmail: teacher.email,
        );
        return {'status': 'linked', 'student': updated};
      }
      return {'status': 'error'};
    }

    // Öğrenci henüz kayıt olmamışsa user_emails'e davet kaydı bırak (kayıt olunca otomatik bağlansın)
    try {
      final emailDocId = cleanEmail.replaceAll('.', '_');
      if (_isInitialized && _firestore != null) {
        await _firestore!.collection('user_emails').doc(emailDocId).set({
          'email': cleanEmail,
          'pendingTeacherId': teacher.id,
          'pendingTeacherName': teacher.fullName,
          'pendingTeacherEmail': teacher.email,
        }, SetOptions(merge: true));
        return {'status': 'invited'};
      }

      final emailUri = Uri.parse(
        '$_restBaseUrl/user_emails/$emailDocId?updateMask.fieldPaths=email&updateMask.fieldPaths=pendingTeacherId&updateMask.fieldPaths=pendingTeacherName&updateMask.fieldPaths=pendingTeacherEmail&key=$_apiKey',
      );
      final resp = await http.patch(
        emailUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fields': _toFirestoreRestFields({
            'email': cleanEmail,
            'pendingTeacherId': teacher.id,
            'pendingTeacherName': teacher.fullName,
            'pendingTeacherEmail': teacher.email,
          }),
        }),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {'status': 'invited'};
      }
    } catch (e) {
      debugPrint('linkStudentToTeacherByEmail invite hatası: $e');
    }

    return {'status': 'error'};
  }

  /// Öğrenci kayıt olurken kendisi için bırakılmış öğretmen daveti var mı kontrol eder
  Future<Map<String, String>?> checkPendingTeacherInvite(String email) async {
    final cleanEmail = email.toLowerCase().trim();
    if (cleanEmail.isEmpty) return null;
    final emailDocId = cleanEmail.replaceAll('.', '_');

    try {
      if (_isInitialized && _firestore != null) {
        final doc = await _firestore!.collection('user_emails').doc(emailDocId).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final tId = data['pendingTeacherId'] as String?;
          if (tId != null && tId.isNotEmpty) {
            return {
              'teacherId': tId,
              'teacherName': data['pendingTeacherName'] as String? ?? 'Öğretmen',
              'teacherEmail': data['pendingTeacherEmail'] as String? ?? '',
            };
          }
        }
      }

      final uri = Uri.parse('$_restBaseUrl/user_emails/$emailDocId?key=$_apiKey');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final flat = _flattenFirestoreFields(data['fields'] as Map<String, dynamic>? ?? {});
        final tId = flat['pendingTeacherId'] as String?;
        if (tId != null && tId.isNotEmpty) {
          return {
            'teacherId': tId,
            'teacherName': flat['pendingTeacherName'] as String? ?? 'Öğretmen',
            'teacherEmail': flat['pendingTeacherEmail'] as String? ?? '',
          };
        }
      }
    } catch (e) {
      debugPrint('checkPendingTeacherInvite hatası: $e');
    }
    return null;
  }

  /// Öğrenciyi öğretmenden ayırır
  Future<bool> unlinkStudentFromTeacher(String studentId) async {
    return _patchUserFields(studentId, {
      'teacherId': '',
      'teacherName': '',
      'teacherEmail': '',
    });
  }

  /// Öğrenciye öğretmeni bağlar (Koç Kodu ile)
  Future<bool> assignTeacherToStudent({
    required String studentId,
    required UserProfileModel teacher,
  }) async {
    return _patchUserFields(studentId, {
      'teacherId': teacher.id,
      'teacherName': teacher.fullName,
      'teacherEmail': teacher.email,
    });
  }

  // --- ÖDEV SİSTEMİ ---

  /// Öğrencinin en güncel ödev listesini buluttan okur
  Future<List<AssignmentModel>> fetchStudentAssignments(String studentId) async {
    final cloud = await fetchCloudUserData(studentId);
    if (cloud != null) {
      final raw = cloud['assignmentsJson'] as String?;
      if (raw != null && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded
                .whereType<Map<String, dynamic>>()
                .map((e) => AssignmentModel.fromJson(e))
                .toList();
          }
        } catch (_) {}
      }
    }
    return [];
  }

  /// Öğrenciye yeni ödev ekler (Mevcut ödevleri koruyarak üstüne ekler)
  Future<List<AssignmentModel>?> addStudentAssignment({
    required String studentId,
    required AssignmentModel assignment,
  }) async {
    final current = await fetchStudentAssignments(studentId);
    final updated = [assignment, ...current];
    final jsonStr = jsonEncode(updated.map((e) => e.toJson()).toList());
    final ok = await _patchUserFields(studentId, {'assignmentsJson': jsonStr});
    return ok ? updated : null;
  }

  /// Öğrencinin ödevini tamamlandı / bekliyor olarak işaretler
  Future<List<AssignmentModel>?> toggleStudentAssignment({
    required String studentId,
    required String assignmentId,
  }) async {
    final current = await fetchStudentAssignments(studentId);
    final updated = current.map((a) {
      if (a.id == assignmentId) {
        final nextState = !a.isCompleted;
        return a.copyWith(
          isCompleted: nextState,
          completedAt: nextState ? DateTime.now() : null,
        );
      }
      return a;
    }).toList();

    final jsonStr = jsonEncode(updated.map((e) => e.toJson()).toList());
    final ok = await _patchUserFields(studentId, {'assignmentsJson': jsonStr});
    return ok ? updated : null;
  }

  /// Öğrencinin ödevini siler
  Future<List<AssignmentModel>?> deleteStudentAssignment({
    required String studentId,
    required String assignmentId,
  }) async {
    final current = await fetchStudentAssignments(studentId);
    final updated = current.where((a) => a.id != assignmentId).toList();
    final jsonStr = jsonEncode(updated.map((e) => e.toJson()).toList());
    final ok = await _patchUserFields(studentId, {'assignmentsJson': jsonStr});
    return ok ? updated : null;
  }

  // --- MESAJLAŞMA SİSTEMİ ---

  /// Öğrenci ile öğretmen arasındaki mesajları okur
  Future<List<CoachMessageModel>> fetchStudentMessages(String studentId) async {
    final cloud = await fetchCloudUserData(studentId);
    if (cloud != null) {
      final raw = cloud['messagesJson'] as String?;
      if (raw != null && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded
                .whereType<Map<String, dynamic>>()
                .map((e) => CoachMessageModel.fromJson(e))
                .toList();
          }
        } catch (_) {}
      }
    }
    return [];
  }

  /// Öğrenciye veya öğretmene mesaj gönderir
  Future<List<CoachMessageModel>?> sendCoachMessage({
    required String studentId,
    required CoachMessageModel message,
  }) async {
    final current = await fetchStudentMessages(studentId);
    final updated = [...current, message];
    // Maksimum son 100 mesajı tut (belge boyutunu makul tutmak için)
    final trimmed = updated.length > 100 ? updated.sublist(updated.length - 100) : updated;
    final jsonStr = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    final ok = await _patchUserFields(studentId, {'messagesJson': jsonStr});
    return ok ? trimmed : null;
  }

  /// Okunmamış mesajları okundu olarak işaretler
  Future<List<CoachMessageModel>?> markMessagesAsRead({
    required String studentId,
    required String readerRole, // 'student' ise teacher mesajlarını okundu yap, 'teacher' ise student mesajlarını
  }) async {
    final current = await fetchStudentMessages(studentId);
    bool changed = false;
    final updated = current.map((m) {
      final shouldMark = (readerRole == 'student' && m.senderRole == 'teacher' && !m.isRead) ||
          (readerRole == 'teacher' && m.senderRole == 'student' && !m.isRead);
      if (shouldMark) {
        changed = true;
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();

    if (!changed) return current;
    final jsonStr = jsonEncode(updated.map((e) => e.toJson()).toList());
    final ok = await _patchUserFields(studentId, {'messagesJson': jsonStr});
    return ok ? updated : current;
  }

  // --- YÖNETİCİ / PREMİUM / KOÇ NOTU ---

  /// Öğrencinin Premium üyelik durumunu günceller (Admin yetkisi)
  Future<bool> setStudentPremiumStatus({
    required String userId,
    required String email,
    required bool isPremium,
  }) async {
    final plan = isPremium ? 'Premium' : 'Ücretsiz';
    final ok = await _patchUserFields(userId, {
      'isPremium': isPremium,
      'membershipPlan': plan,
    });

    final cleanEmail = email.toLowerCase().trim();
    if (cleanEmail.isNotEmpty) {
      final docId = cleanEmail.replaceAll('.', '_');
      if (_isInitialized && _firestore != null) {
        try {
          await _firestore!.collection('user_emails').doc(docId).set({
            'isPremium': isPremium,
          }, SetOptions(merge: true));
        } catch (_) {}
      } else {
        try {
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
        } catch (_) {}
      }
    }
    return ok;
  }

  /// Öğrenciye özel koçluk notunu / tavsiyesini kaydeder
  Future<bool> setStudentCoachNote({
    required String userId,
    required String email,
    required String coachNote,
  }) async {
    final nowIso = DateTime.now().toIso8601String();
    return _patchUserFields(userId, {
      'coachNote': coachNote,
      'coachNoteUpdatedAt': nowIso,
    });
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
