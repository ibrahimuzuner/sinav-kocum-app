import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../models/question_log_model.dart';
import '../models/study_session_model.dart';
import '../models/schedule_item_model.dart';
import '../models/mock_exam_model.dart';
import '../models/student_study_stats_model.dart';
import '../services/firebase_service.dart';
import '../services/storage_service.dart';
import '../services/smart_scheduler_service.dart';
import '../services/predefined_data.dart';
import '../utils/formatters.dart';

enum StatisticsPeriod { weekly, monthly, allTime }

class StudyProvider with ChangeNotifier {
  final StorageService _storage;
  final Uuid _uuid = const Uuid();

  List<CourseModel> _courses = [];
  List<TopicModel> _topics = [];
  List<QuestionLogModel> _questionLogs = [];
  List<StudySessionModel> _studySessions = [];
  List<ScheduleItemModel> _scheduleItems = [];
  List<MockExamModel> _mockExams = [];
  int _streak = 0;
  String? _lastActiveDateStr;
  String _currentExam = 'Genel Sınav Hazırlığı';

  StudyProvider(this._storage) {
    loadData();
  }

  // Getters
  String get currentExam => _currentExam;

  /// Tüm kayıtlı dersler (arşiv ve tüm loglar için)
  List<CourseModel> get allCourses => _courses;

  /// Öğrencinin seçtiği sınava göre kısıtlanmış aktif dersler
  List<CourseModel> get courses => getCoursesForExam(_currentExam);

