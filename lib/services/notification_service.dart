import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isSupportedPlatform => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (!isSupportedPlatform) {
      debugPrint('Bildirim servisi sadece mobil platformlarda (Android/iOS) aktiftir.');
      return;
    }

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Bildirime tıklandı: ${response.payload}');
        },
      );

      _isInitialized = true;

      // Android bildirim kanallarını kilit ekranı ve yüksek öncelik için önceden oluştur
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          const AndroidNotificationChannel liveChannel = AndroidNotificationChannel(
            'sinav_timer_live_v2',
            'Canlı Sayaç & Kilit Ekranı',
            description: 'Sayaç çalışırken kilit ekranında ve bildirim çubuğunda canlı sayaç gösterir',
            importance: Importance.high,
            playSound: false,
            enableVibration: false,
            showBadge: false,
          );
          const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
            'sinav_timer_alarm_channel_v2',
            'Pomodoro Bitiş Alarmı',
            description: 'Pomodoro seansı bittiğinde sesli ve titreşimli uyarı',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          );
          await androidImplementation.createNotificationChannel(liveChannel);
          await androidImplementation.createNotificationChannel(alarmChannel);
        }
      }

      await requestPermissions();
    } catch (e) {
      debugPrint('Bildirim servisi başlatılamadı: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (!isSupportedPlatform || !_isInitialized) return;

    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
        await androidImplementation?.requestExactAlarmsPermission();
      } else if (Platform.isIOS) {
        final iosImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Bildirim izin talebi hatası: $e');
    }
  }

  /// Canlı ve Sürekli (Ongoing) Sayaç Bildirimi Gösterir
  /// Android'in yerel chronometer özelliğini kullanarak uygulama arka plandayken
  /// bile bildirim çubuğunda saniyeleri canlı olarak sayar.
  Future<void> showLiveTimerNotification({
    required String courseName,
    String? topicName,
    required bool isPomodoro,
    required int whenMillis,
    required bool isPaused,
  }) async {
    if (!isSupportedPlatform || !_isInitialized) return;

    final title = isPomodoro
        ? '⏳ Pomodoro: $courseName'
        : '⏱️ Kronometre: $courseName';

    final body = isPaused
        ? 'Sayaç duraklatıldı. Devam etmek için dokunun.'
        : (topicName != null && topicName.isNotEmpty
            ? '$topicName • Odaklanma devam ediyor'
            : 'Ders çalışma seansı sürüyor • Odaklan');

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sinav_timer_live_v2',
      'Canlı Sayaç & Kilit Ekranı',
      channelDescription: 'Sayaç çalışırken kilit ekranında ve üst bildirim çubuğunda canlı sayaç gösterir',
      importance: Importance.defaultImportance, // Kilit ekranında görünmesi için default önem seviyesi
      priority: Priority.high,
      ongoing: !isPaused, // Çalışırken kullanıcı kazara kaydırıp silemez
      autoCancel: false,
      usesChronometer: !isPaused,
      chronometerCountDown: isPomodoro,
      when: whenMillis,
      showWhen: true,
      onlyAlertOnce: true,
      visibility: NotificationVisibility.public, // Kilit ekranında tam görünürlük (şifreli/kilitli ekranda gizlenmez)
      category: AndroidNotificationCategory.stopwatch, // Android'e bunun bir zaman sayacı olduğunu bildirir
      playSound: false, // Sayarken sürekli ses çıkarmaması için
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      2001, // Timer Bildirim ID'si
      title,
      body,
      details,
    );
  }

  /// Pomodoro bittiğinde telefon kilitliyken veya uygulama kapalıyken alarm çalar
  Future<void> schedulePomodoroCompletionAlert({
    required int durationSeconds,
    required String courseName,
  }) async {
    if (!isSupportedPlatform || !_isInitialized) return;

    // Önceki alarmı temizle
    await _notificationsPlugin.cancel(2002);

    try {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: durationSeconds));

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'sinav_timer_alarm_channel_v2',
        'Pomodoro Bitiş Alarmı',
        channelDescription: 'Pomodoro seansı bittiğinde sesli ve titreşimli uyarı',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        2002, // Alarm Bildirim ID'si
        '⏰ Pomodoro Seansı Tamamlandı!',
        '$courseName çalışması başarıyla bitti. Şimdi dinlenme vakti! ☕',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Pomodoro alarm planlama hatası: $e');
    }
  }

  /// Sayaç bildirimini ve alarmını kapatır
  Future<void> cancelTimerNotification() async {
    if (!isSupportedPlatform || !_isInitialized) return;
    await _notificationsPlugin.cancel(2001);
    await _notificationsPlugin.cancel(2002);
  }

  /// Anında test bildirimi gösterir
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    if (!isSupportedPlatform || !_isInitialized) {
      debugPrint('[TEST BILDIRIM] $title: $body');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sinav_takip_channel',
      'Sınav Hatırlatıcıları',
      channelDescription: 'Ders çalışma ve motivasyon hatırlatıcıları',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }

  /// Her gün belirlenen saatte çalışmadığı takdirde hatırlatacak periyodik alarmı kurar
  Future<void> scheduleDailyInactivityReminder({
    required int hour,
    required int minute,
    required bool isEnabled,
  }) async {
    if (!isSupportedPlatform || !_isInitialized) return;

    // Önceki zamanlanmış hatırlatıcıyı temizle
    await _notificationsPlugin.cancel(1001);

    if (!isEnabled) return;

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Eğer bugünkü saat geçtiyse yarına planla
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'sinav_daily_inactivity_channel',
        'Günlük Çalışma Hatırlatıcısı',
        channelDescription: 'Çalışmadığın günlerde seni uyaracak bildirimler',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        1001,
        '📚 Sınav Çalışma Hatırlatıcısı',
        'Bugün henüz ders çalışmadın! Hedeflerine ulaşmak için biraz soru çözmeye ne dersin? 🔥',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('Günlük bildirim $hour:$minute saatine planlandı.');
    } catch (e) {
      debugPrint('Günlük bildirim planlama hatası: $e');
    }
  }

  /// Tüm zamanlanmış bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    if (!isSupportedPlatform || !_isInitialized) return;
    await _notificationsPlugin.cancelAll();
  }
}
