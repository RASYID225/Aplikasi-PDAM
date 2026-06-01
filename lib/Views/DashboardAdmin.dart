import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/ApiService.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});
  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  bool _isLoading = true;
  int totalPelanggan = 0;
  int totalLayanan = 0;
  int belumDiverifikasi = 0;
  List aktivitasTerbaru = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Soal 8: Fetch semua data dashboard secara bersamaan
      final results = await Future.wait([
        ApiService.getPelanggan(), // index 0
        ApiService.getLayanan(), // index 1
        ApiService.getPayments(), // index 2
        ApiService.getTagihan(), // index 3
      ]);

      if (!mounted) return;

      // Total pelanggan dari count
      final pelangganData = results[0];
      final int tPelanggan = pelangganData['count'] ?? 0;

      // Total layanan dari count
      final layananData = results[1];
      final int tLayanan = layananData['count'] ?? 0;

      // Hitung payment yang belum diverifikasi (verified == false)
      final paymentData = results[2];
      final List allPayments = paymentData['data'] ?? [];
      final int belumVerif = allPayments
          .where((p) => p['verified'] == false)
          .length;

      // Aktivitas terbaru dari bills (ambil 3 pertama)
      final tagihanData = results[3];
      final List allTagihan = tagihanData['data'] ?? [];
      final recent = allTagihan.take(3).toList();

      setState(() {
        totalPelanggan = tPelanggan;
        totalLayanan = tLayanan;
        belumDiverifikasi = belumVerif;
        aktivitasTerbaru = recent;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: const BottomNav(0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Halo, Admin ',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            Text('👋', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pantau distribusi air dan kelola data hari ini',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            size: 22,
                            color: Color(0xFF144B80),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Card Total Pelanggan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF144B80), Color(0xFF007BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007BFF).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL PELANGGAN',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  totalPelanggan.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -1,
                                  ),
                                ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.people_alt_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card Layanan & Belum Diverifikasi
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.apps_rounded,
                        iconBg: const Color(0xFFE8F0FE),
                        iconColor: const Color(0xFF144B80),
                        label: 'Total Layanan',
                        value: _isLoading ? '...' : totalLayanan.toString(),
                        valueColor: const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        icon: Icons.access_time_rounded,
                        iconBg: const Color(0xFFFFF3E0),
                        iconColor: const Color(0xFFE65100),
                        label: 'Belum Diverifikasi',
                        value: _isLoading
                            ? '...'
                            : belumDiverifikasi.toString(),
                        valueColor: const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Aktivitas Terbaru
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aktivitas Terbaru',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/KelolaTagihan'),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Color(0xFF007BFF),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : aktivitasTerbaru.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Belum ada tagihan',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: aktivitasTerbaru.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, i) {
                            final item = aktivitasTerbaru[i];
                            final customer = item['customer'] as Map? ?? {};
                            final isPaid = item['paid'] == true;
                            final hasPayment =
                                item['payments'] != null &&
                                (item['payments'] is Map ||
                                    (item['payments'] is List &&
                                        (item['payments'] as List).isNotEmpty));
                            final String status = isPaid
                                ? 'LUNAS'
                                : (hasPayment ? 'MENUNGGU' : 'BELUM BAYAR');
                            final Color statusColor = isPaid
                                ? Colors.green
                                : (hasPayment ? Colors.orange : Colors.red);
                            final Color statusBg = isPaid
                                ? const Color(0xFFE8F5E9)
                                : (hasPayment
                                      ? const Color(0xFFFFF8E1)
                                      : const Color(0xFFFFEBEE));
                            final String nama = customer['name'] ?? '-';
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFE8F0FE),
                                child: Text(
                                  nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Color(0xFF144B80),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                'Tagihan #${item['id']} • ${_bulan(item['month'] ?? 0)} ${item['year']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 24),

                // Quick Actions
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/TambahPelanggan'),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
                    label: const Text('Tambah Pelanggan Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF144B80),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        icon: Icons.bar_chart_rounded,
                        label: 'Laporan\nBulanan',
                        onTap: () =>
                            Navigator.pushNamed(context, '/KelolaTagihan'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionCard(
                        icon: Icons.tune_rounded,
                        label: 'Konfigurasi\nTarif',
                        onTap: () =>
                            Navigator.pushNamed(context, '/KelolaLayanan'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF144B80), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF144B80),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _bulan(int m) {
    const b = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return m >= 1 && m <= 12 ? b[m] : '-';
  }
}
