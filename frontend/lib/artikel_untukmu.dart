import 'package:flutter/material.dart';

// Warna utama (same as dashboard)
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

class ArtikelUntukmuPage extends StatefulWidget {
  final VoidCallback? onBack;
  final int selectedIndex;
  final Function(int) onNavTap;
  
  const ArtikelUntukmuPage({
    super.key, 
    this.onBack,
    required this.selectedIndex,
    required this.onNavTap,
  });

  @override
  State<ArtikelUntukmuPage> createState() => _ArtikelUntukmuPageState();
}

class _ArtikelUntukmuPageState extends State<ArtikelUntukmuPage> {
  int _selectedCategory = 0;
  String _searchQuery = '';
  final Set<String> _bookmarkedArticleTitles = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.favorite_border_rounded, label: 'Sesi'),
    _NavItem(icon: Icons.forum_outlined, label: 'Forum'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Aktifitas'),
    _NavItem(icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  static const _categories = [
    'Semua',
    'Tersimpan',
    'Kesehatan Mental',
    'Mindfulness',
    'Produktivitas',
    'Relasi',
  ];

  static const _featured = _ArtikelData(
    category: 'Kesehatan Mental',
    title: 'Mengenal tanda-tanda burnout dan cara mengatasinya',
    readTime: '5 menit baca',
    timeAgo: 'Hari ini',
    categoryColor: Color(0xFF2E7D32),
    categoryBg: Color(0xFFE8F5E9),
    isFeatured: true,
  );

  static const _articles = [
    _ArtikelData(
      category: 'Kesehatan Mental',
      title: '5 cara mengelola stres sehari-hari',
      readTime: '3 menit baca',
      timeAgo: 'Kemarin',
      categoryColor: Color(0xFF2E7D32),
      categoryBg: Color(0xFFE8F5E9),
    ),
    _ArtikelData(
      category: 'Mindfulness',
      title: 'Melatih pikiran tenang dengan journaling',
      readTime: '3 menit baca',
      timeAgo: '2 hari lalu',
      categoryColor: Color(0xFF7B5EA7),
      categoryBg: Color(0xFFEAE4F5),
    ),
    _ArtikelData(
      category: 'Produktivitas',
      title: 'Teknik Pomodoro untuk fokus lebih dalam',
      readTime: '4 menit baca',
      timeAgo: '3 hari lalu',
      categoryColor: Color(0xFF1565C0),
      categoryBg: Color(0xFFE3F2FD),
    ),
    _ArtikelData(
      category: 'Relasi',
      title: 'Cara mengkomunikasikan perasaan dengan efektif',
      readTime: '6 menit baca',
      timeAgo: '4 hari lalu',
      categoryColor: Color(0xFFC0392B),
      categoryBg: Color(0xFFFFEBEE),
    ),
    _ArtikelData(
      category: 'Mindfulness',
      title: 'Latihan pernapasan 4-7-8 untuk meredakan kecemasan',
      readTime: '2 menit baca',
      timeAgo: '5 hari lalu',
      categoryColor: Color(0xFF7B5EA7),
      categoryBg: Color(0xFFEAE4F5),
    ),
    _ArtikelData(
      category: 'Kesehatan Mental',
      title: 'Pentingnya tidur berkualitas bagi kesehatan mental',
      readTime: '4 menit baca',
      timeAgo: '1 minggu lalu',
      categoryColor: Color(0xFF2E7D32),
      categoryBg: Color(0xFFE8F5E9),
    ),
  ];

  List<_ArtikelData> get _filteredArticles {
    final cat = _categories[_selectedCategory];
    List<_ArtikelData> list;

    if (cat == 'Semua') {
      list = List.from(_articles);
    } else if (cat == 'Tersimpan') {
      list = [_featured, ..._articles].where((a) => _bookmarkedArticleTitles.contains(a.title)).toList();
    } else {
      list = _articles.where((a) => a.category == cat).toList();
    }

    if (_searchQuery.isNotEmpty) {
      list = list.where((a) => a.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  void _toggleBookmark(String title) {
    setState(() {
      if (_bookmarkedArticleTitles.contains(title)) {
        _bookmarkedArticleTitles.remove(title);
      } else {
        _bookmarkedArticleTitles.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    _buildCategoryChips(),
                    const SizedBox(height: 20),
                    if (_selectedCategory == 0 && _searchQuery.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _buildSectionLabel('Pilihan untukmu'),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _buildFeaturedCard(_featured),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _buildSectionLabel('Artikel terbaru'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: _buildArticleList(),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Only show local bottom nav if the parent dashboard isn't showing its own
      // In this app structure, the DashboardPage manages the global Scaffold and its BottomNav.
      // However, since ArtikelUntukmuPage is swapped inside the Dashboard's body, 
      // if we provide a Scaffold here with a BottomNav, it will appear INSIDE the dashboard's body.
      // If the user sees two footers, it means we should probably REMOVE this one and let the Dashboard handle it.
      // But the user requested "the footer button... need to be at that screen as well".
      // I will keep ONE footer and ensure it doesn't duplicate if I can detect the parent, 
      // but usually, removing it from here and relying on the Dashboard's global footer is the fix.
      // The user said "there are 2 footer(duplicate)", so I will remove the local one.
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 14, 22, 12),
      color: AppColors.bg,
      child: Row(
        children: [
          if (widget.onBack != null)
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.hero),
            )
          else
            const SizedBox(width: 22),
          const Expanded(
            child: Text(
              'Artikel untukmu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text1,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border2, width: 0.5),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Cari artikel...',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.text3),
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.text3),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: _searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.text3),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ) 
              : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.hero : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.hero : AppColors.border2,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Text(
                _categories[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.text2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.text1,
      ),
    );
  }

  Widget _buildFeaturedCard(_ArtikelData a) {
    final isBookmarked = _bookmarkedArticleTitles.contains(a.title);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder — taller for featured
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.accentBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.image_outlined, size: 40, color: AppColors.hero),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.hero,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PILIHAN EDITOR',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                const SizedBox(height: 10),
                Text(
                  a.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Burnout bisa terjadi pada siapa saja. Kenali tanda-tandanya lebih awal agar kamu bisa segera mencari bantuan yang tepat.',
                  style: TextStyle(fontSize: 13, color: AppColors.text2, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 13, color: AppColors.text3),
                    const SizedBox(width: 4),
                    Text(a.readTime, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                    const Text(' · ', style: TextStyle(color: AppColors.text3)),
                    Text(a.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 20,
                        color: isBookmarked ? AppColors.hero : AppColors.text3,
                      ),
                      onPressed: () => _toggleBookmark(a.title),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Baca',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.hero),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleList() {
    final list = _filteredArticles;
    if (list.isEmpty) {
      final isSavedFilter = _categories[_selectedCategory] == 'Tersimpan';
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(
                isSavedFilter ? Icons.bookmark_border_rounded : Icons.article_outlined, 
                size: 48, 
                color: AppColors.hero.withOpacity(0.3)
              ),
              const SizedBox(height: 12),
              Text(
                isSavedFilter ? 'Belum ada artikel yang disimpan' : 'Belum ada artikel yang cocok', 
                style: const TextStyle(color: AppColors.text3)
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      children: list.asMap().entries.map((e) {
        final a = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildArticleCard(a),
        );
      }).toList(),
    );
  }

  Widget _buildArticleCard(_ArtikelData a) {
    final isBookmarked = _bookmarkedArticleTitles.contains(a.title);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: AppColors.accentBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, size: 28, color: AppColors.hero),
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: a.categoryBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: a.categoryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(a.readTime, style: const TextStyle(fontSize: 10, color: AppColors.text3)),
                      const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.text3)),
                      Text(a.timeAgo, style: const TextStyle(fontSize: 10, color: AppColors.text3)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bookmark icon
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: 18,
                color: isBookmarked ? AppColors.hero : AppColors.text3,
              ),
              onPressed: () => _toggleBookmark(a.title),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtikelData {
  final String category;
  final String title;
  final String readTime;
  final String timeAgo;
  final Color categoryColor;
  final Color categoryBg;
  final bool isFeatured;

  const _ArtikelData({
    required this.category,
    required this.title,
    required this.readTime,
    required this.timeAgo,
    required this.categoryColor,
    required this.categoryBg,
    this.isFeatured = false,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}