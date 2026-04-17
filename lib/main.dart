import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'daftar_pengaduan_screen.dart';
import 'tentang_screen.dart';
import 'cara_melapor_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Lapor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF89CFF0),
          primary: const Color(0xFF89CFF0),
        ),
        fontFamily: 'Plus Jakarta Sans', // Ensure this font is added in your pubspec.yaml if needed
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/daftar-pengaduan': (context) => const DaftarPengaduanScreen(),
        '/tentang': (context) => const TentangScreen(),
        '/cara-melapor': (context) => const CaraMelaporScreen(),
        '/dashboard/admin': (context) => const AdminDashboardScreen(),
        '/dashboard/admin/users': (context) => const AdminUsersScreen(),
      },
    );
  }
}
