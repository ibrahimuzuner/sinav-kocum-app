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

  // Flutter hata yakalama (Gri ekran çıkmasını engeller, okunabilir arayüz sunar)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 64),
                  const SizedBox(height: 16),
                  const Text('Sınav Koçum 🎓', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Uygulama başlatılıyor, lütfen bekleyin...', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 16),
                  Text(details.exceptionAsString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    return true; // Hatayı yutarak uygulamanın çökmesini engeller
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

  // Yerel depolamayı güvenle başlat
  final storageService = StorageService();
  try {
    await storageService.init();
  } catch (e) {
    debugPrint('StorageService init hatası: $e');
  }

  // ARAYÜZÜ BAŞLAT
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

  // Arka plan servislerini arayüzü engellemeden başlat
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

class SinavTakipApp extends StatefulWidget {
  const SinavTakipApp({super.key});

  @override
  State<SinavTakipApp> createState() => _SinavTakipAppState();
}

class _SinavTakipAppState extends State<SinavTakipApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Uygulama ilk açıldığında Android 13+ yerel bildirim izin diyaloğunu tetikle
      await Future.delayed(const Duration(milliseconds: 700));
      await NotificationService().requestPermissions();
    });
  }

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
