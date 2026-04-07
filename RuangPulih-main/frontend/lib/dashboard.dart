import 'package:flutter/material.dart';
import 'forum.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
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
                child: _buildSectionHeader('Forum Anonim', onLihatSemua: _goToForum),
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
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Selamat pagi,',
                style: TextStyle(fontSize: 13, color: AppColors.text3)),
            SizedBox(height: 2),
            Text(
              'Halo, User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text1,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.accentBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_outline_rounded,
              color: AppColors.hero, size: 24),
        ),
      ],
    );
  }

  Widget _buildMoodPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bagaimana perasaanmu saat ini?',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.text2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_moods.length, (i) {
              final m = _moods[i];
              final isSelected = _selectedMood == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = i),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentBg
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(color: AppColors.hero, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(m.emoji,
                            style: TextStyle(
                                fontSize: isSelected ? 26 : 22)),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      m.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSelected ? AppColors.hero : AppColors.text3,
                      ),
                    ),
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
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E4A42), Color(0xFF4E7A6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MAU CERITA SESUATU?',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xAAFFFFFF),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai curhat\nsekarang',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.white.withOpacity(0.4), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Mulai sesi',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatKonsultasi() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.hero.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 18, color: AppColors.hero),
                ),
                const SizedBox(height: 10),
                const Text('Chat AI',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1)),
                const SizedBox(height: 2),
                const Text('Siap mendengar 24 jam',
                    style:
                    TextStyle(fontSize: 11, color: AppColors.text2)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAE4F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B5EA7).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.medical_services_outlined,
                          size: 18, color: Color(0xFF7B5EA7)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B5EA7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Dokter',
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('Chat Dokter',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1)),
                const SizedBox(height: 2),
                const Text('Konsultasi profesional',
                    style:
                    TextStyle(fontSize: 11, color: AppColors.text2)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _goToForum() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForumPage()),
    );
  }

  Widget _buildSectionHeader(String title, {bool showLihatSemua = true, VoidCallback? onLihatSemua}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text1)),
        if (showLihatSemua)
          GestureDetector(
            onTap: onLihatSemua,
            child: const Text('Lihat semua',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hero)),
          ),
      ],
    );
  }

  Widget _buildLayananGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: _layanan.length,
      itemBuilder: (context, i) {
        final item = _layanan[i];
        return GestureDetector(
          onTap: i == 2 ? _goToForum : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border2, width: 0.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(item.icon, size: 20, color: AppColors.hero),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.label,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text1)),
                      const SizedBox(height: 2),
                      Text(item.sub,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.text3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForumCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _goToForum,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accentBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.forum_rounded,
                        size: 18, color: AppColors.hero),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Ruang Cerita',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text1)),
                      Text('Berbagi tanpa nama',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.text3)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.circle,
                            size: 6, color: Color(0xFF4CAF50)),
                        SizedBox(width: 4),
                        Text('247 online',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.hero)),
                      ],
                    ),
                  ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.accentBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_rounded,
                            size: 16, color: AppColors.hero),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.text,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.text2,
                                    height: 1.5)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.favorite_border_rounded,
                                    size: 12, color: AppColors.text3),
                                const SizedBox(width: 3),
                                Text('${post.likes}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.text3)),
                                const SizedBox(width: 10),
                                const Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 12,
                                    color: AppColors.text3),
                                const SizedBox(width: 3),
                                Text('${post.comments} balasan',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.text3)),
                                const Spacer(),
                                Text(post.timeAgo,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.text3)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _forumPosts.length - 1)
                  const Divider(
                      height: 1, indent: 14, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildArtikelList() {
    final articles = [
      _ArtikelData(
        category: 'Kesehatan Mental',
        title: '5 cara mengelola stres sehari-hari',
        readTime: '3 menit baca',
        timeAgo: 'Kemarin',
        categoryColor: const Color(0xFF2E7D32),
        categoryBg: const Color(0xFFE8F5E9),
      ),
      _ArtikelData(
        category: 'Mindfulness',
        title: 'Melatih pikiran tenang dengan journaling',
        readTime: '3 menit baca',
        timeAgo: '2 hari lalu',
        categoryColor: const Color(0xFF7B5EA7),
        categoryBg: const Color(0xFFEAE4F5),
      ),
    ];

    return Column(
      children: articles.map((a) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border2, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        size: 32, color: AppColors.hero),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: a.categoryBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          a.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: a.categoryColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(a.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text1,
                            height: 1.4,
                          )),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(a.readTime,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.text3)),
                          const Text(' · ',
                              style:
                              TextStyle(color: AppColors.text3)),
                          Text(a.timeAgo,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.text3)),
                        ],
                      ),
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
      decoration: const BoxDecoration(
        color: AppColors.card,
        border:
        Border(top: BorderSide(color: AppColors.border2, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (i) {
          final item = _navItems[i];
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () {
              if (i == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForumPage()),
                );
              } else {
                setState(() => _selectedIndex = i);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon,
                    size: 22,
                    color: isSelected ? AppColors.hero : AppColors.text3),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color:
                    isSelected ? AppColors.hero : AppColors.text3,
                  ),
                ),
                const SizedBox(height: 2),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.hero,
                      shape: BoxShape.circle,
                    ),
                  ),
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
  const _LayananItem(
      {required this.icon, required this.label, required this.sub});
}

class _ForumPost {
  final String text;
  final int likes;
  final int comments;
  final String timeAgo;
  const _ForumPost(
      {required this.text,
        required this.likes,
        required this.comments,
        required this.timeAgo});
}

class _ArtikelData {
  final String category;
  final String title;
  final String readTime;
  final String timeAgo;
  final Color categoryColor;
  final Color categoryBg;
  const _ArtikelData({
    required this.category,
    required this.title,
    required this.readTime,
    required this.timeAgo,
    required this.categoryColor,
    required this.categoryBg,
  });
}