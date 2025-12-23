import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/home/main_home.dart';
import 'package:flutter/services.dart';
import 'features/auth/register_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // makes it transparent
      statusBarIconBrightness: Brightness.light, // white icons
      statusBarBrightness: Brightness.dark, // for iOS
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DateJar',
      debugShowCheckedModeBanner: false,

      // Start from splash screen
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainHomeScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
