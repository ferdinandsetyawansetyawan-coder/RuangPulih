import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Warna ────────────────────────────────────────────────────────────────────
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
  static const danger = Color(0xFFD96B6B);
}

// ─── Model ────────────────────────────────────────────────────────────────────
class HabitItem {
  final String id;
  String emoji;
  String title;
  String subtitle;
  final Color accentColor;
  bool completedToday;
  int streakDays;
  List<bool> weekHistory;

  HabitItem({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.completedToday = false,
    this.streakDays = 0,
    List<bool>? weekHistory,
  }) : weekHistory = weekHistory ?? List.filled(7, false);

  factory HabitItem.fromJson(Map<String, dynamic> json) {
    return HabitItem(
      id: json['id'].toString(),
      emoji: json['emoji'] ?? '⭐',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      accentColor: const Color(0xFFE8F5E9),
      completedToday: json['completedToday'] ?? false,
      streakDays: json['streakDays'] ?? 0,
      weekHistory: (json['weekHistory'] as List?)?.map((e) => e as bool).toList(),
    );
  }
}

// ─── Main Page ────────────────────────────────────────────────────────────────
class HabitTrackerPage extends StatefulWidget {
  final VoidCallback? onBack;
  const HabitTrackerPage({super.key, this.onBack});

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage>
    with TickerProviderStateMixin {
  List<HabitItem> _habits = [];
  late AnimationController _celebController;
  late Animation<double> _celebAnim;
  bool _showCelebration = false;
  String _celebMessage = '';
  bool _isLoading = false;
  int? _userId;

  int _xp = 0;
  static const int _xpPerLevel = 100;
  int get _level => (_xp ~/ _xpPerLevel) + 1;
  int get _xpInLevel => _xp % _xpPerLevel;
  String get _levelTitle {
    if (_level <= 1) return 'Pemula 🌱';
    if (_level <= 5) return 'Konsisten 🌿';
    if (_level <= 15) return 'Terbiasa 🌳';
    return 'Master Kebiasaan 🏆';
  }

  int get _completedToday => _habits.where((h) => h.completedToday).length;
  int get _totalHabits => _habits.length;

  static const _presetSuggestions = [
    {'emoji': '📵', 'title': 'Screen-free 1 jam', 'sub': 'Sebelum tidur'},
    {'emoji': '🙏', 'title': 'Bersyukur', 'sub': '3 hal setiap pagi'},
    {'emoji': '📚', 'title': 'Baca buku', 'sub': '15 menit'},
    {'emoji': '💧', 'title': 'Minum Air', 'sub': '2 Liter sehari'},
    {'emoji': '🧘', 'title': 'Meditasi', 'sub': '5 Menit'},
  ];

  @override
  void initState() {
    super.initState();
    _celebController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebAnim = CurvedAnimation(
      parent: _celebController,
      curve: Curves.elasticOut,
    );
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      final userData = jsonDecode(userDataStr);
      _userId = userData['id'];
      setState(() {
        _xp = userData['exp'] ?? 0;
      });
    }
    _fetchHabits();
  }

