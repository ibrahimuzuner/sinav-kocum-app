import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../models/question_log_model.dart';
import '../models/study_session_model.dart';
import '../models/schedule_item_model.dart';
import '../models/user_profile_model.dart';
import '../models/mock_exam_model.dart';
import 'predefined_data.dart';

class StorageService {
  static const String _keyCourses = 'app_courses';
  static const String _keyTopics = 'app_topics';
  static const String _keyQuestions = 'app_question_logs';
  static const String _keySessions = 'app_study_sessions';
  static const String _keySchedule = 'app_schedule_items';
  static const String _keyMockExams = 'app_mock_exams';
  static const String _keyStreak = 'app_streak_count';
  static const String _keyLastActiveDate = 'app_last_active_date';
  static const String _keyTargetDailyQuestions = 'app_target_daily_questions';
  static const String _keyTargetDailyMinutes = 'app_target_daily_minutes';
  static const String _keyNotificationsEnabled = 'app_notifications_enabled';
  static const String _keyReminderHour = 'app_reminder_hour';
  static const String _keyReminderMinute = 'app_reminder_minute';
  static const String _keyIsDarkMode = 'app_is_dark_mode';
  static const String _keyUserProfile = 'app_user_profile';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- COURSES ---
  List<CourseModel> loadCourses() {
    final allPredefined = PredefinedData.getAllAvailableCourses();
    final raw = _prefs?.getString(_keyCourses);
    if (raw == null || raw.isEmpty) {
      saveCourses(allPredefined);
      return allPredefined;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      final list = decoded.map((e) => CourseModel.fromJson(e as Map<String, dynamic>)).toList();
      final existingIds = list.map((c) => c.id).toSet();
      for (final p in allPredefined) {
        if (!existingIds.contains(p.id)) {
          list.add(p);
        }
      }
      return list;
    } catch (_) {
      return allPredefined;
    }
  }

  Future<void> saveCourses(List<CourseModel> courses) async {
    final raw = jsonEncode(courses.map((c) => c.toJson()).toList());
    await _prefs?.setString(_keyCourses, raw);
  }

  // --- TOPICS ---
  List<TopicModel> loadTopics() {
    final allPredefined = PredefinedData.getDefaultTopics();
    final raw = _prefs?.getString(_keyTopics);
    if (raw == null || raw.isEmpty) {
      saveTopics(allPredefined);
      return allPredefined;
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      final list = decoded.map((e) => TopicModel.fromJson(e as Map<String, dynamic>)).toList();
      final existingIds = list.map((t) => t.id).toSet();
      for (final p in allPredefined) {
        if (!existingIds.contains(p.id)) {
          list.add(p);
        }
      }
      return list;
    } catch (_) {
      return allPredefined;
    }
  }

  Future<void> saveTopics(List<TopicModel> topics) async {
    final raw = jsonEncode(topics.map((t) => t.toJson()).toList());
    await _prefs?.setString(_keyTopics, raw);
  }

