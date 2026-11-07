import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notificationService = NotificationService();

  late bool _isDarkMode;
  late int _targetQuestions;
  late int _targetMinutes;
  late bool _notificationsEnabled;
  late int _reminderHour;
  late int _reminderMinute;

  SettingsProvider(this._storage) {
    _isDarkMode = _storage.loadIsDarkMode();
    _targetQuestions = _storage.loadTargetQuestions();
    _targetMinutes = _storage.loadTargetMinutes();
    _notificationsEnabled = _storage.loadNotificationsEnabled();
    _reminderHour = _storage.loadReminderHour();
    _reminderMinute = _storage.loadReminderMinute();

    _updateNotificationSchedule();
  }

  bool get isDarkMode => _isDarkMode;
  int get targetQuestions => _targetQuestions;
  int get targetMinutes => _targetMinutes;
  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  TimeOfDay get reminderTime => TimeOfDay(hour: _reminderHour, minute: _reminderMinute);

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _storage.saveIsDarkMode(_isDarkMode);
  }

  Future<void> setTargetQuestions(int value) async {
    _targetQuestions = value;
    notifyListeners();
    await _storage.saveTargetQuestions(value);
  }

  Future<void> setTargetMinutes(int value) async {
    _targetMinutes = value;
    notifyListeners();
    await _storage.saveTargetMinutes(value);
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    await _storage.saveNotificationsEnabled(enabled);
    await _updateNotificationSchedule();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderHour = time.hour;
    _reminderMinute = time.minute;
    notifyListeners();
    await _storage.saveReminderHour(_reminderHour);
    await _storage.saveReminderMinute(_reminderMinute);
    await _updateNotificationSchedule();
  }

  Future<void> testNotification() async {
    await _notificationService.showInstantNotification(
      title: '🎯 Sınav Çalışma Bildirimi',
      body: 'Harika gidiyorsun! Bildirim sistemi başarıyla çalışıyor.',
    );
  }

  Future<void> _updateNotificationSchedule() async {
    await _notificationService.scheduleDailyInactivityReminder(
      hour: _reminderHour,
      minute: _reminderMinute,
      isEnabled: _notificationsEnabled,
    );
  }
}
