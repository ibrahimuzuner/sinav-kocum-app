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

  // Set preferred orientations for smooth mobile experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase safely (offline graceful fallback)
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
      );
    } else {
      await Firebase.initializeApp();
    }
    await AppFirebaseService().init();
  } catch (e) {
    debugPrint('Firebase başlatma uyarısı: $e');
  }

  // Initialize Storage
  final storageService = StorageService();
  await storageService.init();

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.init();

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
}

class SinavTakipApp extends StatelessWidget {
  const SinavTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return MaterialApp(
      title: 'Sınav Çalışma Takip',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: userProvider.isRegistered ? const MainScreen() : const AuthScreen(),
    );
  }
}
