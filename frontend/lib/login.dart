import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'signup.dart';
import 'dashboard.dart';

// Warna utama
class AppColors {
  static const bg = Color(0xFFEDE9E1);
  static const card = Color(0xFFF7F5F0);
  static const hero = Color(0xFF3D5A52);
  static const accentBg = Color(0xFFD6E5E0);
  static const text1 = Color(0xFF1C201E);
  static const text2 = Color(0xFF4E5552);
  static const text3 = Color(0xFF9AA09C);
  static const border = Color(0x1F3D5A52);
  static const border2 = Color(0x383D5A52);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool _validateEmail(String val) {
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(val.trim());
  }

  bool _validatePassword(String val) {
    return val.length >= 8;
  }

  Future<void> _tryLogin() async {
    setState(() {
      _emailError = _validateEmail(_emailCtrl.text) ? null : 'Masukkan email yang valid';
      _passError = _validatePassword(_passCtrl.text) ? null : 'Password minimal 8 karakter';
    });

    if (_emailError == null && _passError == null) {
      setState(() => _isLoading = true);
      
      try {
        // Alamat localhost untuk Chrome. Jika di emulator Android gunakan 10.0.2.2
        final response = await http.post(
          Uri.parse('http://localhost:3000/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': _emailCtrl.text.trim(),
            'password': _passCtrl.text,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          // Simpan token dan data user ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['access_token']);
          await prefs.setString('user_data', jsonEncode(data['user']));
          
          debugPrint('Login Berhasil: ${data['access_token']}');
          
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        } else {
          final error = jsonDecode(response.body);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['message'] ?? 'Login Gagal')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat terhubung ke server')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _goToDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrand(),
              const SizedBox(height: 40),
              const Text(
                'Selamat datang kembali',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Masuk untuk melanjutkan perjalananmu',
                style: TextStyle(fontSize: 13, color: AppColors.text3, height: 1.5),
              ),
              const SizedBox(height: 28),
              _buildFieldLabel('Email'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _emailCtrl,
                hint: 'contoh@email.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 14),
              _buildFieldLabel('Password'),
              const SizedBox(height: 6),
              _buildPasswordField(),
              if (_passError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _passError!,
                    style: const TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lupa password?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hero,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildPrimaryButton(
                label: 'Masuk', 
                onTap: _isLoading ? () {} : _tryLogin,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 22),
              _buildDivider(),
              const SizedBox(height: 22),
              _buildSocialButton(
                label: 'Lanjutkan dengan Google',
                iconAsset: 'G',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Google Login belum tersedia')),
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildSocialButton(
                label: 'Lanjutkan dengan Facebook',
                iconAsset: 'f',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur Facebook Login belum tersedia')),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ruang Pulih',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                  letterSpacing: -0.8,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tempatmu untuk pulih & bertumbuh',
                style: TextStyle(fontSize: 12, color: AppColors.text3),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Image.asset(
            'img/logo.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image, size: 32, color: Colors.red);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.text2,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: errorText != null ? Colors.red : AppColors.border2,
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: AppColors.text1),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.text3),
              prefixIcon: Icon(icon, size: 18, color: AppColors.text3),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 11, color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _passError != null ? Colors.red : AppColors.border2,
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: _passCtrl,
        obscureText: _obscurePass,
        style: const TextStyle(fontSize: 14, color: AppColors.text1),
        decoration: InputDecoration(
          hintText: 'Masukkan password',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.text3),
          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.text3),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePass = !_obscurePass),
            child: Icon(
              _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18,
              color: AppColors.text3,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label, 
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.hero,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          disabledBackgroundColor: AppColors.hero.withOpacity(0.6),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border2, thickness: 0.5)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('atau lanjutkan dengan', style: TextStyle(fontSize: 12, color: AppColors.text3)),
        ),
        Expanded(child: Divider(color: AppColors.border2, thickness: 0.5)),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required String iconAsset,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.text1,
          side: const BorderSide(color: AppColors.border2, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(iconAsset, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text2)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Belum punya akun? ',
          style: const TextStyle(fontSize: 13, color: AppColors.text3),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                ),
                child: const Text(
                  'Daftar sekarang',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.hero),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}