  List<TopicModel> get topics => _topics;
  List<QuestionLogModel> get questionLogs => _questionLogs;
  List<StudySessionModel> get studySessions => _studySessions;
  List<ScheduleItemModel> get scheduleItems => _scheduleItems;
  List<MockExamModel> get mockExams {
    final list = List<MockExamModel>.from(_mockExams);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
  int get mockExamCount => _mockExams.length;
  MockExamModel? get latestMockExam {
    if (_mockExams.isEmpty) return null;
    return mockExams.first;
  }
  double get highestMockNet {
    if (_mockExams.isEmpty) return 0.0;
    return _mockExams.map((e) => e.totalNet).reduce((a, b) => a > b ? a : b);
  }
  double get averageMockNet {
    if (_mockExams.isEmpty) return 0.0;
    final total = _mockExams.fold(0.0, (sum, e) => sum + e.totalNet);
    return double.parse((total / _mockExams.length).toStringAsFixed(2));
  }
  Map<String, double> getCourseAverageMockNets() {
    final Map<String, List<double>> courseNets = {};
    for (final exam in _mockExams) {
      for (final score in exam.courseScores) {
        courseNets.putIfAbsent(score.courseName, () => []).add(score.netScore);
      }
    }
    final Map<String, double> averages = {};
    courseNets.forEach((courseName, nets) {
      if (nets.isNotEmpty) {
        final avg = nets.reduce((a, b) => a + b) / nets.length;
        averages[courseName] = double.parse(avg.toStringAsFixed(2));
      }
    });
    return averages;
  }
  int get streak => _streak;

  void setCurrentExam(String exam) {
    if (_currentExam != exam) {
      _currentExam = exam;
      notifyListeners();
    }
  }

  /// Belirtilen sınava ait dersleri döndürür (+ kullanıcının kendi eklediği özel dersler)
  List<CourseModel> getCoursesForExam(String examName) {
    final allowedPredefined = PredefinedData.getCoursesForExam(examName);
    final allowedIds = allowedPredefined.map((c) => c.id).toSet();
    final allPredefinedIds = PredefinedData.getAllAvailableCourses().map((c) => c.id).toSet();

    return _courses.where((c) {
      if (allowedIds.contains(c.id)) return true;
      // Kullanıcının kendi eklediği özel ders ise her zaman dahil et
      if (!allPredefinedIds.contains(c.id)) return true;
      return false;
    }).toList();
  }

  void loadData() {
    _courses = _storage.loadCourses();
    _topics = _storage.loadTopics();
    _questionLogs = _storage.loadQuestionLogs();
    _studySessions = _storage.loadStudySessions();
    _scheduleItems = _storage.loadScheduleItems();
    _mockExams = _storage.loadMockExams();
    _streak = _storage.loadStreak();
    _lastActiveDateStr = _storage.loadLastActiveDate();

    final userProfile = _storage.loadUserProfile();
    if (userProfile != null && userProfile.targetExam.isNotEmpty) {
      _currentExam = userProfile.targetExam;
    }

    // Check streak decay if more than 1 day skipped
    _validateStreak();
    notifyListeners();

    if (userProfile != null && userProfile.isStudent) {
      syncStudyStatsToCloud();
    }
  }

  /// Öğrencinin çalışma istatistik özetini öğretmen takibi için buluta aktarır
  Future<void> syncStudyStatsToCloud() async {
    try {
      final profile = _storage.loadUserProfile();
      if (profile == null || profile.isTeacher) return;

      final totalSessionMins = _studySessions.fold(0, (sum, s) => sum + s.durationMinutes);
      final totalQLogMins = _questionLogs.fold(0, (sum, q) => sum + (q.durationMinutes ?? 0));
      final totalQuestions = _questionLogs.fold(0, (sum, q) => sum + q.totalQuestions);

      final List<String> recent = [];
      for (final q in _questionLogs.take(3)) {
        final topicPart = (q.topicName != null && q.topicName!.isNotEmpty) ? ' (${q.topicName})' : '';
        recent.add('📝 ${q.courseName}$topicPart: ${q.totalQuestions} soru (${q.correctCount}D ${q.wrongCount}Y)');
      }
      for (final s in _studySessions.take(2)) {
        final cname = s.courseName ?? 'Genel Çalışma';
        recent.add('⏱️ $cname: ${s.durationMinutes} dk odak');
      }
      if (latestMockExam != null) {
        recent.add('📊 Deneme (${latestMockExam!.title}): ${latestMockExam!.totalNet.toStringAsFixed(1)} Net');
      }

      final stats = StudentStudyStatsModel(
        todayStudyMinutes: todayStudyMinutes,
        todaySolvedQuestions: todayTotalQuestions,
        todayNetScore: todayNetScore,
        totalStudyMinutes: totalSessionMins + totalQLogMins,
        totalSolvedQuestions: totalQuestions,
        streakDays: _streak,
        mockExamCount: mockExamCount,
        latestMockTitle: latestMockExam?.title,
        latestMockNet: latestMockExam?.totalNet,
        highestMockNet: highestMockNet,
        lastStudiedAt: _lastActiveDateStr != null ? DateTime.tryParse(_lastActiveDateStr!) : null,
        recentActivities: recent,
      );

      await AppFirebaseService().syncStudentStudyStats(profile.id, stats);
    } catch (e) {
      debugPrint('syncStudyStatsToCloud hatası: $e');
    }
  }

  void _validateStreak() {
    if (_lastActiveDateStr == null) return;
    final lastActive = DateTime.tryParse(_lastActiveDateStr!);
    if (lastActive == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(lastActive.year, lastActive.month, lastActive.day);
    final diffDays = today.difference(lastDate).inDays;

    if (diffDays > 1) {
      // More than 1 day missed: streak resets to 0
      _streak = 0;
      _storage.saveStreak(0);
    }
  }

  void _recordActivity() {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (_lastActiveDateStr == null) {
      _streak = 1;
    } else {
      final lastActive = DateTime.tryParse(_lastActiveDateStr!);
      if (lastActive != null) {
        final today = DateTime(now.year, now.month, now.day);
        final lastDate = DateTime(lastActive.year, lastActive.month, lastActive.day);
        final diffDays = today.difference(lastDate).inDays;

        if (diffDays == 1) {
          _streak += 1;
        } else if (diffDays > 1) {
          _streak = 1;
        }
      }
    }

    _lastActiveDateStr = todayStr;
    _storage.saveStreak(_streak);
    _storage.saveLastActiveDate(todayStr);
    syncStudyStatsToCloud();
  }

  // --- STATS GETTERS ---

  /// Bugün ders çalışıldı mı?
  bool get didStudyToday {
    final now = DateTime.now();
    final hasQuestionsToday = _questionLogs.any((q) => Formatters.isSameDay(q.date, now));
    final hasSessionsToday = _studySessions.any((s) => Formatters.isSameDay(s.date, now));
    return hasQuestionsToday || hasSessionsToday;
  }

  /// Bugünkü Soru Çözüm Kayıtları
  List<QuestionLogModel> get todayQuestionLogs {
    final now = DateTime.now();
    return _questionLogs.where((q) => Formatters.isSameDay(q.date, now)).toList();
  }

  /// Bugün çözülen toplam soru
  int get todayTotalQuestions {
    return todayQuestionLogs.fold(0, (sum, item) => sum + item.totalQuestions);
  }

  /// Bugün çözülen toplam doğru
  int get todayCorrectCount {
    return todayQuestionLogs.fold(0, (sum, item) => sum + item.correctCount);
  }

  /// Bugün çözülen toplam yanlış
  int get todayWrongCount {
    return todayQuestionLogs.fold(0, (sum, item) => sum + item.wrongCount);
  }

  /// Bugün çözülen toplam boş
  int get todayEmptyCount {
    return todayQuestionLogs.fold(0, (sum, item) => sum + item.emptyCount);
  }

  /// Bugün kazanılan net toplamı
  double get todayNetScore {
    final net = todayQuestionLogs.fold(0.0, (sum, item) => sum + item.netScore);
    return double.parse(net.toStringAsFixed(2));
  }

  /// Bugün çalışılan toplam dakika (Sayaç seansları + soru çözme süreleri)
  int get todayStudyMinutes {
    final now = DateTime.now();
    final sessionMinutes = _studySessions
        .where((s) => Formatters.isSameDay(s.date, now))
        .fold(0, (sum, item) => sum + item.durationMinutes);

    final questionMinutes = todayQuestionLogs.fold(0, (sum, item) => sum + (item.durationMinutes ?? 0));
    return sessionMinutes + questionMinutes;
  }

  /// Son 7 günün soru sayıları [Pzt, Sal ... Paz]
  List<int> getWeeklyQuestionsData() {
    final now = DateTime.now();
    final result = List<int>.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final logsForDay = _questionLogs.where((q) => Formatters.isSameDay(q.date, day));
      result[i] = logsForDay.fold(0, (sum, item) => sum + item.totalQuestions);
    }
    return result;
  }

  /// Son 7 günün çalışma süreleri (dakika cinsinden)
  List<int> getWeeklyMinutesData() {
    final now = DateTime.now();
    final result = List<int>.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final sessionsForDay = _studySessions.where((s) => Formatters.isSameDay(s.date, day));
      final minutes = sessionsForDay.fold(0, (sum, item) => sum + item.durationMinutes);
      result[i] = minutes;
    }
    return result;
  }

