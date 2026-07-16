import 'package:flutter/material.dart';
import 'package:pdam_apps/Models/User_login.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class ProfileCustomer extends StatefulWidget {
  const ProfileCustomer({super.key});
  @override
  State<ProfileCustomer> createState() => _ProfileCustomerState();
}

class _ProfileCustomerState extends State<ProfileCustomer> {
  bool _isLoading = true;
  String nama = '';
  String phone = '';
  String username = '';
  String alamat = '';
  String customerNumber = '';
  String layanan = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getCustomerProfile();
    if (!mounted) return;
    final data = res['data'] as Map? ?? {};
    final user = data['user'] as Map? ?? {};
    final service = data['service'] as Map? ?? {};
    setState(() {
      nama = data['name'] ?? '';
      phone = data['phone'] ?? '';
      alamat = data['address'] ?? '';
      customerNumber = data['customer_number'] ?? '';
      username = user['username'] ?? '';
      layanan = service['name'] ?? '';
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    await UserLogin.clearPrefs();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/LoginCustomer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      bottomNavigationBar: const BottomNav(2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4364F7)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- HEADER GRADIENT & AVATAR ---
                  Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0052D4), Color(0xFF4364F7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: const SafeArea(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: Text('Profil Saya', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFFF4F7FE), shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.white,
                            child: Text(
                              nama.isNotEmpty ? nama[0].toUpperCase() : 'P',
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0052D4)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // --- NAMA & ROLE ---
                  Text(nama.isNotEmpty ? nama : 'Pelanggan', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text('No. Pelanggan: $customerNumber', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF4364F7).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(layanan.isNotEmpty ? layanan : 'Pelanggan PDAM', style: const TextStyle(color: Color(0xFF4364F7), fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const SizedBox(height: 32),

                  // --- KARTU INFORMASI ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informasi Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 20),
                        _infoRow('Nama Lengkap', nama.isNotEmpty ? nama : '-', Icons.person_outline),
                        const Divider(height: 30, color: Color(0xFFF4F7FE), thickness: 1.5),
                        _infoRow('Username', username.isNotEmpty ? username : '-', Icons.alternate_email),
                        const Divider(height: 30, color: Color(0xFFF4F7FE), thickness: 1.5),
                        _infoRow('Telepon', phone.isNotEmpty ? phone : '-', Icons.phone_outlined),
                        const Divider(height: 30, color: Color(0xFFF4F7FE), thickness: 1.5),
                        _infoRow('Alamat', alamat.isNotEmpty ? alamat : '-', Icons.location_on_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BUTTONS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Profil'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4364F7),
                          side: const BorderSide(color: Color(0xFF4364F7), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    label: const Text('Keluar dari Akun', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFFF4F7FE), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF0052D4), size: 20),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ],
  );
}