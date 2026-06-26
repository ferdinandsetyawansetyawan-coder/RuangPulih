import 'package:flutter/material.dart';
import 'sesi_konsultasi.dart';

// ─── Warna selaras dengan dashboard ───────────────────────────────────────────
class _C {
  static const bg       = Color(0xFFEDE9E1);
  static const card     = Color(0xFFF7F5F0);
  static const hero     = Color(0xFF3D5A52);
  static const accentBg = Color(0xFFD6E5E0);
  static const text1    = Color(0xFF1C201E);
  static const text3    = Color(0xFF9AA09C);
  static const border   = Color(0x1F3D5A52);
  static const border2  = Color(0x383D5A52);
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _PayMethod {
  final String id;
  final String name;
  final String subtitle;
  final Color  brandColor;
  final Color  bgColor;
  final Widget logo;

  const _PayMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.brandColor,
    required this.bgColor,
    required this.logo,
  });
}

// ─── Logo Builders ────────────────────────────────────────────────────────────

// OVO – ungu
Widget _ovoLogo() => Container(
  width: 52, height: 52,
  decoration: BoxDecoration(
    color: const Color(0xFF4C2A86),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Center(
    child: Text('OVO',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
  ),
);

// DANA – biru
Widget _danaLogo() => Container(
  width: 52, height: 52,
  decoration: BoxDecoration(
    color: const Color(0xFF118EEA),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Center(
    child: Text('DANA',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
  ),
);

// GoPay – hijau-biru
Widget _gopayLogo() => Container(
  width: 52, height: 52,
  decoration: BoxDecoration(
    color: const Color(0xFF00AED6),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
      Text('Go', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, height: 1.1)),
      Text('Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, height: 1.1)),
    ]),
  ),
);

// ShopeePay – oranye
Widget _shopeepayLogo() => Container(
  width: 52, height: 52,
  decoration: BoxDecoration(
    color: const Color(0xFFEE4D2D),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
      Text('Shopee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 7.5, height: 1.1)),
      Text('Pay',    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10, height: 1.1)),
    ]),
  ),
);