  /// Belirli bir periyottaki soru kayıtları (Haftalık / Aylık / Tüm Zamanlar)
  List<QuestionLogModel> getQuestionLogsForPeriod(StatisticsPeriod period) {
    if (period == StatisticsPeriod.allTime) return _questionLogs;
    final now = DateTime.now();
    final days = period == StatisticsPeriod.weekly ? 7 : 30;
    final cutoff = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    return _questionLogs.where((q) {
      final qDay = DateTime(q.date.year, q.date.month, q.date.day);
      return qDay.isAtSameMomentAs(cutoff) || qDay.isAfter(cutoff);
    }).toList();
  }

  /// Belirli bir periyottaki çalışma seansları (Haftalık / Aylık / Tüm Zamanlar)
  List<StudySessionModel> getStudySessionsForPeriod(StatisticsPeriod period) {
    if (period == StatisticsPeriod.allTime) return _studySessions;
    final now = DateTime.now();
    final days = period == StatisticsPeriod.weekly ? 7 : 30;
    final cutoff = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    return _studySessions.where((s) {
      final sDay = DateTime(s.date.year, s.date.month, s.date.day);
      return sDay.isAtSameMomentAs(cutoff) || sDay.isAfter(cutoff);
    }).toList();
  }

  /// Son 4 haftanın soru sayıları (Aylık grafik için: [1. Hafta, 2. Hafta, 3. Hafta, 4. Hafta])
  List<int> getMonthlyQuestionsByWeek() {
    final now = DateTime.now();
    final result = List<int>.filled(4, 0);

    for (int w = 0; w < 4; w++) {
      final startDaysAgo = (3 - w) * 7 + 7;
      final endDaysAgo = (3 - w) * 7;
      final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: startDaysAgo - 1));
      final end = DateTime(now.year, now.month, now.day).subtract(Duration(days: endDaysAgo));

