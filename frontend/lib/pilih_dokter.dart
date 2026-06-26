import 'package:flutter/material.dart';
import 'pembayaran.dart';

// Warna sama persis dengan dashboard.dart
class _C {
  static const bg      = Color(0xFFEDE9E1);
  static const card    = Color(0xFFF7F5F0);
  static const hero    = Color(0xFF3D5A52);
  static const accentBg = Color(0xFFD6E5E0);
  static const text1   = Color(0xFF1C201E);
  static const text2   = Color(0xFF4E5552);
  static const text3   = Color(0xFF9AA09C);
  static const border  = Color(0x1F3D5A52);
  static const border2 = Color(0x383D5A52);
}

class Doctor {
  final String name;
  final String specialty;
  final String experience;
  final double rating;
  final String price;
  final IconData icon;

  const Doctor({
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.price,
    required this.icon,
  });
}

const List<Doctor> _doctors = [
  Doctor(name: 'Dr. Andi Santoso, Sp.KJ', specialty: 'Psikiater Dewasa',   experience: '10 Tahun', rating: 4.9, price: 'Rp 250.000', icon: Icons.psychology_rounded),
  Doctor(name: 'Dra. Rina Melati, M.Psi', specialty: 'Psikolog Klinis',    experience: '8 Tahun',  rating: 4.8, price: 'Rp 200.000', icon: Icons.spa_rounded),
  Doctor(name: 'Dr. Budi Setiawan, Sp.KJ', specialty: 'Psikiater Anak',    experience: '12 Tahun', rating: 5.0, price: 'Rp 300.000', icon: Icons.child_care_rounded),
  Doctor(name: 'Dr. Clara Monica, M.Psi', specialty: 'Konselor Pernikahan', experience: '5 Tahun',  rating: 4.7, price: 'Rp 150.000', icon: Icons.favorite_rounded),
];

class PilihDokterPage extends StatelessWidget {
  const PilihDokterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Temukan profesional yang tepat untukmu',
                  style: const TextStyle(fontSize: 13, color: _C.text3),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                itemCount: _doctors.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, i) => _DoctorCard(doctor: _doctors[i]),
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
          // Back button — gaya sama dengan dashboard cards
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
              Text(
                'Pilih Dokter',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _C.text1,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final Doctor doctor;
  const _DoctorCard({required this.doctor});

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konsultasi dengan ${doc.name} belum tersedia'),
            backgroundColor: _C.hero,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border2, width: 0.8),
            boxShadow: const [
              BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                // Baris atas: Avatar + Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: _C.accentBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: _C.border2, width: 1),
                      ),
                      child: Center(child: Icon(doc.icon, color: _C.hero, size: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.text1),
                          ),
                          const SizedBox(height: 5),
                          // Specialty chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: _C.accentBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _C.border2, width: 0.8),
                            ),
                            child: Text(doc.specialty, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _C.hero)),
                          ),
                          const SizedBox(height: 8),
                          // Rating & Pengalaman
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 15),
                              const SizedBox(width: 3),
                              Text(doc.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _C.text1)),
                              const SizedBox(width: 12),
                              const Icon(Icons.work_history_rounded, color: _C.text3, size: 14),
                              const SizedBox(width: 4),
                              Text(doc.experience, style: const TextStyle(fontSize: 12, color: _C.text2, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Divider
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: _C.border, height: 1),
                ),

                // Baris bawah: Harga + Tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sesi 45 Menit', style: TextStyle(fontSize: 11, color: _C.text3, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(doc.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _C.text1)),
                      ],
                    ),
                    _KonsultasiButton(doctorName: doc.name, price: doc.price, specialty: doc.specialty, icon: doc.icon),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KonsultasiButton extends StatefulWidget {
  final String doctorName;
  final String price;
  final String specialty;
  final IconData icon;
  const _KonsultasiButton({required this.doctorName, required this.price, required this.specialty, required this.icon});

  @override
  State<_KonsultasiButton> createState() => _KonsultasiButtonState();
}

class _KonsultasiButtonState extends State<_KonsultasiButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PembayaranPage(
                doctorName: widget.doctorName,
                price: widget.price,
                specialty: widget.specialty,
                doctorIcon: widget.icon,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF2E4A42) : _C.hero,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _C.hero.withValues(alpha: _hovered ? 0.35 : 0.18),
                blurRadius: _hovered ? 14 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'Konsultasi',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.2),
          ),
        ),
      ),
    );
  }
}