  // --- QUESTIONS ---
  List<QuestionLogModel> loadQuestionLogs() {
    final raw = _prefs?.getString(_keyQuestions);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => QuestionLogModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveQuestionLogs(List<QuestionLogModel> logs) async {
    final raw = jsonEncode(logs.map((l) => l.toJson()).toList());
    await _prefs?.setString(_keyQuestions, raw);
  }

  // --- STUDY SESSIONS ---
  List<StudySessionModel> loadStudySessions() {
    final raw = _prefs?.getString(_keySessions);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => StudySessionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveStudySessions(List<StudySessionModel> sessions) async {
    final raw = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs?.setString(_keySessions, raw);
  }

  // --- SCHEDULE ITEMS ---
  List<ScheduleItemModel> loadScheduleItems() {
    final raw = _prefs?.getString(_keySchedule);
    if (raw == null || raw.isEmpty) {
      // Yeni kullanıcılar için boş programla başla, kullanıcı kendi hedeflerini ekler
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      // Eski versiyonlardan kalan def_ ön ekli varsayılan dersleri (Fizik, Kimya vb.) temizle
      final list = decoded
          .map((e) => ScheduleItemModel.fromJson(e as Map<String, dynamic>))
          .where((item) => !item.id.startsWith('def_'))
          .toList();

      if (list.length != decoded.length) {
        saveScheduleItems(list);
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveScheduleItems(List<ScheduleItemModel> items) async {
    final raw = jsonEncode(items.map((i) => i.toJson()).toList());
    await _prefs?.setString(_keySchedule, raw);
  }

  Future<void> clearScheduleItems() async {
    await _prefs?.remove(_keySchedule);
  }

  // --- MOCK EXAMS (DENEMELER) ---
  List<MockExamModel> loadMockExams() {
    final raw = _prefs?.getString(_keyMockExams);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => MockExamModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMockExams(List<MockExamModel> exams) async {
    final raw = jsonEncode(exams.map((e) => e.toJson()).toList());
    await _prefs?.setString(_keyMockExams, raw);
  }

  // --- STREAK & STATS ---
  int loadStreak() => _prefs?.getInt(_keyStreak) ?? 0;
  Future<void> saveStreak(int streak) async {
    await _prefs?.setInt(_keyStreak, streak);
  }

  String? loadLastActiveDate() => _prefs?.getString(_keyLastActiveDate);
  Future<void> saveLastActiveDate(String dateStr) async {
    await _prefs?.setString(_keyLastActiveDate, dateStr);
  }

  // --- SETTINGS ---
  int loadTargetQuestions() => _prefs?.getInt(_keyTargetDailyQuestions) ?? 100;
  Future<void> saveTargetQuestions(int val) async {
    await _prefs?.setInt(_keyTargetDailyQuestions, val);
  }

  int loadTargetMinutes() => _prefs?.getInt(_keyTargetDailyMinutes) ?? 180; // 3 saat
  Future<void> saveTargetMinutes(int val) async {
    await _prefs?.setInt(_keyTargetDailyMinutes, val);
  }

  bool loadNotificationsEnabled() => _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> saveNotificationsEnabled(bool val) async {
    await _prefs?.setBool(_keyNotificationsEnabled, val);
  }

  int loadReminderHour() => _prefs?.getInt(_keyReminderHour) ?? 20;
  Future<void> saveReminderHour(int hour) async {
    await _prefs?.setInt(_keyReminderHour, hour);
  }

  int loadReminderMinute() => _prefs?.getInt(_keyReminderMinute) ?? 30;
  Future<void> saveReminderMinute(int min) async {
    await _prefs?.setInt(_keyReminderMinute, min);
  }

  bool loadIsDarkMode() => _prefs?.getBool(_keyIsDarkMode) ?? false;
  Future<void> saveIsDarkMode(bool isDark) async {
    await _prefs?.setBool(_keyIsDarkMode, isDark);
  }

  // --- USER PROFILE ---
  UserProfileModel? loadUserProfile() {
    final raw = _prefs?.getString(_keyUserProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return UserProfileModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  List<UserProfileModel> loadAllUserProfiles() {
    final raw = _prefs?.getString('app_all_user_profiles');
    if (raw == null || raw.isEmpty) {
      final current = loadUserProfile();
      return current != null ? [current] : [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      final current = loadUserProfile();
      return current != null ? [current] : [];
    }
  }

  UserProfileModel? findProfileByEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final all = loadAllUserProfiles();
    final idx = all.indexWhere((p) => p.email.toLowerCase() == cleanEmail);
    if (idx >= 0) return all[idx];
    final current = loadUserProfile();
    if (current != null && current.email.toLowerCase() == cleanEmail) return current;
    return null;
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    final raw = jsonEncode(profile.toJson());
    await _prefs?.setString(_keyUserProfile, raw);

    final cleanEmail = profile.email.trim().toLowerCase();
    if (cleanEmail.isNotEmpty) {
      await _prefs?.setString('last_social_email', cleanEmail);
    }

    final all = loadAllUserProfiles();
    final idx = all.indexWhere((p) => p.email.toLowerCase() == profile.email.toLowerCase());
    if (idx >= 0) {
      all[idx] = profile;
    } else {
      all.add(profile);
    }
    await _prefs?.setString('app_all_user_profiles', jsonEncode(all.map((p) => p.toJson()).toList()));
  }

  String? getLastSocialEmail() {
    return _prefs?.getString('last_social_email');
  }

  Future<void> setLastSocialEmail(String email) async {
    final clean = email.trim().toLowerCase();
    if (clean.isNotEmpty) {
      await _prefs?.setString('last_social_email', clean);
    }
  }

  String? getLastAuthPassword() {
    return _prefs?.getString('last_auth_password');
  }

  Future<void> setLastAuthPassword(String password) async {
    if (password.isNotEmpty) {
      await _prefs?.setString('last_auth_password', password);
    }
  }

  Future<void> clearUserProfile() async {
    await _prefs?.remove(_keyUserProfile);
    await _prefs?.remove(_keySchedule);
  }
}
