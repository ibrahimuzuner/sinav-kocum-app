import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/study_provider.dart';
import 'providers/timer_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main_screen.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter hata yakalama (Bembeyaz ekran donmalarını önler)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    return true; // Hatayı yutarak uygulamanın çökmesini veya donmasını engeller
  };

  // Mobil dikey yönlendirme kilidi
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('Orientations hatası: $e');
  }

  // Yerel depolamayı hızlıca yükle (milisaniyeler içinde tamamlanır)
  final storageService = StorageService();
  try {
    await storageService.init().timeout(const Duration(seconds: 2));
  } catch (e) {
    debugPrint('StorageService init hatası: $e');
  }

  // ARAYÜZÜ ANINDA BAŞLAT! (Kullanıcı asla beyaz ekranda beklemez)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService)),
        ChangeNotifierProvider(create: (_) => StudyProvider(storageService)),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: const SinavTakipApp(),
    ),
  );

  // Arka plan servislerini (Firebase ve Bildirimler) arayüzü engellemeden başlat
  _initServicesAsync();
}

void _initServicesAsync() async {
  // 1. Firebase Başlatma (Güvenli zaman aşımı ile)
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyB0gbVTJWYKLFQBUQWgbalCqg4qV1azOUE',
          appId: '1:104704232110:web:a1abfd662ed07a3a113b3f',
          messagingSenderId: '104704232110',
          projectId: 'sinavkocum-2e212',
          authDomain: 'sinavkocum-2e212.firebaseapp.com',
          storageBucket: 'sinavkocum-2e212.firebasestorage.app',
        ),
      ).timeout(const Duration(seconds: 4));
    } else {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyB0gbVTJWYKLFQBUQWgbalCqg4qV1azOUE',
          appId: '1:104704232110:android:a1abfd662ed07a3a113b3f',
          messagingSenderId: '104704232110',
          projectId: 'sinavkocum-2e212',
          storageBucket: 'sinavkocum-2e212.firebasestorage.app',
        ),
      ).timeout(const Duration(seconds: 4));
    }
    await AppFirebaseService().init().timeout(const Duration(seconds: 4));
  } catch (e) {
    debugPrint('Firebase arka plan başlatma uyarısı: $e');
  }

  // 2. Bildirim Servisi Başlatma
  try {
    final notificationService = NotificationService();
    await notificationService.init().timeout(const Duration(seconds: 4));
  } catch (e) {
    debugPrint('Bildirim servisi başlatma uyarısı: $e');
  }
}

class SinavTakipApp extends StatelessWidget {
  const SinavTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return MaterialApp(
      title: 'Sınav Koçum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: userProvider.isRegistered ? const MainScreen() : const AuthScreen(),
    );
  }
}
