import 'package:flutter/material.dart';
import 'dart:async';
import 'chat_store.dart';

// ─── Warna selaras dashboard ──────────────────────────────────────────────────
class _C {
  static const bg       = Color(0xFFEDE9E1);
  static const card     = Color(0xFFF7F5F0);
  static const hero     = Color(0xFF3D5A52);
  static const accentBg = Color(0xFFD6E5E0);
  static const text1    = Color(0xFF1C201E);
  static const text3    = Color(0xFF9AA09C);
  static const border2  = Color(0x383D5A52);
}

// ─── Model Pesan ──────────────────────────────────────────────────────────────
class _Msg {
  final String text;
  final bool isMe;
  final DateTime time;
  _Msg({required this.text, required this.isMe, required this.time});
}

// ─── Halaman Sesi Konsultasi ──────────────────────────────────────────────────
class SesiKonsultasiPage extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String sessionType;
  final IconData doctorIcon;
  final List<ChatMessage>? existingMessages;
  final String? sessionId;

  const SesiKonsultasiPage({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.sessionType,
    this.doctorIcon = Icons.psychology_rounded,
    this.existingMessages,
    this.sessionId,
  });

  @override
  State<SesiKonsultasiPage> createState() => _SesiKonsultasiPageState();
}

class _SesiKonsultasiPageState extends State<SesiKonsultasiPage>
    with TickerProviderStateMixin {

  // ── Chat state ──────────────────────────────────────────────────────────────
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_Msg> _messages = [];
  bool _typing = false;
  late final String _sessionId;

  // ── Video call state ────────────────────────────────────────────────────────
  bool _micOn  = true;
  bool _camOn  = true;
  bool _spkOn  = true;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  // ── Session timer (45 min) ──────────────────────────────────────────────────
  late AnimationController _pulseCtrl;

  // Static auto-reply pool
  static const _autoReplies = [
    'Halo! Saya siap mendengarkan kamu. Apa yang ingin kamu ceritakan hari ini?',
    'Terima kasih sudah terbuka. Bisa ceritakan lebih lanjut tentang perasaan itu?',
    'Saya memahami perasaanmu. Itu adalah hal yang wajar untuk dirasakan.',
    'Apakah ada hal tertentu yang membuatmu merasa seperti itu belakangan ini?',
    'Kamu sudah melakukan hal yang berani dengan mencari bantuan. Itu langkah yang tepat.',
    'Bagaimana pola tidurmu akhir-akhir ini? Apakah ada perubahan?',
    'Coba tarik napas perlahan. Kita hadapi ini bersama-sama.',
  ];
  int _replyIdx = 0;

  @override
  void initState() {
    super.initState();
    // Gunakan sessionId dari luar jika ada (buka ulang sesi lama)
    _sessionId = widget.sessionId ?? '${widget.doctorName}_${DateTime.now().millisecondsSinceEpoch}';

    // Muat pesan lama jika ada
    if (widget.existingMessages != null) {
      _messages.addAll(widget.existingMessages!.map((m) => _Msg(
        text: m.text, isMe: m.isMe, time: m.time,
      )));
    }

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    if (widget.sessionType == 'chat') {
      // Pesan sambutan dari dokter
      Future.delayed(const Duration(milliseconds: 800), () {
        _addDoctorMsg(_autoReplies[0]);
        _replyIdx = 1;
      });
    } else {
      // Timer video call
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed += const Duration(seconds: 1));
      });
    }
  }

  @override
  void dispose() {
    // Simpan sesi ke ChatStore sebelum dispose (hanya untuk mode chat)
    if (widget.sessionType == 'chat' && _messages.isNotEmpty) {
      ChatStore.instance.saveSession(ChatSession(
        id: _sessionId,
        doctorName: widget.doctorName,
        specialty: widget.specialty,
        doctorIcon: widget.doctorIcon,
        startedAt: DateTime.now(),
        messages: _messages.map((m) => ChatMessage(
          text: m.text,
          isMe: m.isMe,
          time: m.time,
        )).toList(),
      ));
    }
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _pulseCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _addDoctorMsg(String text) {
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add(_Msg(text: text, isMe: false, time: DateTime.now()));
    });
    _scrollToBottom();
  }

  void _sendMessage() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Msg(text: text, isMe: true, time: DateTime.now()));
      _textCtrl.clear();
      _typing = true;
    });
    _scrollToBottom();

    // Simulate doctor reply after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      final reply = _autoReplies[_replyIdx % _autoReplies.length];
      _replyIdx++;
      _addDoctorMsg(reply);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveAndPop(context);
      },
      child: widget.sessionType == 'chat'
          ? _buildChatPage(context)
          : _buildVideoCallPage(context),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CHAT UI
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildChatPage(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildChatHeader(context),
            Expanded(
              child: _messages.isEmpty
                  ? _buildChatEmpty()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: _messages.length + (_typing ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_typing && i == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        return _buildBubble(_messages[i]);
                      },
                    ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: _C.card,
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _saveAndPop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.border2, width: 0.8),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: _C.text1),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(color: _C.accentBg, shape: BoxShape.circle),
            child: Center(child: Icon(widget.doctorIcon, color: _C.hero, size: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.text1)),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, __) => Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(const Color(0xFF4CAF50), const Color(0xFF81C784), _pulseCtrl.value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text('Online · Sesi Chat', style: TextStyle(fontSize: 11, color: _C.text3)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _C.accentBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _C.border2),
            ),
            child: const Text('45 Menit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _C.hero)),
          ),
        ],
      ),
    );
  }

  Widget _buildChatEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: _C.accentBg, shape: BoxShape.circle),
            child: Icon(widget.doctorIcon, color: _C.hero, size: 40),
          ),
          const SizedBox(height: 16),
          Text(widget.doctorName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.text1)),
          const SizedBox(height: 6),
          const Text('Sedang menyiapkan sesi konsultasimu...', style: TextStyle(fontSize: 13, color: _C.text3)),
        ],
      ),
    );
  }

  Widget _buildBubble(_Msg msg) {
    final isMe = msg.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 30, height: 30,
              decoration: const BoxDecoration(color: _C.accentBg, shape: BoxShape.circle),
              child: Center(child: Icon(widget.doctorIcon, color: _C.hero, size: 15)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? _C.hero : _C.card,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(msg.text,
                    style: TextStyle(fontSize: 14, color: isMe ? Colors.white : _C.text1, height: 1.4)),
                  const SizedBox(height: 4),
                  Text(
                    '${msg.time.hour.toString().padLeft(2,'0')}:${msg.time.minute.toString().padLeft(2,'0')}',
                    style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : _C.text3),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 15,
              backgroundColor: _C.accentBg,
              child: Icon(Icons.person_rounded, color: _C.hero, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Container(
          width: 30, height: 30,
          decoration: const BoxDecoration(color: _C.accentBg, shape: BoxShape.circle),
          child: Center(child: Icon(widget.doctorIcon, color: _C.hero, size: 15)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => _Dot(delay: i * 200)),
          ),
        ),
      ],
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: _C.card,
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _C.border2, width: 0.8),
              ),
              child: TextField(
                controller: _textCtrl,
                style: const TextStyle(fontSize: 14, color: _C.text1),
                decoration: const InputDecoration(
                  hintText: 'Ketik pesanmu...',
                  hintStyle: TextStyle(color: _C.text3),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _C.hero,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _C.hero.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VIDEO CALL UI
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildVideoCallPage(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: Stack(
        children: [
          // Latar "video" dokter (simulasi)
          Positioned.fill(child: _buildDoctorVideoFeed()),

          // Self preview (pojok kanan atas)
          Positioned(top: 60, right: 16, child: _buildSelfPreview()),

          // Header
          Positioned(top: 0, left: 0, right: 0, child: _buildVideoHeader(context)),

          // Controls
          Positioned(bottom: 0, left: 0, right: 0, child: _buildVideoControls(context)),
        ],
      ),
    );
  }

  Widget _buildDoctorVideoFeed() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2A3A), Color(0xFF0D1F2D)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: 110 + _pulseCtrl.value * 6,
                height: 110 + _pulseCtrl.value * 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2A4A5A),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF3D5A52).withValues(alpha: 0.4 + _pulseCtrl.value * 0.2),
                    blurRadius: 30, spreadRadius: 5,
                  )],
                ),
                child: Center(
                  child: Icon(widget.doctorIcon, color: Colors.white.withValues(alpha: 0.85), size: 54),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.doctorName,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(widget.specialty,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfPreview() {
    return SafeArea(
      child: Container(
        width: 100, height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2E3A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_rounded, color: Colors.white54, size: 40),
              const SizedBox(height: 8),
              Text(_camOn ? 'Kamera Aktif' : 'Kamera Mati',
                style: const TextStyle(color: Colors.white38, fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Color(0xFF4CAF50), size: 8),
                  const SizedBox(width: 6),
                  Text(_formatDuration(_elapsed),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Sesi 45 Menit', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xCC000000), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _videoBtn(
            icon: _micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
            label: _micOn ? 'Mikrofon' : 'Bisu',
            active: _micOn,
            onTap: () => setState(() => _micOn = !_micOn),
          ),
          _videoBtn(
            icon: _camOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
            label: _camOn ? 'Kamera' : 'Kamera Mati',
            active: _camOn,
            onTap: () => setState(() => _camOn = !_camOn),
          ),
          _videoBtn(
            icon: _spkOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            label: _spkOn ? 'Speaker' : 'Hening',
            active: _spkOn,
            onTap: () => setState(() => _spkOn = !_spkOn),
          ),
          // End call button
          GestureDetector(
            onTap: () => _saveAndPop(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 6),
                const Text('Akhiri', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoBtn({required IconData icon, required String label, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: active ? Colors.white24 : Colors.white10,
              shape: BoxShape.circle,
              border: Border.all(color: active ? Colors.white30 : Colors.white12, width: 1),
            ),
            child: Icon(icon, color: active ? Colors.white : Colors.white38, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }

  // ── Simpan & Kembali ───────────────────────────────────────────────────────
  void _saveAndPop(BuildContext context) {
    Navigator.of(context).pop();
  }
}

// ─── Animasi Titik Typing ──────────────────────────────────────────────────────
class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, -4 * _anim.value),
          child: Container(
            width: 7, height: 7,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _C.text3),
          ),
        ),
      ),
    );
  }
}
