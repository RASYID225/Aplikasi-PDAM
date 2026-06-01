import 'package:flutter/material.dart';
import 'package:pdam_apps/Models/User_login.dart';
import 'package:pdam_apps/Services/ApiService.dart';
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

  // Soal 3: GET /customers/me
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
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNav(2),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF144B80)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFE0F2FE),
                      child: Text(
                        nama.isNotEmpty ? nama[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nama.isNotEmpty ? nama : 'Pelanggan',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No. Pelanggan: $customerNumber',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        layanan.isNotEmpty ? layanan : 'Pelanggan PDAM',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Akun',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _infoRow(
                            'Nama',
                            nama.isNotEmpty ? nama : '-',
                            Icons.person_outline,
                          ),
                          const Divider(height: 24),
                          _infoRow(
                            'Username',
                            username.isNotEmpty ? username : '-',
                            Icons.alternate_email,
                          ),
                          const Divider(height: 24),
                          _infoRow(
                            'Telepon',
                            phone.isNotEmpty ? phone : '-',
                            Icons.phone_outlined,
                          ),
                          const Divider(height: 24),
                          _infoRow(
                            'Alamat',
                            alamat.isNotEmpty ? alamat : '-',
                            Icons.location_on_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Profil'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF144B80),
                          side: const BorderSide(color: Color(0xFF144B80)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _handleLogout,
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Icon(icon, color: Colors.grey.shade500, size: 20),
    ],
  );
}
