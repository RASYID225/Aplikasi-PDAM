import 'package:flutter/material.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class KelolaData extends StatelessWidget {
  const KelolaData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Kelola Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1A1A2E))),
        backgroundColor: const Color(0xFFF4F7FE),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const BottomNav(1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih kategori data yang ingin dikelola', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              _menuCard(context, icon: Icons.people_alt_rounded, title: 'Kelola Pelanggan', subtitle: 'Tambah, edit, dan hapus data pelanggan', color: const Color(0xFF0052D4), route: '/KelolaPelanggan'),
              const SizedBox(height: 16),
              _menuCard(context, icon: Icons.water_drop_rounded, title: 'Kelola Layanan', subtitle: 'Atur tarif dan kategori layanan air', color: const Color(0xFF4364F7), route: '/KelolaLayanan'),
              const SizedBox(height: 16),
              _menuCard(context, icon: Icons.receipt_long_rounded, title: 'Kelola Tagihan', subtitle: 'Buat dan verifikasi tagihan pelanggan', color: const Color(0xFF6FB1FC), route: '/KelolaTagihan'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required String route}) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 28),
          ],
        ),
      ),
    );
  }
}