import 'package:flutter/material.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class KelolaData extends StatelessWidget {
  const KelolaData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: const BottomNav(1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kelola Data', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              const Text('Pilih kategori data yang ingin dikelola', style: TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 24),
              _menuCard(context, icon: Icons.people_alt_outlined, title: 'Kelola Pelanggan', subtitle: 'Tambah, edit, dan hapus data pelanggan', color: const Color(0xFF144B80), route: '/KelolaPelanggan'),
              const SizedBox(height: 14),
              _menuCard(context, icon: Icons.water_drop_outlined, title: 'Kelola Layanan', subtitle: 'Atur tarif dan kategori layanan air', color: const Color(0xFF0369A1), route: '/KelolaLayanan'),
              const SizedBox(height: 14),
              _menuCard(context, icon: Icons.receipt_long_outlined, title: 'Kelola Tagihan', subtitle: 'Buat dan verifikasi tagihan pelanggan', color: const Color(0xFF047857), route: '/KelolaTagihan'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required String route}) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}