import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      title: 'AI Lead CRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF0EA5E9),
          surface: Color(0xFF1E293B),
        ),
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/signup', page: () => const SignupScreen()),
        GetPage(name: '/dashboard', page: () => const MainContainerScreen()),
      ],
    );
  }
}
