import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'core/providers/app_providers.dart';
import 'core/services/database_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize services (comment out if not implemented yet)
  await DatabaseService.initialize();
  await NotificationService.initialize();
  await FirebaseService.initializeMessaging();

  // Request permissions
  await _requestPermissions();

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.location.request();
  // Works only on permission_handler >= 10.2.0
  await Permission.notification.request();
  await Permission.storage.request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers, // ✅ corrected
      child: MaterialApp(
        title: 'Finance Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
