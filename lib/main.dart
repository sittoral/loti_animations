import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'core/di/service_locator.dart';
import 'core/service/firebase_service/push_background_handler.dart';
import 'core/service/firebase_service/push_foreground_service.dart';
import 'features/auth/ui/pages/splash_page.dart';
import 'features/news/ui/bloc/news_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Получаем и выводим FCM токен в консоль для тестов
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('=== FCM TOKEN: $fcmToken ===');
  } catch (e) {
    debugPrint('Error getting FCM token: $e');
  }

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  configureDependencies();

  try {
    final pushForegroundService = sl<PushForegroundService>();
    await pushForegroundService.initialize();
  } catch (e) {
    debugPrint('Error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NewsBloc>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'News App',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorSchemeSeed: Colors.deepPurple,
        ),
        home: const SplashPage(),
      ),
    );
  }
}