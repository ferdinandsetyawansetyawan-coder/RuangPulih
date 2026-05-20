import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'dart:convert';

// ─── Warna (sama persis dengan dashboard.dart) ────────────────────────────────
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

// ─── Model ────────────────────────────────────────────────────────────────────
class JurnalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String moodEmoji;   // e.g. "😊"
  final String moodLabel;   // e.g. "Baik"
  String toneTag;           // AI-generated e.g. "Tenang 🌿"
  final Color toneColor;    // subtle background for the tag

  JurnalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.moodEmoji,
    required this.moodLabel,
    this.toneTag = '',
    required this.toneColor,
  });

  factory JurnalEntry.fromJson(Map<String, dynamic> json) {
    final tag = json['toneTag'] ?? '';
    return JurnalEntry(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['createdAt']),
      moodEmoji: json['moodEmoji'],
      moodLabel: json['moodLabel'],
      toneTag: tag,
      toneColor: _getToneColor(tag),
    );
  }
}

Color _getToneColor(String tag) {
  if (tag.contains('Tenang')) return const Color(0xFFE4F0EB);
  if (tag.contains('Berat')) return const Color(0xFFE8EDF5);
  if (tag.contains('Bersyukur')) return const Color(0xFFFAF3E0);
  if (tag.contains('Cemas')) return const Color(0xFFF5EAE4);
  if (tag.contains('Semangat')) return const Color(0xFFEFF5E4);
  if (tag.contains('Sedih')) return const Color(0xFFEEEEF3);
  return const Color(0xFFEDE9E1);
}

// ─── Tone metadata ────────────────────────────────────────────────────────────
class _ToneMeta {
  final String tag;
  final Color color;
  const _ToneMeta(this.tag, this.color);
}

// ─── Main Page ────────────────────────────────────────────────────────────────
class JurnalHarianPage extends StatefulWidget {
  final VoidCallback? onBack;
  const JurnalHarianPage({super.key, this.onBack});

  @override
  State<JurnalHarianPage> createState() => _JurnalHarianPageState();
}

