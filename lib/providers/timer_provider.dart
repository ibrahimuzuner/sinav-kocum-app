import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/topic_model.dart';
import '../services/notification_service.dart';

enum TimerMode { stopwatch, pomodoro }
enum TimerStatus { initial, running, paused }
enum PomodoroPhase { study, rest }

class TimerProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  TimerMode _mode = TimerMode.stopwatch;
  TimerStatus _status = TimerStatus.initial;
  PomodoroPhase _pomodoroPhase = PomodoroPhase.study;

  Timer? _timer;
  int _secondsElapsed = 0; // Kronometrede artan saniye
  int _pomodoroSecondsRemaining = 25 * 60; // 25 dakika varsayılan

  int _pomodoroStudyMinutes = 25;
  int _pomodoroRestMinutes = 5;

  CourseModel? _selectedCourse;
  TopicModel? _selectedTopic;

  // Gerçek zamanlı senkronizasyon damgaları (Arka plan doğruluğu için)
  DateTime? _startTimestamp;
  DateTime? _targetPomodoroEndTime;

  // Getters
  TimerMode get mode => _mode;
  TimerStatus get status => _status;
  PomodoroPhase get pomodoroPhase => _pomodoroPhase;
  int get secondsElapsed => _secondsElapsed;
  int get pomodoroSecondsRemaining => _pomodoroSecondsRemaining;
  int get pomodoroStudyMinutes => _pomodoroStudyMinutes;
  int get pomodoroRestMinutes => _pomodoroRestMinutes;
  CourseModel? get selectedCourse => _selectedCourse;
  TopicModel? get selectedTopic => _selectedTopic;

  bool get isRunning => _status == TimerStatus.running;
  bool get isPaused => _status == TimerStatus.paused;
  bool get isInitial => _status == TimerStatus.initial;

  String get _currentCourseName => _selectedCourse?.name ?? 'Genel Çalışma';

  void setMode(TimerMode newMode) {
    if (_status == TimerStatus.running) return;
    _mode = newMode;
    reset();
    notifyListeners();
  }

  void setSelectedCourse(CourseModel? course) {
    _selectedCourse = course;
    _selectedTopic = null;
    notifyListeners();
  }

  void setSelectedTopic(TopicModel? topic) {
    _selectedTopic = topic;
    notifyListeners();
  }

  void setPomodoroDurations({required int studyMinutes, required int restMinutes}) {
    if (_status == TimerStatus.running) return;
    _pomodoroStudyMinutes = studyMinutes;
    _pomodoroRestMinutes = restMinutes;
    if (_mode == TimerMode.pomodoro && _status == TimerStatus.initial) {
      _pomodoroSecondsRemaining = _pomodoroPhase == PomodoroPhase.study
          ? _pomodoroStudyMinutes * 60
          : _pomodoroRestMinutes * 60;
    }
    notifyListeners();
  }

  void start() {
    if (_status == TimerStatus.running) return;

    _status = TimerStatus.running;
    final now = DateTime.now();

    if (_mode == TimerMode.stopwatch) {
      // Kronometre başlangıç anını belirle
      _startTimestamp = now.subtract(Duration(seconds: _secondsElapsed));

      // Üst bildirim çubuğunda canlı sayacı başlat
      _notificationService.showLiveTimerNotification(
        courseName: _currentCourseName,
        topicName: _selectedTopic?.name,
        isPomodoro: false,
        whenMillis: _startTimestamp!.millisecondsSinceEpoch,
        isPaused: false,
      );
    } else {
      // Pomodoro hedef bitiş anını belirle
      _targetPomodoroEndTime = now.add(Duration(seconds: _pomodoroSecondsRemaining));

      // Üst bildirim çubuğunda canlı geri sayımı başlat
      _notificationService.showLiveTimerNotification(
        courseName: _currentCourseName,
        topicName: _selectedTopic?.name,
        isPomodoro: true,
        whenMillis: _targetPomodoroEndTime!.millisecondsSinceEpoch,
        isPaused: false,
      );

      // Pomodoro bittiğinde telefon kilitliyken veya uygulama kapalıyken alarm kur
      _notificationService.schedulePomodoroCompletionAlert(
        durationSeconds: _pomodoroSecondsRemaining,
        courseName: _currentCourseName,
      );
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mode == TimerMode.stopwatch) {
        _secondsElapsed++;
      } else {
        if (_pomodoroSecondsRemaining > 0) {
          _pomodoroSecondsRemaining--;
          _secondsElapsed++;
        } else {
          // Pomodoro faz değişimi (Çalışma -> Dinlenme veya Dinlenme -> Çalışma)
          _timer?.cancel();
          _status = TimerStatus.paused;
          if (_pomodoroPhase == PomodoroPhase.study) {
            _pomodoroPhase = PomodoroPhase.rest;
            _pomodoroSecondsRemaining = _pomodoroRestMinutes * 60;
          } else {
            _pomodoroPhase = PomodoroPhase.study;
            _pomodoroSecondsRemaining = _pomodoroStudyMinutes * 60;
          }
          _notificationService.cancelTimerNotification();
        }
      }
      notifyListeners();
    });

    notifyListeners();
  }

  void pause() {
    if (_status != TimerStatus.running) return;
    _timer?.cancel();
    _status = TimerStatus.paused;

    // Bildirimi duraklatıldı olarak güncelle
    _notificationService.showLiveTimerNotification(
      courseName: _currentCourseName,
      topicName: _selectedTopic?.name,
      isPomodoro: _mode == TimerMode.pomodoro,
      whenMillis: DateTime.now().millisecondsSinceEpoch,
      isPaused: true,
    );

    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _status = TimerStatus.initial;
    _secondsElapsed = 0;
    _pomodoroPhase = PomodoroPhase.study;
    _pomodoroSecondsRemaining = _pomodoroStudyMinutes * 60;
    _startTimestamp = null;
    _targetPomodoroEndTime = null;

    _notificationService.cancelTimerNotification();
    notifyListeners();
  }

  /// Uygulama arka plandan geri döndüğünde veya ekran açıldığında
  /// gerçek saat ile sayacı kusursuz senkronize eder.
  void syncTimeWithClock() {
    if (_status != TimerStatus.running) return;

    final now = DateTime.now();

    if (_mode == TimerMode.stopwatch && _startTimestamp != null) {
      _secondsElapsed = now.difference(_startTimestamp!).inSeconds;
      notifyListeners();
    } else if (_mode == TimerMode.pomodoro && _targetPomodoroEndTime != null) {
      final remaining = _targetPomodoroEndTime!.difference(now).inSeconds;
      if (remaining > 0) {
        _pomodoroSecondsRemaining = remaining;
      } else {
        _pomodoroSecondsRemaining = 0;
        pause();
      }
      notifyListeners();
    }
  }

  /// Timer'ı durdurup toplam çalışılan süreyi döndürür ve timer'ı sıfırlar
  int finishAndGetSessionSeconds() {
    final totalStudySeconds = _secondsElapsed;
    reset();
    return totalStudySeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationService.cancelTimerNotification();
    super.dispose();
  }
}