  Future<void> _fetchHabits() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/habits?userId=$_userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _habits = data.map((json) => HabitItem.fromJson(json)).toList();
        });
      }
    } catch (e) {
      // Fetch error ignored
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _celebController.dispose();
    super.dispose();
  }

  Future<void> _toggleHabit(int index) async {
    if (_userId == null) return;
    HapticFeedback.lightImpact();
    final habit = _habits[index];
    
    try {
      final response = await ApiService.post('/habits/${habit.id}/toggle', {
        'userId': _userId,
      });
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          habit.completedToday = data['completedToday'];
          habit.streakDays = data['streakDays'];
          habit.weekHistory[6] = habit.completedToday;
          _xp = data['exp'];
          
          // Update local storage too to keep it in sync
          _updateLocalStorageXP(_xp, data['level']);
          
          if (habit.completedToday) {
            _celebMessage = 'Lanjutkan! +15 XP';
          }
        });

        if (habit.completedToday) {
          _triggerCelebration();
        }
      }
    } catch (e) {
      // Toggle error ignored
    }
  }

  Future<void> _updateLocalStorageXP(int exp, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      final userData = jsonDecode(userDataStr);
      userData['exp'] = exp;
      userData['level'] = level;
      await prefs.setString('user_data', jsonEncode(userData));
    }
  }

  void _triggerCelebration() {
    setState(() => _showCelebration = true);
    _celebController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _celebController.reverse().then((_) {
            setState(() => _showCelebration = false);
          });
        }
      });
    });
  }

  void _openEditDialog(HabitItem habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CustomHabitForm(
        existing: habit,
        onSave: (title, subtitle, emoji) async {
          if (_userId == null) return;
          try {
            final response = await ApiService.put('/habits/${habit.id}', {
              'userId': _userId,
              'title': title,
              'subtitle': subtitle,
              'emoji': emoji,
            });
            if (response.statusCode == 200) {
              _fetchHabits();
            }
          } catch (e) {
            // Update error ignored
          }
        },
      ),
    );
  }

  void _openCustomHabitDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CustomHabitForm(
        onSave: (title, subtitle, emoji) async {
          if (_userId == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: User ID tidak ditemukan. Silakan login kembali.')),
              );
            }
            return;
          }
          try {
            final response = await ApiService.post('/habits', {
              'userId': _userId,
              'title': title,
              'subtitle': subtitle,
              'emoji': emoji,
            });
            if (response.statusCode == 201) {
              _fetchHabits();
              _loadUserAndFetch(); // To sync XP
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kebiasaan baru ditambahkan!')),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menambahkan: ${response.statusCode}')),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Terjadi kesalahan: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _addPreset(Map<String, String> p) async {
    if (_userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Silakan login kembali.')),
        );
      }
      return;
    }
    HapticFeedback.mediumImpact();
    try {
      final response = await ApiService.post('/habits', {
        'userId': _userId,
        'title': p['title'],
        'subtitle': p['sub'],
        'emoji': p['emoji'],
      });
      if (response.statusCode == 201) {
        _fetchHabits();
        _loadUserAndFetch();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${p['title']} ditambahkan!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.hero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  void _deleteHabit(int index) {
    final habit = _habits[index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus habit?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text('Hapus "${habit.title}" dari daftar kamu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.text3)),
          ),
          TextButton(
            onPressed: () async {
              if (_userId == null) return;
              Navigator.pop(ctx);
              try {
                final response = await ApiService.delete('/habits/${habit.id}/$_userId');
                if (response.statusCode == 200) {
                  _fetchHabits();
                }
              } catch (e) {
                // Delete error ignored
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showHabitOptions(int index) {
    final habit = _habits[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38, height: 4,
              decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(habit.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(habit.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text1)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),
            _OptionTile(
              icon: Icons.edit_outlined,
              label: 'Edit kebiasaan',
              onTap: () {
                Navigator.pop(ctx);
                _openEditDialog(habit);
              },
            ),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Hapus kebiasaan',
              color: AppColors.danger,
              onTap: () {
                Navigator.pop(ctx);
                _deleteHabit(index);
              },
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchHabits,
                    color: AppColors.hero,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 100),
                      children: [
                        _LevelBanner(
                          level: _level,
                          levelTitle: _levelTitle,
                          xpInLevel: _xpInLevel,
                          xpPerLevel: _xpPerLevel,
                          totalXp: _xp,
                        ),
                        const SizedBox(height: 20),
                        _TodayProgress(completed: _completedToday, total: _totalHabits),
                        const SizedBox(height: 28),

                        _sectionHeader('Habit Kamu'),
                        const SizedBox(height: 14),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator(color: AppColors.hero))
                        else if (_habits.isEmpty)
                          _buildEmptyHabits()
                        else
                          ...List.generate(_habits.length, (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HabitCard(
                              habit: _habits[i],
                              onToggle: () => _toggleHabit(i),
                              onOptions: () => _showHabitOptions(i),
                            ),
                          )),

                        const SizedBox(height: 28),
                        _sectionHeader('Statistik Mingguan'),
                        const SizedBox(height: 14),
                        _WeekSummary(habits: _habits),

                        const SizedBox(height: 28),
                        _sectionHeader('Inspirasi Untukmu'),
                        const SizedBox(height: 14),
                        ..._presetSuggestions.map((p) => _SuggestionTile(
                          emoji: p['emoji']!,
                          title: p['title']!,
                          subtitle: p['sub']!,
                          onTap: () => _addPreset(p),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_showCelebration) _buildCelebrationOverlay(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCustomHabitDialog,
        backgroundColor: AppColors.hero,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Habit Kustom', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEmptyHabits() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.checklist_rounded, size: 48, color: AppColors.text3.withOpacity(0.5)),
            const SizedBox(height: 8),
            const Text('Belum ada habit aktif', style: TextStyle(color: AppColors.text3, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
      child: Row(
        children: [
          if (widget.onBack != null)
            GestureDetector(
              onTap: widget.onBack,
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border2, width: 0.5),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.hero),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Habit Tracker', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text1, letterSpacing: -0.5)),
                Text('Bangun kebiasaan baik setiap hari', style: TextStyle(fontSize: 12, color: AppColors.text3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text1));
  }

  Widget _buildCelebrationOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: ScaleTransition(
            scale: _celebAnim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.hero,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [BoxShadow(color: AppColors.hero.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(_celebMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Option Tile (for bottom sheet actions) ───────────────────────────────────
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.text1,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Habit Form ────────────────────────────────────────────────────────
class _CustomHabitForm extends StatefulWidget {
  final HabitItem? existing;
  final Function(String, String, String) onSave;

  const _CustomHabitForm({this.existing, required this.onSave});

  @override
  State<_CustomHabitForm> createState() => _CustomHabitFormState();
}

class _CustomHabitFormState extends State<_CustomHabitForm> {
  late TextEditingController _titleCtrl;
  late TextEditingController _subtitleCtrl;
  late TextEditingController _customEmojiCtrl;
  late String _selectedEmoji;
  bool _useCustomEmoji = false;

  static const _emojiOptions = [
    '⭐', '🥗', '📖', '💪', '🧘', '💧', '🏃', '🚲',
    '📝', '🛁', '☕', '🌙', '🔋', '🎨', '🧩', '💡',
    '🌿', '🍎', '🎯', '🏋️', '🎵', '✍️', '🌅', '🧹',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _subtitleCtrl = TextEditingController(text: widget.existing?.subtitle ?? '');
    _customEmojiCtrl = TextEditingController();

    final existingEmoji = widget.existing?.emoji ?? '⭐';
    if (_emojiOptions.contains(existingEmoji)) {
      _selectedEmoji = existingEmoji;
      _useCustomEmoji = false;
    } else {
      _selectedEmoji = existingEmoji;
      _customEmojiCtrl.text = existingEmoji;
      _useCustomEmoji = true;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _customEmojiCtrl.dispose();
    super.dispose();
  }

  String get _effectiveEmoji {
    if (_useCustomEmoji) {
      final custom = _customEmojiCtrl.text.trim();
      return custom.isNotEmpty ? custom : _selectedEmoji;
    }
    return _selectedEmoji;
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    widget.onSave(
      _titleCtrl.text.trim(),
      _subtitleCtrl.text.trim().isEmpty ? 'Kebiasaan kustom' : _subtitleCtrl.text.trim(),
      _effectiveEmoji,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
            children: [
              Center(
                child: Container(
                  width: 38, height: 4,
                  decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEdit ? 'Edit Kebiasaan' : 'Buat Kebiasaan Sendiri',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text1),
              ),
              const SizedBox(height: 24),

              // ── Emoji Picker ──────────────────────────────────────────────
              _FormLabel('Ikon Emoji'),
              const SizedBox(height: 10),

              // Toggle between grid and custom
              Row(
                children: [
                  _EmojiToggleChip(
                    label: 'Pilih Emoji',
                    selected: !_useCustomEmoji,
                    onTap: () => setState(() => _useCustomEmoji = false),
                  ),
                  const SizedBox(width: 8),
                  _EmojiToggleChip(
                    label: 'Ketik Emoji',
                    selected: _useCustomEmoji,
                    onTap: () => setState(() => _useCustomEmoji = true),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (!_useCustomEmoji) ...[
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _emojiOptions.map((e) {
                    final selected = e == _selectedEmoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.hero : AppColors.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? AppColors.hero : AppColors.border2),
                        ),
                        child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                // Custom emoji text input
                Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: Center(
                        child: Text(
                          _customEmojiCtrl.text.trim().isNotEmpty
                              ? _customEmojiCtrl.text.trim()
                              : '?',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _customEmojiCtrl,
                        maxLength: 2,
                        style: const TextStyle(fontSize: 22),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Ketik emoji di sini...',
                          hintStyle: const TextStyle(fontSize: 13, color: AppColors.text3),
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.bg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.hero, width: 1.5)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Buka keyboard emoji di HP kamu (🌐 atau 😊) lalu ketik emoji pilihanmu.',
                  style: TextStyle(fontSize: 11, color: AppColors.text3),
                ),
              ],

              const SizedBox(height: 20),
              _FormLabel('Nama Kebiasaan *'),
              const SizedBox(height: 8),
              _StyledTextField(controller: _titleCtrl, hint: 'cth: Yoga pagi, Minum vitamin...', maxLength: 40),
              const SizedBox(height: 16),
              _FormLabel('Deskripsi (opsional)'),
              const SizedBox(height: 8),
              _StyledTextField(controller: _subtitleCtrl, hint: 'cth: 10 menit · Setelah sarapan', maxLength: 60),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hero,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isEdit ? 'Simpan Perubahan' : 'Tambahkan Kebiasaan',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _FormLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text2, letterSpacing: 0.3));
  }
}

class _EmojiToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _EmojiToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.hero : AppColors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.hero : AppColors.border2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  const _StyledTextField({required this.controller, required this.hint, required this.maxLength});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 14, color: AppColors.text1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.text3),
        counterStyle: const TextStyle(fontSize: 10, color: AppColors.text3),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.hero, width: 1.5)),
      ),
    );
  }
}

// ─── Habit Card ───────────────────────────────────────────────────────────────
class _HabitCard extends StatelessWidget {
  final HabitItem habit;
  final VoidCallback onToggle;
  final VoidCallback onOptions;

  const _HabitCard({
    required this.habit,
    required this.onToggle,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: habit.completedToday ? habit.accentColor : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: habit.completedToday ? AppColors.hero.withOpacity(0.2) : AppColors.border,
            width: habit.completedToday ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 68, height: 68,
              decoration: BoxDecoration(
                color: habit.completedToday ? AppColors.hero.withOpacity(0.08) : AppColors.bg,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              ),
              child: Center(child: Text(habit.emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: habit.completedToday ? AppColors.hero : AppColors.text1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(habit.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                  ],
                ),
              ),
            ),
            // Streak badge
            if (habit.streakDays > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: habit.completedToday ? AppColors.hero.withOpacity(0.1) : AppColors.accentBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 3),
                    Text('${habit.streakDays}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.hero)),
                  ],
                ),
              ),
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: habit.completedToday ? AppColors.hero : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: habit.completedToday ? AppColors.hero : AppColors.border2, width: 1.5),
              ),
              child: habit.completedToday ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
            ),
            // Options button
            GestureDetector(
              onTap: onOptions,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 14, 12, 14),
                child: Icon(Icons.more_vert_rounded, size: 18, color: AppColors.text3.withOpacity(0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Level Banner ─────────────────────────────────────────────────────────────
class _LevelBanner extends StatelessWidget {
  final int level;
  final String levelTitle;
  final int xpInLevel;
  final int xpPerLevel;
  final int totalXp;
  const _LevelBanner({required this.level, required this.levelTitle, required this.xpInLevel, required this.xpPerLevel, required this.totalXp});

  @override
  Widget build(BuildContext context) {
    final progress = xpInLevel / xpPerLevel;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.hero, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text('Lv$level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(levelTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('$totalXp XP total', style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$xpInLevel / $xpPerLevel XP', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('ke Level ${level + 1}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Today Progress ───────────────────────────────────────────────────────────
class _TodayProgress extends StatelessWidget {
  final int completed;
  final int total;
  const _TodayProgress({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final allDone = completed == total && total > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: allDone ? const Color(0xFFE4F0EB) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: allDone ? AppColors.hero.withOpacity(0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46, height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: total > 0 ? completed / total : 0,
                  strokeWidth: 4,
                  backgroundColor: AppColors.border2,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.hero),
                ),
                Text('$completed', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text1)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allDone ? 'Semua selesai! 🎉' : '$completed dari $total habit selesai',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text1),
                ),
                const SizedBox(height: 3),
                Text(
                  allDone ? 'Luar biasa, kamu konsisten hari ini!' : '${total - completed} habit lagi untuk hari ini',
                  style: const TextStyle(fontSize: 12, color: AppColors.text3),
                ),
              ],
            ),
          ),
          if (allDone) const Icon(Icons.verified_rounded, color: AppColors.hero, size: 22),
        ],
      ),
    );
  }
}

// ─── Week Summary ─────────────────────────────────────────────────────────────
class _WeekSummary extends StatelessWidget {
  final List<HabitItem> habits;
  const _WeekSummary({required this.habits});
  static const _dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: const Center(child: Text('Belum ada habit', style: TextStyle(fontSize: 13, color: AppColors.text3))),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 36),
              ...List.generate(7, (i) => Expanded(
                child: Center(
                  child: Text(
                    _dayLabels[i],
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: i == 6 ? AppColors.hero : AppColors.text3),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 10),
          ...habits.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text(h.emoji, style: const TextStyle(fontSize: 14))),
                ),
                const SizedBox(width: 8),
                ...List.generate(7, (i) => Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: h.weekHistory[i]
                            ? (i == 6 ? AppColors.hero : AppColors.hero.withOpacity(0.25))
                            : AppColors.bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: h.weekHistory[i]
                          ? Icon(Icons.check_rounded, size: 13, color: i == 6 ? Colors.white : AppColors.hero)
                          : null,
                    ),
                  ),
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Suggestion Tile ──────────────────────────────────────────────────────────
class _SuggestionTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SuggestionTile({required this.emoji, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text1)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.hero),
          ],
        ),
      ),
    );
  }
}