class _JurnalHarianPageState extends State<JurnalHarianPage>
    with TickerProviderStateMixin {
  List<JurnalEntry> _entries = [];
  bool _isLoading = false;
  int? _userId;

  // Sample moods (same as dashboard)
  static const _moods = [
    {'emoji': '😢', 'label': 'Sedih'},
    {'emoji': '😰', 'label': 'Cemas'},
    {'emoji': '😐', 'label': 'Biasa'},
    {'emoji': '😊', 'label': 'Baik'},
    {'emoji': '😁', 'label': 'Bahagia'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAndFetch();
  }

  Future<void> _loadUserAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      final userData = jsonDecode(userDataStr);
      _userId = userData['id'];
    }
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/journals/user/$_userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _entries = data.map((json) => JurnalEntry.fromJson(json)).toList();
        });
      }
    } catch (e) {
      // Fetch error ignored
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createEntry(String title, String content, String moodEmoji, String moodLabel, String toneTag) async {
    if (_userId == null) return;
    try {
      final response = await ApiService.post('/journals', {
        'userId': _userId,
        'title': title,
        'content': content,
        'moodEmoji': moodEmoji,
        'moodLabel': moodLabel,
        'toneTag': toneTag,
      });
      if (response.statusCode == 201) {
        _fetchEntries();
      }
    } catch (e) {
      // Create error ignored
    }
  }

  Future<void> _updateEntry(String id, String title, String content, String moodEmoji, String moodLabel, String toneTag) async {
    if (_userId == null) return;
    try {
      final response = await ApiService.put('/journals/$id', {
        'userId': _userId,
        'title': title,
        'content': content,
        'moodEmoji': moodEmoji,
        'moodLabel': moodLabel,
        'toneTag': toneTag,
      });
      if (response.statusCode == 200) {
        _fetchEntries();
      }
    } catch (e) {
      // Update error ignored
    }
  }

  Future<void> _deleteEntry(String id) async {
    if (_userId == null) return;
    try {
      final response = await ApiService.delete('/journals/$id/$_userId');
      if (response.statusCode == 200) {
        _fetchEntries();
      }
    } catch (e) {
      // Delete error ignored
    }
  }

  // ─── AI Tone Analysis via Anthropic ────────────────────────────────────────

  // ─── Analisis Nada Lokal (keyword matching) ──────────────────────────────────
  //
  // Cara kerja:
  //  1. Teks di-lowercase
  //  2. Tiap kategori punya daftar kata kunci bahasa Indonesia
  //  3. Hitung berapa kata kunci yang cocok per kategori
  //  4. Kategori dengan skor tertinggi menang
  //  5. Seri / tidak ada yang cocok → "Campur aduk 🌊"
  //
  Future<_ToneMeta> _analyzeTone(String text) async {
    final lower = text.toLowerCase();

    final Map<String, List<String>> keywords = {
      'Tenang 🌿': [
        'tenang', 'damai', 'nyaman', 'rileks', 'santai', 'aman', 'adem',
        'istirahat', 'tidur', 'rehat', 'kalem', 'hening', 'sepi', 'sunyi',
        'diam', 'duduk', 'napas', 'nafas', 'slow', 'pelan',
      ],
      'Berat 🌧': [
        'berat', 'lelah', 'capek', 'penat', 'overwhelmed', 'tekanan',
        'beban', 'sulit', 'susah', 'payah', 'nggak kuat', 'tidak kuat',
        'deadline', 'numpuk', 'menumpuk', 'melelahkan', 'kewalahan',
        'terpuruk', 'tertekan', 'burnout', 'exhausted',
      ],
      'Bersyukur ☀️': [
        'syukur', 'bersyukur', 'terima kasih', 'makasih', 'beruntung',
        'lega', 'senang', 'gembira', 'happy', 'suka', 'seru',
        'menyenangkan', 'indah', 'bagus', 'luar biasa', 'terharu',
        'bangga', 'hangat', 'berarti', 'bermakna',
      ],
      'Cemas 🌀': [
        'cemas', 'khawatir', 'anxiety', 'gelisah', 'was-was', 'takut',
        'gugup', 'grogi', 'panik', 'resah', 'tidak tenang', 'nggak tenang',
        'gemetar', 'deg-degan', 'nervous', 'overthinking', 'ragu', 'bingung', 'galau',
      ],
      'Semangat ⚡': [
        'semangat', 'energi', 'produktif', 'excited', 'antusias',
        'termotivasi', 'motivasi', 'bisa', 'mampu', 'siap', 'optimis',
        'berhasil', 'sukses', 'goal', 'target', 'fokus', 'gas', 'yakin', 'percaya diri',
      ],
      'Sedih 🌑': [
        'sedih', 'nangis', 'menangis', 'air mata', 'sakit', 'perih',
        'kecewa', 'patah hati', 'kehilangan', 'rindu', 'kangen',
        'hampa', 'kosong', 'sendiri', 'lonely', 'ditinggal', 'gagal', 'menyesal',
      ],
    };

    String bestTag = 'Campur aduk 🌊';
    int bestScore = 0;
    int categoriesWithScore = 0;

    keywords.forEach((tag, words) {
      int score = words.where((w) => lower.contains(w)).length;
      if (score > 0) categoriesWithScore++;
      if (score > bestScore) {
        bestScore = score;
        bestTag = tag;
      }
    });

    // Jika skor rendah dan banyak kategori cocok → campur aduk
    if (bestScore <= 1 && categoriesWithScore >= 2) {
      bestTag = 'Campur aduk 🌊';
    }

    return _ToneMeta(bestTag, _colorForTag(bestTag));
  }

  Color _colorForTag(String tag) {
    if (tag.contains('Tenang')) return const Color(0xFFE4F0EB);
    if (tag.contains('Berat')) return const Color(0xFFE8EDF5);
    if (tag.contains('Bersyukur')) return const Color(0xFFFAF3E0);
    if (tag.contains('Cemas')) return const Color(0xFFF5EAE4);
    if (tag.contains('Semangat')) return const Color(0xFFEFF5E4);
    if (tag.contains('Sedih')) return const Color(0xFFEEEEF3);
    return const Color(0xFFEDE9E1);
  }

  // ─── Open write dialog ──────────────────────────────────────────────────────
  void _openWriteDialog({JurnalEntry? existing}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    int selectedMoodIdx = existing != null
        ? _moods.indexWhere((m) => m['label'] == existing.moodLabel)
        : 2;
    if (selectedMoodIdx < 0) selectedMoodIdx = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return Padding(
            padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
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

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.accentBg,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(Icons.edit_note_rounded,
                            size: 20, color: AppColors.hero),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            existing == null ? 'Tulis Jurnal Baru' : 'Edit Jurnal',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text1),
                          ),
                          Text(
                            _formatDate(DateTime.now()),
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.text3),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title field
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1),
                    decoration: InputDecoration(
                      hintText: 'Judul entri...',
                      hintStyle:
                      const TextStyle(color: AppColors.text3, fontSize: 15),
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Content field
                  TextField(
                    controller: contentCtrl,
                    maxLines: 6,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.text1,
                        height: 1.6),
                    decoration: InputDecoration(
                      hintText:
                      'Ceritakan harimu... Tidak ada yang menghakimi di sini.',
                      hintStyle:
                      const TextStyle(color: AppColors.text3, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.bg,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mood picker
                  const Text(
                    'Perasaanmu hari ini?',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_moods.length, (i) {
                      final mood = _moods[i];
                      final isSelected = selectedMoodIdx == i;
                      return GestureDetector(
                        onTap: () => setModal(() => selectedMoodIdx = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentBg
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.hero
                                  : AppColors.border2,
                              width: isSelected ? 1.5 : 0.8,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(mood['emoji']!,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 2),
                              Text(mood['label']!,
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.hero
                                          : AppColors.text3)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hero,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final title = titleCtrl.text.trim();
                        final content = contentCtrl.text.trim();
                        if (title.isEmpty || content.isEmpty) return;

                        Navigator.pop(ctx);
                        setState(() => _isLoading = true);

                        try {
                          // AI tone analysis
                          final tone = await _analyzeTone(content);

                          final mood = _moods[selectedMoodIdx];
                          if (existing != null) {
                            await _updateEntry(existing.id, title, content, mood['emoji']!, mood['label']!, tone.tag);
                          } else {
                            await _createEntry(title, content, mood['emoji']!, mood['label']!, tone.tag);
                          }

                          if (mounted) {
                            _showToneSnackbar(tone.tag);
                          }
                        } catch (e) {
                          debugPrint('Error saving entry: $e');
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      child: const Text('Simpan & Analisis Nada',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
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

  void _showToneSnackbar(String tag) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.hero,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nada hari ini terdeteksi: $tag',
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(JurnalEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus entri ini?',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text1)),
        content: const Text(
            'Entri jurnal ini akan dihapus secara permanen.',
            style: TextStyle(fontSize: 13, color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal',
                style: TextStyle(color: AppColors.text3)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteEntry(entry.id);
            },
            child: const Text('Hapus',
                style: TextStyle(
                    color: Color(0xFFD96B6B),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _relativeDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    return '${diff} hari lalu';
  }

  // ─── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_isLoading) _buildLoadingBanner(),
            Expanded(
              child: _entries.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: _entries.length,
                itemBuilder: (_, i) => _buildEntryCard(_entries[i]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWriteDialog(),
        backgroundColor: AppColors.hero,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text('Tulis Jurnal',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border2, width: 0.5)),
      ),
      child: Row(
        children: [
          // Back button
          if (widget.onBack != null)
            GestureDetector(
              onTap: widget.onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.accentBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: AppColors.hero),
              ),
            ),
          if (widget.onBack != null) const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jurnal Harian',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1)),
                Text('${_entries.length} entri tersimpan',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.text3)),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildLoadingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.accentBg,
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
              AlwaysStoppedAnimation<Color>(AppColors.hero),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Menganalisis nada emosional jurnal kamu...',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.hero,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(JurnalEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: () => _openDetailSheet(entry),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border2, width: 0.5),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: date + mood + tone tag
              Row(
                children: [
                  Text(
                    _relativeDate(entry.date),
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text3,
                        fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  // Mood badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(entry.moodEmoji,
                            style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(entry.moodLabel,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.hero)),
                      ],
                    ),
                  ),
                  // Tone tag (AI)
                  if (entry.toneTag.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: entry.toneColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.border2, width: 0.5),
                      ),
                      child: Text(
                        entry.toneTag,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text2),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),

              // Title
              Text(
                entry.title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1),
              ),
              const SizedBox(height: 6),

              // Content preview
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.text2,
                    height: 1.55),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 10),

              // Bottom row: date formatted + actions
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColors.text3),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(entry.date),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.text3),
                  ),
                  const Spacer(),
                  // Edit button
                  GestureDetector(
                    onTap: () => _openWriteDialog(existing: entry),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.text3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Delete button
                  GestureDetector(
                    onTap: () => _confirmDelete(entry),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline_rounded,
                          size: 16, color: AppColors.text3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetailSheet(JurnalEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (ctx, scrollCtrl) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
                children: [
                  // Handle
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
                  const SizedBox(height: 20),

                  // Date + mood + tone row
                  Row(
                    children: [
                      Text(
                        _formatDate(entry.date),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.text3),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(children: [
                          Text(entry.moodEmoji,
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(entry.moodLabel,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.hero)),
                        ]),
                      ),
                      if (entry.toneTag.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: entry.toneColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.border2, width: 0.5),
                          ),
                          child: Row(children: [
                            const Icon(Icons.auto_awesome_rounded,
                                size: 10, color: AppColors.text2),
                            const SizedBox(width: 4),
                            Text(entry.toneTag,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text2)),
                          ]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    entry.title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1,
                        height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),

                  // Full content
                  Text(
                    entry.content,
                    style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.text1,
                        height: 1.75),
                  ),
                  const SizedBox(height: 28),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openWriteDialog(existing: entry);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 15),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.hero,
                            side: const BorderSide(
                                color: AppColors.border2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _confirmDelete(entry);
                          },
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 15),
                          label: const Text('Hapus'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD96B6B),
                            side: const BorderSide(
                                color: Color(0xFFD96B6B),
                                width: 0.8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.accentBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_note_rounded,
                  size: 36, color: AppColors.hero),
            ),
            const SizedBox(height: 20),
            const Text('Belum ada entri jurnal',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1)),
            const SizedBox(height: 8),
            const Text(
              'Mulai tulis hari ini.\nSemua cerita di sini hanya milikmu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppColors.text3, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}