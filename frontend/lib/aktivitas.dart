import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

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

class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  bool _isLoading = true;
  int _totalJurnal = 0;
  int _totalHabit = 0;
  int _totalForum = 0;
  List<Map<String, dynamic>> _recentActivities = [];
  
  String _dominantMoodEmoji = '😐';
  String _dominantMoodLabel = 'Biasa';
  String _moodMessage = 'Belum ada data mood, yuk catat perasaanmu!';

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    if (userDataStr == null) {
      setState(() => _isLoading = false);
      return;
    }

    final userData = jsonDecode(userDataStr);
    final userId = userData['id'];

    try {
      final futures = await Future.wait([
        ApiService.get('/journals/user/$userId'),
        ApiService.get('/habits?userId=$userId'),
        ApiService.get('/forum?authorId=$userId'),
        ApiService.get('/moods/user/$userId'),
      ]);

      int jurnalCount = 0;
      int habitCount = 0;
      int forumCount = 0;
      List<Map<String, dynamic>> allActivities = [];

      // Journals
      if (futures[0].statusCode == 200) {
        final List jList = jsonDecode(futures[0].body);
        jurnalCount = jList.length;
        for (var j in jList) {
          allActivities.add({
            'type': 'Jurnal Harian',
            'title': j['title'] ?? 'Tanpa Judul',
            'desc': 'Menulis jurnal dengan mood ${j['moodEmoji']}',
            'date': DateTime.parse(j['createdAt']),
            'icon': Icons.edit_note_rounded,
          });
        }
      }

      // Habits
      if (futures[1].statusCode == 200) {
        final List hList = jsonDecode(futures[1].body);
        habitCount = hList.length;
        for (var h in hList) {
          DateTime date = DateTime.now();
          if (h['createdAt'] != null) {
            date = DateTime.parse(h['createdAt']);
          }
          allActivities.add({
            'type': 'Habit Tracker',
            'title': '${h['emoji']} ${h['title']}',
            'desc': 'Membuat kebiasaan baru',
            'date': date,
            'icon': Icons.check_circle_outline_rounded,
          });
        }
      }

      // Forum
      if (futures[2].statusCode == 200) {
        final List fList = jsonDecode(futures[2].body);
        forumCount = fList.length;
        for (var f in fList) {
          allActivities.add({
            'type': 'Forum Anonim',
            'title': f['category'] ?? 'Tanpa Kategori',
            'desc': f['content'],
            'date': DateTime.parse(f['createdAt']),
            'icon': Icons.people_outline_rounded,
          });
        }
      }
      
      // Moods
      String dominantEmoji = '😐';
      String dominantLabel = 'Biasa';
      String moodMessage = 'Belum ada data mood, yuk catat perasaanmu!';

      if (futures[3].statusCode == 200) {
        final List mList = jsonDecode(futures[3].body);
        if (mList.isNotEmpty) {
          Map<String, int> moodCounts = {};
          Map<String, String> moodEmojis = {};
          
          for (var m in mList) {
            String label = m['label'] ?? 'Biasa';
            String emoji = m['emoji'] ?? '😐';
            moodCounts[label] = (moodCounts[label] ?? 0) + 1;
            moodEmojis[label] = emoji;
            
            // Tambahkan mood ke activity feed
            allActivities.add({
              'type': 'Quick Mood Check',
              'title': 'Merasa $label $emoji',
              'desc': 'Mencatat perasaan hari ini.',
              'date': DateTime.parse(m['createdAt']),
              'icon': Icons.mood_rounded,
            });
          }
          
          int maxCount = 0;
          moodCounts.forEach((label, count) {
            if (count > maxCount) {
              maxCount = count;
              dominantLabel = label;
            }
          });
          
          dominantEmoji = moodEmojis[dominantLabel] ?? '😐';
          
          if (dominantLabel == 'Sedih' || dominantLabel == 'Cemas') {
            moodMessage = 'Sepertinya hari-harimu akhir-akhir ini cukup berat ya. Peluk jauh, tetap semangat!';
          } else if (dominantLabel == 'Bahagia' || dominantLabel == 'Baik') {
            moodMessage = 'Luar biasa! Kamu memancarkan energi positif. Pertahankan terus ya!';
          } else {
            moodMessage = 'Mood kamu cukup stabil akhir-akhir ini. Tidak terlalu buruk, kan?';
          }
        }
      }

      allActivities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      if (mounted) {
        setState(() {
          _dominantMoodEmoji = dominantEmoji;
          _dominantMoodLabel = dominantLabel;
          _moodMessage = moodMessage;
          
          _totalJurnal = jurnalCount;
          _totalHabit = habitCount;
          _totalForum = forumCount;
          _recentActivities = allActivities.take(15).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} menit yang lalu';
      }
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 20, 22, 10),
            child: Text(
              'Aktifitas Kamu',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text1,
                  letterSpacing: -0.5),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 22, 20),
            child: Text(
              'Ringkasan perjalananmu di RuangPulih',
              style: TextStyle(fontSize: 13, color: AppColors.text3),
            ),
          ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.hero),
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.hero,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.hero.withOpacity(0.3), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(_dominantMoodEmoji, style: const TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rata-rata Mood Kamu', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(_dominantMoodLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(_moodMessage, style: const TextStyle(fontSize: 12, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Jurnal',
                      count: _totalJurnal,
                      icon: Icons.edit_note_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Habit',
                      count: _totalHabit,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Forum',
                      count: _totalForum,
                      icon: Icons.people_outline_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'Riwayat Terbaru',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text1),
              ),
            ),
            const SizedBox(height: 12),
            if (_recentActivities.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada aktifitas yang tercatat.\nMulai tulis jurnal atau bangun kebiasaanmu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.text3),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                itemCount: _recentActivities.length,
                itemBuilder: (ctx, i) {
                  final act = _recentActivities[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.hero.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(act['icon'], color: AppColors.hero, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(act['type'],
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.hero)),
                                  Text(_formatDate(act['date']),
                                      style: const TextStyle(
                                          fontSize: 10, color: AppColors.text3)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(act['title'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text1)),
                              const SizedBox(height: 4),
                              Text(act['desc'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.text2,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.hero, size: 26),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.text1),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.text3),
          ),
        ],
      ),
    );
  }
}