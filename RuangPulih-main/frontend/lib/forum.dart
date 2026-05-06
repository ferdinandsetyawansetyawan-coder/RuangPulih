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

class ForumPost {
  final String id;
  final String category;
  final String content;
  int likes;
  int comments;
  final String timeAgo;
  bool isLiked;
  final bool isOwnPost;

  ForumPost({
    required this.id,
    required this.category,
    required this.content,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    this.isLiked = false,
    this.isOwnPost = false,
  });
}

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabController;
  int _selectedNav = 2;

  final List<String> _categories = [
    'Semua', 'Curhat', 'Tips', 'Pertanyaan', 'Motivasi', 'Pengalaman'
  ];

  late List<ForumPost> _posts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _posts = _samplePosts();
  }

  List<ForumPost> _samplePosts() {
    return [
      ForumPost(
        id: '1',
        category: 'Curhat',
        content: 'Hari ini aku ngerasa overwhelmed banget sama kerjaan. Rasanya semua deadline dateng bareng dan aku nggak tau harus mulai dari mana... Ada yang pernah ngalamin hal yang sama?',
        likes: 42,
        comments: 8,
        timeAgo: '2 jm lalu',
        isLiked: false,
      ),
      ForumPost(
        id: '2',
        category: 'Motivasi',
        content: 'Gapapa nangis, itu bukan kelemahan, itu keberanian. Kamu sudah berjuang jauh lebih keras dari yang orang lain tahu. Tetap semangat ya semuanya 💚',
        likes: 125,
        comments: 23,
        timeAgo: '5 jm lalu',
        isLiked: true,
      ),
      ForumPost(
        id: '3',
        category: 'Pertanyaan',
        content: 'Tips buat anxiety saat presentasi? Aku udah coba tarik napas tapi tetep gemetar terus. Butuh saran dari teman-teman di sini 🙏',
        likes: 19,
        comments: 31,
        timeAgo: '1 hr lalu',
        isLiked: false,
      ),
      ForumPost(
        id: '4',
        category: 'Tips',
        content: 'Setelah 6 bulan terapi, aku mau share beberapa hal yang benar-benar bantu aku:\n\n1. Journaling setiap malam\n2. Batasi social media jam 9 malam\n3. Cerita ke orang yang kamu percaya\n\nSemoga membantu!',
        likes: 88,
        comments: 14,
        timeAgo: '2 hr lalu',
        isLiked: false,
      ),
      ForumPost(
        id: '5',
        category: 'Pengalaman',
        content: 'Baru pertama kali konsultasi sama psikolog minggu lalu. Awalnya takut banget, tapi ternyata aman dan judgement-free. Kalau kalian ragu-ragu, coba aja dulu, worth it banget!',
        likes: 67,
        comments: 19,
        timeAgo: '3 hr lalu',
        isLiked: false,
      ),
    ];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<ForumPost> get _filteredPosts {
    final selectedCat = _categories[_tabController.index];
    final query = _searchCtrl.text.toLowerCase().trim();
    return _posts.where((p) {
      final matchCat = selectedCat == 'Semua' || p.category == selectedCat;
      final matchQuery = query.isEmpty || p.content.toLowerCase().contains(query);
      return matchCat && matchQuery;
    }).toList();
  }

  void _openPostDialog() {
    final ctrl = TextEditingController();
    String selectedCategory = 'Curhat';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border2,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _buildAnonAvatar(38),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Anonim',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text1,
                            ),
                          ),
                          Text(
                            'Identitasmu tidak akan ditampilkan',
                            style: TextStyle(fontSize: 11, color: AppColors.text3),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Category selector
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text3,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.skip(1).map((cat) {
                        final isSelected = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.hero : AppColors.bg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.hero : AppColors.border2,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : AppColors.text2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Text input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border2, width: 0.5),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: TextField(
                      controller: ctrl,
                      maxLines: 5,
                      minLines: 3,
                      style: const TextStyle(fontSize: 14, color: AppColors.text1, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Apa yang ingin kamu bagikan hari ini?',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.text3),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final text = ctrl.text.trim();
                        if (text.isNotEmpty) {
                          setState(() {
                            _posts.insert(
                              0,
                              ForumPost(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                category: selectedCategory,
                                content: text,
                                likes: 0,
                                comments: 0,
                                timeAgo: 'Baru saja',
                                isLiked: false,
                                isOwnPost: true,
                              ),
                            );
                          });
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hero,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Kirim Postingan',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (_, __) {
                  final posts = _filteredPosts;
                  if (posts.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 100),
                    itemCount: posts.length,
                    itemBuilder: (_, i) => _buildPostCard(posts[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPostDialog,
        backgroundColor: AppColors.hero,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text(
          'Tulis Postingan',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Forum Komunitas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Berbagi, mendukung, dan bertumbuh bersama',
                style: TextStyle(fontSize: 12, color: AppColors.text3),
              ),
            ],
          ),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.accentBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: AppColors.hero, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border2, width: 0.5),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: AppColors.text1),
          decoration: const InputDecoration(
            hintText: 'Cari postingan atau pengguna...',
            hintStyle: TextStyle(fontSize: 13, color: AppColors.text3),
            prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppColors.text3),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 36,
        child: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.transparent,
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.only(left: 6, right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          tabs: _categories.map((cat) {
            return Tab(
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (_, __) {
                  final isSelected = _categories[_tabController.index] == cat;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.hero : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.hero : AppColors.border2,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.text2,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPostCard(ForumPost post) {
    final isOwn = post.isOwnPost;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isOwn ? const Color(0xFFE8F2EE) : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOwn ? AppColors.hero.withOpacity(0.35) : AppColors.border2,
            width: isOwn ? 1.2 : 0.5,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                _buildAnonAvatar(38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Anonim',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text1,
                            ),
                          ),
                          if (isOwn) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.hero,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'kamu post ini',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        post.timeAgo,
                        style: const TextStyle(fontSize: 11, color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOwn ? AppColors.hero.withOpacity(0.12) : AppColors.accentBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    post.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.hero,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text1,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 14),
            // Divider
            Divider(height: 1, color: isOwn ? AppColors.hero.withOpacity(0.15) : AppColors.border),
            const SizedBox(height: 12),
            // Actions row
            Row(
              children: [
                _buildActionButton(
                  icon: post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: '${post.likes}',
                  color: post.isLiked ? const Color(0xFFD96B6B) : AppColors.text3,
                  onTap: () {
                    setState(() {
                      post.isLiked = !post.isLiked;
                      post.likes += post.isLiked ? 1 : -1;
                    });
                  },
                ),
                const SizedBox(width: 18),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.comments} balasan',
                  color: AppColors.text3,
                  onTap: () {},
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.bookmark_border_rounded,
                      size: 18, color: AppColors.text3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border2, width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: size * 0.55,
          color: AppColors.hero,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.accentBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forum_outlined, size: 34, color: AppColors.hero),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada postingan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Jadilah yang pertama berbagi!',
            style: TextStyle(fontSize: 13, color: AppColors.text3),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const navItems = [
      _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
      _NavItem(icon: Icons.favorite_border_rounded, label: 'Sesi'),
      _NavItem(icon: Icons.forum_outlined, label: 'Forum'),
      _NavItem(icon: Icons.bar_chart_rounded, label: 'Aktifitas'),
      _NavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
    ];

    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border2, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (i) {
          final item = navItems[i];
          final isSelected = _selectedNav == i;
          return GestureDetector(
            onTap: () {
              if (i == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                      (route) => false,
                );
              } else {
                setState(() => _selectedNav = i);
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
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.hero : AppColors.text3,
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