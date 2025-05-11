import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartfeed/const/color.dart';
import 'package:smartfeed/controller/fcm_controller.dart';
import 'package:smartfeed/view/auth/login_view.dart';
import 'firebase_options.dart';
import 'view/main_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FcmController.initialize();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FcmController.requestPermission();

  await FcmController.initialize();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    FcmController.handleNotification(message);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartFeed',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.commonBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.appBarBackground,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.fabBackground,
        ),
      ),
      home: user != null ? const MainView() : LoginView(),
    );
  }
}
