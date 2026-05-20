import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Warna utama (sama seperti forum.dart)
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

// Warna avatar berdasarkan inisial
const List<Color> _avatarColors = [
  Color(0xFF3D5A52),
  Color(0xFF5A7A72),
  Color(0xFF7A5A3D),
  Color(0xFF3D5272),
  Color(0xFF72523D),
  Color(0xFF52723D),
  Color(0xFF723D52),
];

Color _avatarColorFor(String name) {
  final code = name.codeUnits.fold(0, (a, b) => a + b);
  return _avatarColors[code % _avatarColors.length];
}

String _initialsFor(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  if (parts[0].isNotEmpty) return parts[0][0].toUpperCase();
  return '?';
}

class CurhatPost {
  final String id;
  final String authorName;
  final String category;
  final String content;
  final bool isAnonymous;
  int likes;
  int comments;
  final DateTime createdAt;
  bool isLiked;
  bool isSaved;
  final bool isOwnPost;

  CurhatPost({
    required this.id,
    required this.authorName,
    required this.category,
    required this.content,
    required this.isAnonymous,
    required this.likes,
    required this.comments,
    required this.createdAt,
    this.isLiked = false,
    this.isSaved = false,
    this.isOwnPost = false,
  });

  factory CurhatPost.fromJson(Map<String, dynamic> json, int? currentUserId) {
    return CurhatPost(
      id: json['id'].toString(),
      authorName: json['user']?['fullName'] ?? 'User',
      category: json['category'],
      content: json['content'],
      isAnonymous: json['isAnonymous'] ?? false,
      likes: int.tryParse(json['likes'].toString()) ?? 0,
      comments: int.tryParse(json['comments'].toString()) ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isLiked: json['isLiked'] ?? false,
      isSaved: json['isSaved'] ?? false,
      isOwnPost: json['userId'] == currentUserId,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

class CurhatBebasPage extends StatefulWidget {
  final VoidCallback? onBack;
  const CurhatBebasPage({super.key, this.onBack});

  @override
  State<CurhatBebasPage> createState() => _CurhatBebasPageState();
}

class _CurhatBebasPageState extends State<CurhatBebasPage>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabController;
  bool _isLoading = false;
  int? _currentUserId;
  String _currentUserName = 'Kamu';

  final List<String> _categories = [
    'Semua', 'Tersimpan', 'Curhat', 'Tips', 'Pertanyaan', 'Motivasi', 'Pengalaman'
  ];

  List<CurhatPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchPosts();
      }
    });
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      final userData = jsonDecode(userDataStr);
      _currentUserId = userData['id'];
      _currentUserName = userData['fullName'] ?? 'Kamu';
    }
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final category = _categories[_tabController.index];
      // Type 'public' means we only want non-anonymous posts for this page
      final response = await ApiService.get('/forum?category=$category&type=public&userId=$_currentUserId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _posts = data.map((json) => CurhatPost.fromJson(json, _currentUserId)).toList();
          });
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesi telah berakhir. Silakan login kembali.')),
          );
        }
      }
    } catch (e) {
      // Error handled silently or via snackbar in relevant methods
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createPost(String category, String content) async {
    if (_currentUserId == null) return;
    try {
      final response = await ApiService.post('/forum', {
        'userId': _currentUserId,
        'category': category,
        'content': content,
        'isAnonymous': false,
      });
      if (response.statusCode == 201) {
        await _fetchPosts();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuat postingan: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error creating post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Future<void> _toggleLike(CurhatPost post) async {
    if (_currentUserId == null) return;
    try {
      final response = await ApiService.post('/forum/${post.id}/like', {'userId': _currentUserId});
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          post.isLiked = data['liked'];
          post.likes += post.isLiked ? 1 : -1;
        });
      }
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }

  Future<void> _toggleSave(CurhatPost post) async {
    if (_currentUserId == null) return;
    try {
      final response = await ApiService.post('/forum/${post.id}/save', {'userId': _currentUserId});
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          post.isSaved = data['saved'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(post.isSaved ? 'Berhasil disimpan' : 'Batal disimpan')),
        );
      }
    } catch (e) {
      debugPrint('Error saving post: $e');
    }
  }

  void _openCommentSheet(CurhatPost post) {
    final commentCtrl = TextEditingController();
    bool isPosting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (ctx, scrollCtrl) => Container(
            decoration: const BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              children: [
                Container(width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                const Text('Balasan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text1)),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<http.Response>(
                    future: ApiService.get('/forum/${post.id}/comments'),
                    builder: (ctx, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final List<dynamic> comments = jsonDecode(snapshot.data!.body);
                      if (comments.isEmpty) return const Center(child: Text('Belum ada balasan', style: TextStyle(color: AppColors.text3)));
                      return ListView.builder(
                        controller: scrollCtrl,
                        itemCount: comments.length,
                        itemBuilder: (ctx, i) {
                          final c = comments[i];
                          final author = c['user']?['fullName'] ?? 'User';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNamedAvatar(author, 32),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(author, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      Text(c['content'], style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.4)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentCtrl,
                        decoration: InputDecoration(
                          hintText: 'Tulis balasan...',
                          filled: true,
                          fillColor: AppColors.bg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: isPosting ? null : () async {
                        final text = commentCtrl.text.trim();
                        if (text.isEmpty) return;
                        setModal(() => isPosting = true);
                        await ApiService.post('/forum/${post.id}/comments', {
                          'userId': _currentUserId,
                          'content': text,
                        });
                        commentCtrl.clear();
                        setState(() => post.comments++);
                        setModal(() => isPosting = false);
                      },
                      icon: Icon(Icons.send_rounded, color: AppColors.hero),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<CurhatPost> get _filteredPosts {
    final query = _searchCtrl.text.toLowerCase().trim();
    if (query.isEmpty) return _posts;
    return _posts.where((p) {
      return p.content.toLowerCase().contains(query);
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
                      _buildNamedAvatar(_currentUserName, 38),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUserName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text1),
                          ),
                          const Text(
                            'Namamu akan ditampilkan di postingan',
                            style:
                            TextStyle(fontSize: 11, color: AppColors.text3),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Kategori',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text3,
                          letterSpacing: 0.4)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.where((cat) => cat != 'Semua' && cat != 'Tersimpan').map((cat) {
                        final isSelected = selectedCategory == cat;
                        return GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color:
                              isSelected ? AppColors.hero : AppColors.bg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isSelected
                                      ? AppColors.hero
                                      : AppColors.border2,
                                  width: 0.8),
                            ),
                            child: Text(cat,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.text2)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(14),
                      border:
                      Border.all(color: AppColors.border2, width: 0.5),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: TextField(
                      controller: ctrl,
                      maxLines: 5,
                      minLines: 3,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.text1,
                          height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Apa yang ingin kamu bagikan hari ini?',
                        hintStyle:
                        TextStyle(fontSize: 14, color: AppColors.text3),
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
                      onPressed: () async {
                        final text = ctrl.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.pop(ctx);
                          await _createPost(selectedCategory, text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.hero,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: const Text('Kirim Postingan',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
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
    return Stack(
      children: [
        Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryTabs(),
            if (_isLoading) 
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.hero))),
              ),
            Expanded(
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (_, __) {
                  final posts = _filteredPosts;
                  if (posts.isEmpty && !_isLoading) return _buildEmptyState();
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
        Positioned(
          right: 22,
          bottom: 22,
          child: FloatingActionButton.extended(
            onPressed: _openPostDialog,
            backgroundColor: AppColors.hero,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Tulis Postingan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.onBack != null) ...[
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border2, width: 0.5),
                    ),
                    child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.hero),
                  ),
                ),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Curhat Bebas',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text1,
                          letterSpacing: -0.5)),
                  SizedBox(height: 2),
                  Text('Ceritakan isi hatimu, dengan namamu sendiri',
                      style: TextStyle(fontSize: 12, color: AppColors.text3)),
                ],
              ),
            ],
          ),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
                color: AppColors.accentBg, shape: BoxShape.circle),
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
            border: Border.all(color: AppColors.border2, width: 0.5)),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: AppColors.text1),
          decoration: const InputDecoration(
            hintText: 'Cari postingan...',
            hintStyle: TextStyle(fontSize: 13, color: AppColors.text3),
            prefixIcon:
            Icon(Icons.search_rounded, size: 18, color: AppColors.text3),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                        color: isSelected ? AppColors.hero : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.hero
                                : AppColors.border2,
                            width: 0.8)),
                    child: Text(cat,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.text2)),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPostCard(CurhatPost post) {
    final isOwn = post.isOwnPost;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        decoration: BoxDecoration(
            color: isOwn ? const Color(0xFFE8F2EE) : AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isOwn
                    ? AppColors.hero.withOpacity(0.35)
                    : AppColors.border2,
                width: isOwn ? 1.2 : 0.5)),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildNamedAvatar(post.authorName, 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text1),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isOwn) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.hero,
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Text('kamu post ini',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2)),
                            ),
                          ],
                        ],
                      ),
                      Text(post.timeAgo,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.text3)),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: isOwn
                          ? AppColors.hero.withOpacity(0.12)
                          : AppColors.accentBg,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(post.category,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.hero,
                          letterSpacing: 0.2)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.text1, height: 1.55)),
            const SizedBox(height: 14),
            Divider(
                height: 1,
                color: isOwn
                    ? AppColors.hero.withOpacity(0.15)
                    : AppColors.border),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildActionButton(
                  icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: '${post.likes}',
                  color: post.isLiked ? const Color(0xFFD96B6B) : AppColors.text3,
                  onTap: () => _toggleLike(post),
                ),
                const SizedBox(width: 18),
                _buildActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${post.comments} balasan',
                  color: AppColors.text3,
                  onTap: () => _openCommentSheet(post),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _toggleSave(post),
                  child: Icon(
                    post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 18,
                    color: post.isSaved ? AppColors.hero : AppColors.text3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Avatar dengan inisial nama dan warna unik per nama
  Widget _buildNamedAvatar(String name, double size) {
    final color = _avatarColorFor(name);
    final initials = _initialsFor(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
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
      child: Row(children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ]),
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
                color: AppColors.accentBg, shape: BoxShape.circle),
            child: const Icon(Icons.forum_outlined,
                size: 34, color: AppColors.hero),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada postingan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1)),
          const SizedBox(height: 6),
          const Text('Jadilah yang pertama berbagi!',
              style: TextStyle(fontSize: 13, color: AppColors.text3)),
        ],
      ),
    );
  }
}