// BCA VA – biru navy
Widget _bcaLogo() => Container(
  width: 52, height: 52,
  decoration: BoxDecoration(
    color: const Color(0xFF003D82),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Center(
    child: Text('BCA',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
  ),
);

// Mandiri VA – kuning-biru
Widget _mandiriLogo() => Container(
  width: 52, height: 52,
  decoration: BoxDecoration(
    color: const Color(0xFF003087),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Center(
    child: Text('mdri',
      style: const TextStyle(color: Color(0xFFF5A623), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
  ),
);

// BNI VA – oranye
Widget _bniLogo() => Container(
  width: 52, height: 52,
  decoration: BoxDecoration(
    color: const Color(0xFFFF6600),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Center(
    child: Text('BNI',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
  ),
);

// BRI VA – biru tua
Widget _briLogo() => Container(
  width: 52, height: 52,
  decoration: BoxDecoration(
    color: const Color(0xFF005082),
    borderRadius: BorderRadius.circular(14),
  ),
  child: Center(
    child: Text('BRI',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
  ),
);

// ─── Data ─────────────────────────────────────────────────────────────────────
List<Map<String, dynamic>> _buildPayGroups() => [
  {
    'label': 'Dompet Digital',
    'icon': Icons.account_balance_wallet_rounded,
    'methods': [
      _PayMethod(id: 'ovo',       name: 'OVO',       subtitle: 'Bayar dengan saldo OVO',       brandColor: const Color(0xFF4C2A86), bgColor: const Color(0xFFF3EDFF), logo: _ovoLogo()),
      _PayMethod(id: 'dana',      name: 'DANA',      subtitle: 'Bayar dengan saldo DANA',      brandColor: const Color(0xFF118EEA), bgColor: const Color(0xFFE8F4FF), logo: _danaLogo()),
      _PayMethod(id: 'gopay',     name: 'GoPay',     subtitle: 'Bayar dengan saldo GoPay',     brandColor: const Color(0xFF00AED6), bgColor: const Color(0xFFE5F8FC), logo: _gopayLogo()),
      _PayMethod(id: 'shopeepay', name: 'ShopeePay', subtitle: 'Bayar dengan saldo ShopeePay', brandColor: const Color(0xFFEE4D2D), bgColor: const Color(0xFFFFF0EE), logo: _shopeepayLogo()),
    ],
  },
  {
    'label': 'Virtual Account Bank',
    'icon': Icons.account_balance_rounded,
    'methods': [
      _PayMethod(id: 'va_bca',     name: 'BCA Virtual Account',     subtitle: 'Transfer antar-bank BCA',     brandColor: const Color(0xFF003D82), bgColor: const Color(0xFFE8EEF8), logo: _bcaLogo()),
      _PayMethod(id: 'va_mandiri', name: 'Mandiri Virtual Account', subtitle: 'Transfer antar-bank Mandiri', brandColor: const Color(0xFF003087), bgColor: const Color(0xFFE8EEF8), logo: _mandiriLogo()),
      _PayMethod(id: 'va_bni',     name: 'BNI Virtual Account',     subtitle: 'Transfer antar-bank BNI',     brandColor: const Color(0xFFFF6600), bgColor: const Color(0xFFFFF2EA), logo: _bniLogo()),
      _PayMethod(id: 'va_bri',     name: 'BRI Virtual Account',     subtitle: 'Transfer antar-bank BRI',     brandColor: const Color(0xFF005082), bgColor: const Color(0xFFE5EEF5), logo: _briLogo()),
    ],
  },
];

// ─── Halaman Pembayaran ───────────────────────────────────────────────────────
class PembayaranPage extends StatefulWidget {
  final String doctorName;
  final String price;
  final String specialty;
  final IconData doctorIcon;

  const PembayaranPage({
    super.key,
    required this.doctorName,
    required this.price,
    required this.specialty,
    this.doctorIcon = Icons.psychology_rounded,
  });

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  String? _selectedId;
  String _sessionType = 'chat'; // 'chat' | 'videocall'

  @override
  Widget build(BuildContext context) {
    final groups = _buildPayGroups();

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildOrderSummary(),
                  const SizedBox(height: 20),
                  _buildSessionTypePicker(),
                  const SizedBox(height: 20),
                  ...groups.map((g) => _buildGroup(g)),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating Pay Button
      bottomSheet: _buildBottomBar(context),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pembayaran',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _C.text1, letterSpacing: -0.5)),
              Text('Pilih metode bayar',
                style: TextStyle(fontSize: 12, color: _C.text3)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Ringkasan Pesanan ─────────────────────────────────────────────────────
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.accentBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border2, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _C.hero, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Ringkasan Pesanan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.text1)),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _C.border, height: 1),
          const SizedBox(height: 14),
          _row('Dokter',        widget.doctorName),
          const SizedBox(height: 6),
          _row('Spesialisasi',  widget.specialty),
          const SizedBox(height: 6),
          _row('Durasi Sesi',   '45 Menit'),
          const SizedBox(height: 14),
          const Divider(color: _C.border, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.text1)),
              Text(widget.price,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _C.hero)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _C.text3, fontWeight: FontWeight.w500)),
        Flexible(
          child: Text(value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.text1)),
        ),
      ],
    );
  }

  // ── Grup Metode Bayar ─────────────────────────────────────────────────────
  Widget _buildGroup(Map<String, dynamic> group) {
    final methods = group['methods'] as List<_PayMethod>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(group['icon'] as IconData, size: 17, color: _C.hero),
            const SizedBox(width: 8),
            Text(group['label'] as String,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.text1)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.border2, width: 0.8),
            boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: methods.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: _C.border, indent: 20, endIndent: 20),
            itemBuilder: (_, i) => _buildMethodTile(methods[i]),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Tile Metode ───────────────────────────────────────────────────────────
  Widget _buildMethodTile(_PayMethod method) {
    final selected = _selectedId == method.id;
    return InkWell(
      onTap: () => setState(() => _selectedId = method.id),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? method.bgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            // Logo
            method.logo,
            const SizedBox(width: 14),
            // Name & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? method.brandColor : _C.text1,
                    )),
                  const SizedBox(height: 2),
                  Text(method.subtitle,
                    style: const TextStyle(fontSize: 11, color: _C.text3)),
                ],
              ),
            ),
            // Radio Circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? method.brandColor : Colors.transparent,
                border: Border.all(
                  color: selected ? method.brandColor : _C.text3,
                  width: selected ? 0 : 1.5,
                ),
              ),
              child: selected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    final enabled = _selectedId != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
      decoration: const BoxDecoration(
        color: _C.card,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!enabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('Pilih metode pembayaran terlebih dahulu',
                style: const TextStyle(fontSize: 12, color: _C.text3)),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AnimatedOpacity(
              opacity: enabled ? 1.0 : 0.45,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: enabled ? () => _onBayar(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.hero,
                  disabledBackgroundColor: _C.hero,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: enabled ? 4 : 0,
                  shadowColor: _C.hero.withValues(alpha: 0.35),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, size: 16),
                    const SizedBox(width: 8),
                    Text('Bayar ${widget.price}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Session Type Picker ────────────────────────────────────────────────────
  Widget _buildSessionTypePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.devices_rounded, size: 17, color: _C.hero),
          const SizedBox(width: 8),
          const Text('Jenis Sesi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.text1)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _SessionTypeCard(
            icon: Icons.chat_bubble_rounded,
            label: 'Chat',
            desc: 'Konsultasi lewat pesan teks',
            selected: _sessionType == 'chat',
            onTap: () => setState(() => _sessionType = 'chat'),
          )),
          const SizedBox(width: 12),
          Expanded(child: _SessionTypeCard(
            icon: Icons.videocam_rounded,
            label: 'Video Call',
            desc: 'Konsultasi tatap muka virtual',
            selected: _sessionType == 'videocall',
            onTap: () => setState(() => _sessionType = 'videocall'),
          )),
        ]),
      ],
    );
  }

  void _onBayar(BuildContext context) {
    // Langsung navigasi ke sesi konsultasi (simulasi pembayaran berhasil)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SesiKonsultasiPage(
          doctorName: widget.doctorName,
          specialty: widget.specialty,
          sessionType: _sessionType,
          doctorIcon: widget.doctorIcon,
        ),
      ),
    );
  }
}

// ─── Session Type Card Widget ─────────────────────────────────────────────────
class _SessionTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  const _SessionTypeCard({
    required this.icon,
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? _C.accentBg : _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _C.hero : _C.border2,
            width: selected ? 1.5 : 0.8,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _C.hero.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))]
              : const [BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected ? _C.hero : const Color(0xFFE8EDE9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: selected ? Colors.white : _C.text3, size: 18),
                ),
                if (selected) ...[
                  const Spacer(),
                  const Icon(Icons.check_circle_rounded, color: _C.hero, size: 18),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? _C.hero : _C.text1,
              )),
            const SizedBox(height: 3),
            Text(desc, style: const TextStyle(fontSize: 10, color: _C.text3, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

