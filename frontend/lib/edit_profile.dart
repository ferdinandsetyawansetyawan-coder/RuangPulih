import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

// Warna utama (consistent with other pages)
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

class EditProfilePage extends StatefulWidget {
  final VoidCallback onProfileUpdated;
  const EditProfilePage({super.key, required this.onProfileUpdated});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _avatarUrlCtrl = TextEditingController();
  bool _isLoading = false;
  int? _userId;
  String? _token;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _avatarUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    final token = prefs.getString('token');
    
    if (userDataStr != null && token != null) {
      final userData = jsonDecode(userDataStr);
      setState(() {
        _userId = userData['id'];
        _token = token;
        _nameCtrl.text = userData['fullName'] ?? '';
        _avatarUrlCtrl.text = userData['avatarUrl'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka galeri: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_userId == null || _token == null) return;

    setState(() => _isLoading = true);

    try {
      String finalAvatarUrl = _avatarUrlCtrl.text.trim();

      if (_imageFile != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiService.baseUrl}/users/$_userId/avatar'),
        );
        request.files.add(await http.MultipartFile.fromPath('avatar', _imageFile!.path));
        
        final streamedResponse = await request.send();
        if (streamedResponse.statusCode == 201 || streamedResponse.statusCode == 200) {
           final respBody = await streamedResponse.stream.bytesToString();
           final updatedUser = jsonDecode(respBody);
           finalAvatarUrl = updatedUser['avatarUrl'] ?? finalAvatarUrl;
        } else {
           if (!mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Gagal mengunggah foto')),
           );
        }
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/users/$_userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'fullName': _nameCtrl.text.trim(),
          'avatarUrl': finalAvatarUrl,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final updatedUser = jsonDecode(response.body);
        
        // Update SharedPreferences with new user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(updatedUser));
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        
        widget.onProfileUpdated();
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan koneksi')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ImageProvider? _getAvatarImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }
    final url = _avatarUrlCtrl.text;
    if (url.isNotEmpty) {
      if (url.startsWith('http')) {
        return NetworkImage(url);
      } else {
        return NetworkImage('${ApiService.baseUrl}$url');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.hero),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: AppColors.text1, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.hero,
                        backgroundImage: _getAvatarImage(),
                        child: _getAvatarImage() == null
                          ? const Icon(Icons.person_rounded, size: 60, color: Colors.white) 
                          : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.hero,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameCtrl,
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),
              _buildLabel('URL Foto Profil'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _avatarUrlCtrl,
                hint: 'Atau masukkan URL gambar...',
                icon: Icons.link_rounded,
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 10),
              const Text(
                'Anda dapat memilih foto dari galeri dengan mengetuk ikon profil, atau memasukkan URL gambar langsung di sini.',
                style: TextStyle(fontSize: 11, color: AppColors.text3, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.text2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.text1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.text3),
          prefixIcon: Icon(icon, size: 20, color: AppColors.text3),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.hero,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
