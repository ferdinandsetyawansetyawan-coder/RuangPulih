import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  bool _isLoading = true;
  List<dynamic> _moods = [];

  @override
  void initState() {
    super.initState();
    _fetchAktivitas();
  }

  Future<void> _fetchAktivitas() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('user_data');
    final token = prefs.getString('token');

    if (userDataStr != null && token != null) {
      final userData = jsonDecode(userDataStr);
      final userId = userData['id'];

      try {
        final response = await http.get(
          Uri.parse('${ApiService.baseUrl}/moods/user/$userId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _moods = data;
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      final padHour = date.hour.toString().padLeft(2, '0');
      final padMin = date.minute.toString().padLeft(2, '0');
      return '${date.day} ${months[date.month - 1]} ${date.year}, $padHour:$padMin';
    } catch (e) {
      return dateStr;
    }
  }

  Color _getMoodColor(String label) {
    switch (label.toLowerCase()) {
      case 'bahagia':
        return const Color(0xFFF2C94C); // Yellow/Orange
      case 'baik':
        return const Color(0xFF6FCF97); // Green
      case 'sedih':
        return const Color(0xFF56CCF2); // Blue
      case 'cemas':
        return const Color(0xFFF2994A); // Orange
      case 'biasa':
      default:
        return const Color(0xFF3D5A52); // Default hero
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE9E1),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D5A52)))
                  : _moods.isEmpty
                      ? _buildEmptyState()
                      : _buildTimeline(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E4A42), Color(0xFF4E7A6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aktivitas Kamu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.insights_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Pantau terus riwayat perasaanmu setiap hari. Memahami diri sendiri adalah langkah pertama menuju ketenangan.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
              height: 1.5,
            ),
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
          Icon(Icons.history_rounded, size: 80, color: const Color(0xFF3D5A52).withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Belum ada aktivitas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4E5552))),
          const SizedBox(height: 8),
          const Text('Bagaimana perasaanmu hari ini?\nIsi di beranda yuk!', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9AA09C))),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      itemCount: _moods.length,
      itemBuilder: (context, index) {
        final mood = _moods[index];
        final bool isFirst = index == 0;
        final bool isLast = index == _moods.length - 1;
        final moodColor = _getMoodColor(mood['label'] ?? '');
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line and dot
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 2,
                      height: 20,
                      color: isFirst ? Colors.transparent : const Color(0x383D5A52),
                    ),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isFirst ? moodColor : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: moodColor, width: 3),
                        boxShadow: isFirst ? [
                          BoxShadow(
                            color: moodColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ] : null,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isLast ? Colors.transparent : const Color(0x383D5A52),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D5A52).withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: isFirst ? Border.all(color: moodColor.withOpacity(0.5), width: 1.5) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: moodColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              mood['emoji'] ?? '😐',
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Merasa ${mood['label'] ?? 'Biasa'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1C201E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded, size: 14, color: moodColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(mood['createdAt']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4E5552),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
