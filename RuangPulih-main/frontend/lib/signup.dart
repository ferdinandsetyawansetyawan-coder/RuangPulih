import 'package:flutter/material.dart';
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

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreeToTerms = false;

  String? _nameError;
  String? _emailError;
  String? _passError;
  String? _confirmPassError;
  String? _termsError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  bool _validateEmail(String val) {
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(val.trim());
  }

  bool _validatePassword(String val) => val.length >= 8;
  bool _validateName(String val) => val.trim().length >= 2;

  void _trySignup() {
    setState(() {
      _nameError = _validateName(_nameCtrl.text) ? null : 'Nama minimal 2 karakter';
      _emailError = _validateEmail(_emailCtrl.text) ? null : 'Masukkan email yang valid';
      _passError = _validatePassword(_passCtrl.text) ? null : 'Password minimal 8 karakter';
      _confirmPassError = _passCtrl.text == _confirmPassCtrl.text ? null : 'Password tidak cocok';
      _termsError = _agreeToTerms ? null : 'Kamu harus menyetujui syarat & ketentuan';
    });

    if (_nameError == null &&
        _emailError == null &&
        _passError == null &&
        _confirmPassError == null &&
        _termsError == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
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
                'Buat akun baru',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mulai perjalanan pulih & bertumbuhmu hari ini',
                style: TextStyle(fontSize: 13, color: AppColors.text3, height: 1.5),
              ),
              const SizedBox(height: 28),
              _buildFieldLabel('Nama Lengkap'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _nameCtrl,
                hint: 'Nama lengkapmu',
                icon: Icons.person_outline_rounded,
                errorText: _nameError,
              ),
              const SizedBox(height: 14),
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
              _buildObscureField(
                controller: _passCtrl,
                hint: 'Minimal 8 karakter',
                obscure: _obscurePass,
                onToggle: () => setState(() => _obscurePass = !_obscurePass),
                errorText: _passError,
              ),
              const SizedBox(height: 14),
              _buildFieldLabel('Konfirmasi Password'),
              const SizedBox(height: 6),
              _buildObscureField(
                controller: _confirmPassCtrl,
                hint: 'Ulangi password',
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                errorText: _confirmPassError,
              ),
              const SizedBox(height: 20),
              _buildTermsRow(),
              if (_termsError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _termsError!,
                    style: const TextStyle(fontSize: 11, color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              _buildPrimaryButton(label: 'Daftar Sekarang', onTap: _trySignup),
              const SizedBox(height: 22),
              _buildDivider(),
              const SizedBox(height: 22),
              _buildSocialButton(
                label: 'Lanjutkan dengan Google',
                iconAsset: 'G',
                onTap: _goToDashboard,
              ),
              const SizedBox(height: 10),
              _buildSocialButton(
                label: 'Lanjutkan dengan Facebook',
                iconAsset: 'f',
                onTap: _goToDashboard,
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

  Widget _buildObscureField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
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
            obscureText: obscure,
            style: const TextStyle(fontSize: 14, color: AppColors.text1),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.text3),
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.text3),
              suffixIcon: GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.text3,
                ),
              ),
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

  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _agreeToTerms,
              onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
              activeColor: AppColors.hero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: AppColors.border2, width: 1),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                text: 'Saya menyetujui ',
                style: TextStyle(fontSize: 12, color: AppColors.text3, height: 1.5),
                children: [
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.hero),
                  ),
                  TextSpan(text: ' serta '),
                  TextSpan(
                    text: 'Kebijakan Privasi',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.hero),
                  ),
                  TextSpan(text: ' Ruang Pulih.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.hero,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
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
            Text(iconAsset,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text2)),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text1)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Sudah punya akun? ',
          style: const TextStyle(fontSize: 13, color: AppColors.text3),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Masuk sekarang',
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