import 'package:flutter/material.dart';
import 'chat_store.dart';
import 'sesi_konsultasi.dart';

class _C {
  static const bg       = Color(0xFFEDE9E1);
  static const card     = Color(0xFFF7F5F0);
  static const hero     = Color(0xFF3D5A52);
  static const accentBg = Color(0xFFD6E5E0);
  static const text1    = Color(0xFF1C201E);
  static const text2    = Color(0xFF4E5552);
  static const text3    = Color(0xFF9AA09C);
  static const border2  = Color(0x383D5A52);
}

class ChatDokterPage extends StatefulWidget {
  const ChatDokterPage({super.key});

  @override
  State<ChatDokterPage> createState() => _ChatDokterPageState();
}

class _ChatDokterPageState extends State<ChatDokterPage> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // refresh saat kembali ke halaman ini
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ChatStore.instance.sessions;

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: sessions.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: sessions.length,
                      itemBuilder: (_, i) => _buildSessionTile(context, sessions[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _C.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border2, width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: _C.text1, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Chat Dokter',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _C.text1, letterSpacing: -0.5)),
              Text('Riwayat konsultasi kamu',
                style: TextStyle(fontSize: 12, color: _C.text3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: _C.accentBg, shape: BoxShape.circle),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: _C.hero, size: 42),
          ),
          const SizedBox(height: 20),
          const Text('Belum ada sesi chat',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.text1)),
          const SizedBox(height: 8),
          const Text('Mulai konsultasi dengan dokter\nuntuk melihat riwayat chat di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _C.text3, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, ChatSession session) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SesiKonsultasiPage(
              doctorName: session.doctorName,
              specialty: session.specialty,
              sessionType: 'chat',
              doctorIcon: session.doctorIcon,
              existingMessages: session.messages,
              sessionId: session.id,
            ),
          ),
        );
        setState(() {}); // refresh setelah kembali agar pesan terbaru tampil
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border2, width: 0.8),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Row(
          children: [
            // Avatar dokter
            Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(color: _C.accentBg, shape: BoxShape.circle),
              child: Center(child: Icon(session.doctorIcon, color: _C.hero, size: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(session.doctorName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.text1),
                          overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        _formatTime(session.startedAt),
                        style: const TextStyle(fontSize: 11, color: _C.text3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(session.specialty,
                    style: const TextStyle(fontSize: 11, color: _C.hero, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      if (session.lastIsMe)
                        const Icon(Icons.done_all_rounded, size: 14, color: _C.hero),
                      if (session.lastIsMe) const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          session.lastMessage,
                          style: const TextStyle(fontSize: 12, color: _C.text2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: _C.text3, size: 20),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}
