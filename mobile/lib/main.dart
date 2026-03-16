import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'views/screens/dashboard_screen.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/signup_screen.dart';
import 'views/screens/splash_screen.dart';
import 'views/screens/main_container_screen.dart';
import 'controllers/lead_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/nav_controller.dart';

import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await GetStorage.init();
  Get.put(AuthController());
  Get.put(LeadController());
  Get.put(NavController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Leads',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF056E73),
        scaffoldBackgroundColor: Colors.white,
        cardColor: const Color(0xFFF8FAFC),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
          bodyLarge: TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          bodyMedium: TextStyle(fontSize: 12, color: Color(0xFF475569)),
          labelLarge: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF056E73),
          primary: const Color(0xFF056E73),
          secondary: const Color(0xFFB2D430),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/dashboard', page: () => const MainContainerScreen()),
      ],
    );
  }
}
