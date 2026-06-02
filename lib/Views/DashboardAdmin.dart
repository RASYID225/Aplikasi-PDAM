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

  static const _bulan = [
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getPelanggan(),
        ApiService.getLayanan(),
        ApiService.getPayments(),
        ApiService.getTagihan(),
      ]);
      if (!mounted) return;
      final List allPayments = results[2]['data'] ?? [];
      final List allTagihan = results[3]['data'] ?? [];
      setState(() {
        totalPelanggan = results[0]['count'] ?? 0;
        totalLayanan = results[1]['count'] ?? 0;
        belumDiverifikasi = allPayments
            .where((p) => p['verified'] == false)
            .length;
        aktivitasTerbaru = allTagihan.take(3).toList();
        _isLoading = false;
      });
    } catch (_) {
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Halo, Admin ',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Text('👋', style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Pantau distribusi air dan kelola data',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: Color(0xFF144B80),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 7,
                            height: 7,
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
                const SizedBox(height: 16),

                // ── CARD TOTAL PELANGGAN ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF144B80), Color(0xFF007BFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007BFF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL PELANGGAN',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
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
                                    '$totalPelanggan',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.people_alt_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── STAT CARDS ──
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        Icons.apps_rounded,
                        const Color(0xFFE8F0FE),
                        const Color(0xFF144B80),
                        'Total Layanan',
                        _isLoading ? '...' : '$totalLayanan',
                        const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        Icons.access_time_rounded,
                        const Color(0xFFFFF3E0),
                        const Color(0xFFE65100),
                        'Belum Verifikasi',
                        _isLoading ? '...' : '$belumDiverifikasi',
                        const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── AKTIVITAS TERBARU ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aktivitas Terbaru',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/KelolaTagihan'),
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: Color(0xFF007BFF),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : aktivitasTerbaru.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada tagihan',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
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
                          itemBuilder: (_, i) {
                            final item = aktivitasTerbaru[i];
                            final cust = item['customer'] as Map? ?? {};
                            final String nama = cust['name'] ?? '-';
                            final bool paid = item['paid'] == true;
                            final payments = item['payments'];
                            final bool hasPayment =
                                payments != null &&
                                ((payments is List &&
                                        (payments as List).isNotEmpty) ||
                                    payments is Map);
                            final String status = paid
                                ? 'LUNAS'
                                : hasPayment
                                ? 'MENUNGGU'
                                : 'BELUM BAYAR';
                            final Color sc = paid
                                ? Colors.green
                                : hasPayment
                                ? Colors.orange
                                : Colors.red;
                            final Color sb = paid
                                ? const Color(0xFFE8F5E9)
                                : hasPayment
                                ? const Color(0xFFFFF8E1)
                                : const Color(0xFFFFEBEE);
                            final int m = item['month'] ?? 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFE8F0FE),
                                    child: Text(
                                      nama.isNotEmpty
                                          ? nama[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Color(0xFF144B80),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nama,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Tagihan #${item['id']} • ${m >= 1 && m <= 12 ? _bulan[m] : '-'}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sb,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: sc,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 18),

                // ── QUICK ACTIONS ──
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/TambahPelanggan'),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                    label: const Text('Tambah Pelanggan Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF144B80),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        Icons.bar_chart_rounded,
                        'Laporan\nBulanan',
                        () => Navigator.pushNamed(context, '/KelolaTagihan'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionCard(
                        Icons.tune_rounded,
                        'Konfigurasi\nTarif',
                        () => Navigator.pushNamed(context, '/KelolaLayanan'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    Color bg,
    Color ic,
    String label,
    String val,
    Color valColor,
  ) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ic, size: 18),
        ),
        const SizedBox(height: 10),
        Text(
          val,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: valColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    ),
  );

  Widget _actionCard(IconData icon, String label, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF144B80), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF144B80),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
}
