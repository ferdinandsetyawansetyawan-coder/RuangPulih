import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'forum.dart';
import 'login.dart';

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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  int? _selectedMood;
  String _userName = 'User';
  String _userEmail = '';
  int? _userId;
  String? _token;

  // --- DATA STATIS ---
  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.favorite_border_rounded, label: 'Sesi'),
    _NavItem(icon: Icons.forum_outlined, label: 'Forum'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Aktifitas'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  static const _moods = [
    _MoodOption(emoji: '😢', label: 'Sedih'),
    _MoodOption(emoji: '😰', label: 'Cemas'),
    _MoodOption(emoji: '😐', label: 'Biasa'),
    _MoodOption(emoji: '😊', label: 'Baik'),
    _MoodOption(emoji: '😁', label: 'Bahagia'),
  ];

  static const _layanan = [
    _LayananItem(icon: Icons.chat_bubble_outline_rounded, label: 'Curhat Bebas', sub: 'Ceritakan apa saja'),
    _LayananItem(icon: Icons.edit_note_rounded, label: 'Jurnal Harian', sub: 'Tulis perasaan'),
    _LayananItem(icon: Icons.people_outline_rounded, label: 'Forum Anonim', sub: 'Tanpa identitas'),
    _LayananItem(icon: Icons.mood_rounded, label: 'Mood Track', sub: 'Pantau emosi'),
  ];

  static const _forumPosts = [
    _ForumPost(
      text: '"Hari ini aku ngerasa overwhelmed banget sama kerjaan..."',
      likes: 42,
      comments: 8,
      timeAgo: '2 jm',
    ),
    _ForumPost(
      text: '"Gapapa nangis, itu bukan kelemahan, itu keberanian."',
      likes: 125,
      comments: 23,
      timeAgo: '5 jm',
    ),
    _ForumPost(
      text: '"Tips buat anxiety saat presentasi? Butuh saran..."',
      likes: 19,
      comments: 31,
      timeAgo: '1 hr',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    final token = prefs.getString('token');
    
    if (userDataStr != null && token != null) {
      final userData = jsonDecode(userDataStr);
      setState(() {
        _userName = userData['fullName'] ?? 'User';
        _userEmail = userData['email'] ?? '';
        _userId = userData['id'];
        _token = token;
      });
      _loadLatestMood();
    }
  }

  Future<void> _loadLatestMood() async {
    if (_userId == null || _token == null) return;
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/moods/latest/$_userId'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data != null) {
          setState(() {
            _selectedMood = _moods.indexWhere((m) => m.label == data['label']);
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal memuat mood: $e');
    }
  }

  Future<void> _saveMood(int index) async {
    if (_userId == null || _token == null) return;
    final mood = _moods[index];
    setState(() => _selectedMood = index);

    try {
      await http.post(
        Uri.parse('http://localhost:3000/moods'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'userId': _userId,
          'label': mood.label,
          'emoji': mood.emoji,
        }),
      );
    } catch (e) {
      debugPrint('Gagal menyimpan mood: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi,';
    if (hour < 15) return 'Selamat siang,';
    if (hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
    
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedIndex) {
      case 0: return _buildBerandaTab();
      case 1: return _buildPlaceholderTab('Sesi Konsultasi');
      case 2: return const ForumPage();
      case 3: return _buildPlaceholderTab('Aktifitas Kamu');
      case 4: return _buildProfilTab();
      default: return _buildBerandaTab();
    }
  }

  Widget _buildBerandaTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: _buildHeader(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
            child: _buildMoodPicker(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: _buildHeroBanner(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: _buildChatKonsultasi(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: _buildSectionHeader('Layanan lainnya', showLihatSemua: false),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: _buildLayananGrid(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: _buildSectionHeader('Forum Anonim', onLihatSemua: () => setState(() => _selectedIndex = 2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: _buildForumCard(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: _buildSectionHeader('Artikel untukmu'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            child: _buildArtikelList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilTab() {
    return Padding(
      padding: const EdgeInsets.all(26),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.hero,
            child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text1)),
          Text(_userEmail, style: const TextStyle(fontSize: 14, color: AppColors.text3)),
          const SizedBox(height: 40),
          _buildMenuTile(Icons.history_rounded, 'Riwayat Konsultasi'),
          _buildMenuTile(Icons.settings_outlined, 'Pengaturan Akun'),
          _buildMenuTile(Icons.help_outline_rounded, 'Pusat Bantuan'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text('Keluar Aplikasi', style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.hero),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.text3),
        onTap: () {},
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 64, color: AppColors.hero.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text2)),
          const Text('Fitur ini sedang dalam pengembangan', style: TextStyle(color: AppColors.text3)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGreeting(), style: const TextStyle(fontSize: 13, color: AppColors.text3)),
            const SizedBox(height: 2),
            Text('Halo, $_userName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text1, letterSpacing: -0.5)),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(color: AppColors.accentBg, shape: BoxShape.circle),
          child: const Icon(Icons.notifications_none_rounded, color: AppColors.hero, size: 24),
        ),
      ],
    );
  }

  Widget _buildMoodPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border2, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bagaimana perasaanmu saat ini?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_moods.length, (i) {
              final m = _moods[i];
              final isSelected = _selectedMood == i;
              return GestureDetector(
                onTap: () => _saveMood(i),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected ? Border.all(color: AppColors.hero, width: 1.5) : null,
                      ),
                      child: Center(child: Text(m.emoji, style: TextStyle(fontSize: isSelected ? 26 : 22))),
                    ),
                    const SizedBox(height: 5),
                    Text(m.label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, color: isSelected ? AppColors.hero : AppColors.text3)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2E4A42), Color(0xFF4E7A6E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MAU CERITA SESUATU?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xAAFFFFFF), letterSpacing: 1.2)),
          const SizedBox(height: 8),
          const Text('Mulai curhat\nsekarang', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2, letterSpacing: -0.5)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.4), width: 1)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Mulai sesi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)), SizedBox(width: 6), Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white)]),
          ),
        ],
      ),
    );
  }

  Widget _buildChatKonsultasi() {
    return Row(
      children: [
        Expanded(child: _buildKonsulCard(Icons.auto_awesome_rounded, 'Chat AI', 'Siap mendengar 24 jam', AppColors.accentBg, AppColors.hero)),
        const SizedBox(width: 12),
        Expanded(child: _buildKonsulCard(Icons.medical_services_outlined, 'Chat Dokter', 'Konsultasi profesional', const Color(0xFFEAE4F5), const Color(0xFF7B5EA7))),
      ],
    );
  }

  Widget _buildKonsulCard(IconData icon, String title, String sub, Color bg, Color tint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: tint.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: tint)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text1)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.text2)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showLihatSemua = true, VoidCallback? onLihatSemua}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text1)),
        if (showLihatSemua) GestureDetector(onTap: onLihatSemua, child: const Text('Lihat semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.hero))),
      ],
    );
  }

  Widget _buildLayananGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6),
      itemCount: _layanan.length,
      itemBuilder: (context, i) {
        final item = _layanan[i];
        return GestureDetector(
          onTap: i == 2 ? () => setState(() => _selectedIndex = 2) : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border2, width: 0.5)),
            child: Row(
              children: [
                Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(11)), child: Icon(item.icon, size: 20, color: AppColors.hero)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(item.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)), const SizedBox(height: 2), Text(item.sub, style: const TextStyle(fontSize: 11, color: AppColors.text3), maxLines: 1, overflow: TextOverflow.ellipsis)])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForumCard() {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border2, width: 0.5)),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedIndex = 2),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.forum_rounded, size: 18, color: AppColors.hero)),
                  const SizedBox(width: 10),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Ruang Cerita', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text1)), Text('Berbagi tanpa nama', style: TextStyle(fontSize: 11, color: AppColors.text3))]),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.circle, size: 6, color: Color(0xFF4CAF50)), SizedBox(width: 4), Text('247 online', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.hero))])),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border2),
          ..._forumPosts.asMap().entries.map((e) {
            final i = e.key;
            final post = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.accentBg, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, size: 16, color: AppColors.hero)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(post.text, style: const TextStyle(fontSize: 12, color: AppColors.text2, height: 1.5)),
                          const SizedBox(height: 6),
                          Row(children: [const Icon(Icons.favorite_border_rounded, size: 12, color: AppColors.text3), const SizedBox(width: 3), Text('${post.likes}', style: const TextStyle(fontSize: 11, color: AppColors.text3)), const SizedBox(width: 10), const Icon(Icons.chat_bubble_outline_rounded, size: 12, color: AppColors.text3), const SizedBox(width: 3), Text('${post.comments} balasan', style: const TextStyle(fontSize: 11, color: AppColors.text3)), const Spacer(), Text(post.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.text3))]),
                        ]),
                      ),
                    ],
                  ),
                ),
                if (i < _forumPosts.length - 1) const Divider(height: 1, indent: 14, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildArtikelList() {
    final articles = [
      _ArtikelData(category: 'Kesehatan Mental', title: '5 cara mengelola stres sehari-hari', readTime: '3 menit baca', timeAgo: 'Kemarin', categoryColor: const Color(0xFF2E7D32), categoryBg: const Color(0xFFE8F5E9)),
      _ArtikelData(category: 'Mindfulness', title: 'Melatih pikiran tenang dengan journaling', readTime: '3 menit baca', timeAgo: '2 hari lalu', categoryColor: const Color(0xFF7B5EA7), categoryBg: const Color(0xFFEAE4F5)),
    ];

    return Column(
      children: articles.map((a) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border2, width: 0.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 100, width: double.infinity, decoration: const BoxDecoration(color: AppColors.accentBg, borderRadius: BorderRadius.vertical(top: Radius.circular(16))), child: const Center(child: Icon(Icons.image_outlined, size: 32, color: AppColors.hero))),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: a.categoryBg, borderRadius: BorderRadius.circular(20)), child: Text(a.category.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: a.categoryColor, letterSpacing: 0.6))),
                      const SizedBox(height: 8),
                      Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text1, height: 1.4)),
                      const SizedBox(height: 6),
                      Row(children: [Text(a.readTime, style: const TextStyle(fontSize: 11, color: AppColors.text3)), const Text(' · ', style: TextStyle(color: AppColors.text3)), Text(a.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.text3))]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 68,
      decoration: const BoxDecoration(color: AppColors.card, border: Border(top: BorderSide(color: AppColors.border2, width: 0.5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (i) {
          final item = _navItems[i];
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 22, color: isSelected ? AppColors.hero : AppColors.text3),
                const SizedBox(height: 4),
                Text(item.label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.hero : AppColors.text3)),
                const SizedBox(height: 2),
                if (isSelected) Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.hero, shape: BoxShape.circle)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _MoodOption {
  final String emoji;
  final String label;
  const _MoodOption({required this.emoji, required this.label});
}

class _LayananItem {
  final IconData icon;
  final String label;
  final String sub;
  const _LayananItem({required this.icon, required this.label, required this.sub});
}

class _ForumPost {
  final String text;
  final int likes;
  final int comments;
  final String timeAgo;
  const _ForumPost({required this.text, required this.likes, required this.comments, required this.timeAgo});
}

class _ArtikelData {
  final String category;
  final String title;
  final String readTime;
  final String timeAgo;
  final Color categoryColor;
  final Color categoryBg;
  const _ArtikelData({required this.category, required this.title, required this.readTime, required this.timeAgo, required this.categoryColor, required this.categoryBg});
}
