import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'dashboard.dart';

void main() async {
  // Pastikan Flutter binding sudah diinisialisasi sebelum panggil SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cek apakah ada token yang tersimpan
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');
  
  runApp(RuangPulihApp(isLoggedIn: token != null));
}

class RuangPulihApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const RuangPulihApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RuangPulih',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5A52)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEDE9E1),
      ),
      // Jika sudah login, langsung ke Dashboard. Jika belum, ke Login.
      home: isLoggedIn ? const DashboardPage() : const LoginPage(),
    );
  }
}