      final logs = _questionLogs.where((q) {
        final d = DateTime(q.date.year, q.date.month, q.date.day);
        return (d.isAtSameMomentAs(start) || d.isAfter(start)) && (d.isAtSameMomentAs(end) || d.isBefore(end));
      });
      result[w] = logs.fold(0, (sum, item) => sum + item.totalQuestions);
    }
    return result;
  }

  /// Son 4 haftanın çalışma süreleri (Aylık grafik için)
  List<int> getMonthlyMinutesByWeek() {
    final now = DateTime.now();
    final result = List<int>.filled(4, 0);

    for (int w = 0; w < 4; w++) {
      final startDaysAgo = (3 - w) * 7 + 7;
      final endDaysAgo = (3 - w) * 7;
      final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: startDaysAgo - 1));
      final end = DateTime(now.year, now.month, now.day).subtract(Duration(days: endDaysAgo));

      final sessions = _studySessions.where((s) {
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        return (d.isAtSameMomentAs(start) || d.isAfter(start)) && (d.isAtSameMomentAs(end) || d.isBefore(end));
      });
      result[w] = sessions.fold(0, (sum, item) => sum + item.durationMinutes);
    }
    return result;
  }

  // --- CRUD: DERSLER ---
  Future<void> addCourse(String name, int colorValue, {String iconName = 'book', int targetDaily = 30}) async {
    final newCourse = CourseModel(
      id: _uuid.v4(),
      name: name,
      colorValue: colorValue,
      iconName: iconName,
      targetDailyQuestions: targetDaily,
    );
    _courses.add(newCourse);
    await _storage.saveCourses(_courses);
    notifyListeners();
  }

  Future<void> updateCourse(CourseModel updated) async {
    final index = _courses.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _courses[index] = updated;
      await _storage.saveCourses(_courses);
      notifyListeners();
    }
  }

  Future<void> deleteCourse(String courseId) async {
    _courses.removeWhere((c) => c.id == courseId);
    _topics.removeWhere((t) => t.courseId == courseId);
    await _storage.saveCourses(_courses);
    await _storage.saveTopics(_topics);
    notifyListeners();
  }

  // --- CRUD: KONULAR ---
  List<TopicModel> getTopicsForCourse(String courseId) {
    return _topics.where((t) => t.courseId == courseId).toList();
  }

  Future<void> addTopic(String courseId, String topicName) async {
    final newTopic = TopicModel(
      id: _uuid.v4(),
      courseId: courseId,
      name: topicName,
    );
    _topics.add(newTopic);
    await _storage.saveTopics(_topics);
    notifyListeners();
  }

  Future<void> toggleTopicCompleted(String topicId) async {
    final index = _topics.indexWhere((t) => t.id == topicId);
    if (index != -1) {
      _topics[index] = _topics[index].copyWith(isCompleted: !_topics[index].isCompleted);
      await _storage.saveTopics(_topics);
      notifyListeners();
    }
  }

  Future<void> deleteTopic(String topicId) async {
    _topics.removeWhere((t) => t.id == topicId);
    await _storage.saveTopics(_topics);
    notifyListeners();
  }

  // --- CRUD: SORU KAYITLARI ---
  Future<void> addQuestionLog({
    required String courseId,
    required String courseName,
    String? topicId,
    String? topicName,
    required int correct,
    required int wrong,
    int empty = 0,
    DateTime? date,
    int? durationMinutes,
    String? notes,
  }) async {
    final newLog = QuestionLogModel(
      id: _uuid.v4(),
      courseId: courseId,
      courseName: courseName,
      topicId: topicId,
      topicName: topicName,
      correctCount: correct,
      wrongCount: wrong,
      emptyCount: empty,
      date: date ?? DateTime.now(),
      durationMinutes: durationMinutes,
      notes: notes,
    );

    _questionLogs.insert(0, newLog);
    _recordActivity();
    await _storage.saveQuestionLogs(_questionLogs);
    notifyListeners();
  }

  Future<void> deleteQuestionLog(String id) async {
    _questionLogs.removeWhere((q) => q.id == id);
    await _storage.saveQuestionLogs(_questionLogs);
    notifyListeners();
  }

  // --- CRUD: ÇALIŞMA SEANSLARI (SAYAÇ) ---
  Future<void> addStudySession({
    String? courseId,
    String? courseName,
    String? topicName,
    required int durationSeconds,
    String mode = 'stopwatch',
    String? notes,
  }) async {
    if (durationSeconds < 10) return; // 10 saniyeden kısa kayıtları dikkate alma

    final newSession = StudySessionModel(
      id: _uuid.v4(),
      courseId: courseId,
      courseName: courseName,
      topicName: topicName,
      durationSeconds: durationSeconds,
      date: DateTime.now(),
      mode: mode,
      notes: notes,
    );

    _studySessions.insert(0, newSession);
    _recordActivity();
    await _storage.saveStudySessions(_studySessions);
    notifyListeners();
  }

  Future<void> deleteStudySession(String id) async {
    _studySessions.removeWhere((s) => s.id == id);
    await _storage.saveStudySessions(_studySessions);
    notifyListeners();
  }

  // --- CRUD: PROGRAM MADDELERİ ---
  List<ScheduleItemModel> getScheduleForDay(int dayOfWeek) {
    return _scheduleItems.where((i) => i.dayOfWeek == dayOfWeek).toList();
  }

  Future<void> addScheduleItem({
    required int dayOfWeek,
    required String courseId,
    required String courseName,
    required String topicName,
    required int targetMinutes,
    required int targetQuestions,
  }) async {
    final item = ScheduleItemModel(
      id: _uuid.v4(),
      dayOfWeek: dayOfWeek,
      courseId: courseId,
      courseName: courseName,
      topicName: topicName,
      targetMinutes: targetMinutes,
      targetQuestions: targetQuestions,
    );
    _scheduleItems.add(item);
    await _storage.saveScheduleItems(_scheduleItems);
    notifyListeners();
  }

  Future<void> toggleScheduleCompleted(String id) async {
    final index = _scheduleItems.indexWhere((i) => i.id == id);
    if (index != -1) {
      final current = _scheduleItems[index];
      final isNowCompleted = !current.isCompleted;
      _scheduleItems[index] = current.copyWith(
        isCompleted: isNowCompleted,
        completedDate: isNowCompleted ? DateTime.now() : null,
      );
      if (isNowCompleted) {
        _recordActivity();
      }
      await _storage.saveScheduleItems(_scheduleItems);
      notifyListeners();
    }
  }

  Future<void> deleteScheduleItem(String id) async {
    _scheduleItems.removeWhere((i) => i.id == id);
    await _storage.saveScheduleItems(_scheduleItems);
    notifyListeners();
  }

  /// Akıllı çalışma programı oluştur ve uygula
  Future<int> applySmartSchedule({
    required int dailyMinutes,
    required ScheduleStrategy strategy,
    required bool includeSunday,
    String targetExam = 'YKS (Sayısal)',
    String? targetDepartment,
    double? targetScore,
    double? targetNet,
    StudyContentMode contentMode = StudyContentMode.hybrid,
    bool replaceExisting = true,
    Set<String> excludedCourseIds = const {},
  }) async {
    final userProfile = _storage.loadUserProfile();
    final dep = targetDepartment ?? userProfile?.targetDepartment ?? 'Genel Başarı Hedefi';
    final score = targetScore ?? userProfile?.targetScore ?? 450.0;
    final net = targetNet ?? userProfile?.targetNet ?? 80.0;

    final generated = SmartSchedulerService.generateSchedule(
      courses: getCoursesForExam(targetExam),
      questionLogs: _questionLogs,
      dailyMinutes: dailyMinutes,
      strategy: strategy,
      includeSunday: includeSunday,
      targetExam: targetExam,
      targetDepartment: dep,
      targetScore: score,
      targetNet: net,
      contentMode: contentMode,
      excludedCourseIds: excludedCourseIds,
    );

    if (replaceExisting) {
      _scheduleItems = generated;
    } else {
      _scheduleItems.addAll(generated);
    }

    await _storage.saveScheduleItems(_scheduleItems);
    notifyListeners();
    return generated.length;
  }

  // --- CRUD: DENEME SINAVLARI ---
  Future<void> addMockExam(MockExamModel exam) async {
    _mockExams.add(exam);
    _recordActivity();
    await _storage.saveMockExams(_mockExams);
    notifyListeners();
  }

  Future<void> updateMockExam(MockExamModel updated) async {
    final idx = _mockExams.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _mockExams[idx] = updated;
      await _storage.saveMockExams(_mockExams);
      notifyListeners();
    }
  }

  Future<void> deleteMockExam(String id) async {
    _mockExams.removeWhere((e) => e.id == id);
    await _storage.saveMockExams(_mockExams);
    notifyListeners();
  }
}
