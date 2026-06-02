import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/ApiService.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class DashboardCustomer extends StatefulWidget {
  const DashboardCustomer({super.key});
  @override
  State<DashboardCustomer> createState() => _DashboardCustomerState();
}

class _DashboardCustomerState extends State<DashboardCustomer> {
  bool _isLoading = true;
  String namaCustomer = '';
  String idCustomer = '';
  int totalTagihan = 0;
  int volumeAir = 0;
  String jatuhTempo = '-';
  bool sudahBayar = false;
  bool menungguVerifikasi = false;
  int billId = 0;
  int belumBayarCount = 0;
  List<Map<String, dynamic>> chartData = [];

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
        ApiService.getMyBills(),
        ApiService.getCustomerProfile(),
      ]);
      if (!mounted) return;

      final billsRes = results[0];
      final profileRes = results[1];
      final profileData = profileRes['data'] as Map? ?? {};
      final List allBills = billsRes['data'] ?? [];

      Map? latest;
      for (var b in allBills) {
        if (b['paid'] == false) {
          latest = b;
          break;
        }
      }

      final chart = allBills
          .take(5)
          .toList()
          .reversed
          .map<Map<String, dynamic>>((b) {
            final int m = b['month'] ?? 0;
            return {
              'bulan': m >= 1 && m <= 12 ? _bulan[m] : '-',
              'nilai': (b['usage_value'] ?? 0) as int,
              'isActive': false,
            };
          })
          .toList();
      if (chart.isNotEmpty) chart.last['isActive'] = true;

      setState(() {
        namaCustomer = profileData['name'] ?? 'Pelanggan';
        idCustomer = profileData['id']?.toString() ?? '';
        belumBayarCount = allBills.where((b) => b['paid'] == false).length;
        chartData = chart;
        if (latest != null) {
          totalTagihan = latest['price'] ?? 0;
          volumeAir = latest['usage_value'] ?? 0;
          billId = latest['id'] ?? 0;
          sudahBayar = false;
          final payments = latest['payments'];
          menungguVerifikasi =
              payments != null &&
              ((payments is List && payments.isNotEmpty) ||
                  (payments is Map && payments.isNotEmpty));
          final int m = latest['month'] ?? 0;
          jatuhTempo = m >= 1 && m <= 12 ? '30 ${_bulan[m]}' : '-';
        } else if (allBills.isNotEmpty) {
          final last = allBills.first;
          totalTagihan = last['price'] ?? 0;
          volumeAir = last['usage_value'] ?? 0;
          billId = 0;
          sudahBayar = true;
          menungguVerifikasi = false;
          final int m = last['month'] ?? 0;
          jatuhTempo = m >= 1 && m <= 12 ? '30 ${_bulan[m]}' : '-';
        } else {
          menungguVerifikasi = false;
        }
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: _isLoading
                ? const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF144B80),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── HEADER ──
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ FIX: Expanded + maxLines agar nama panjang tidak overflow
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Halo, $namaCustomer ',
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Text(
                                      '👋',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: $idCustomer',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
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
                              size: 20,
                              color: Color(0xFF144B80),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── CARD TAGIHAN ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sudahBayar
                                        ? const Color(0xFFE8F5E9)
                                        : menungguVerifikasi
                                        ? const Color(0xFFFFF8E1)
                                        : const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    sudahBayar
                                        ? '✓ Sudah Lunas'
                                        : menungguVerifikasi
                                        ? '⏳ Menunggu Verifikasi'
                                        : 'Belum Bayar',
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: sudahBayar
                                          ? Colors.green[700]
                                          : menungguVerifikasi
                                          ? Colors.orange[700]
                                          : Colors.red[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tagihan Bulan Ini',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Rp ${_fmt(totalTagihan)}',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Volume Air',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$volumeAir m³',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 36,
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Jatuh Tempo',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          jatuhTempo,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1A1A2E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    !sudahBayar &&
                                        billId > 0 &&
                                        !menungguVerifikasi
                                    ? () async {
                                        await Navigator.pushNamed(
                                          context,
                                          '/BayarTagihan',
                                          arguments: {
                                            'billId': billId,
                                            'total': totalTagihan,
                                          },
                                        );
                                        _loadData();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF144B80),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  sudahBayar
                                      ? '✓ Sudah Lunas'
                                      : menungguVerifikasi
                                      ? '⏳ Menunggu Verifikasi Admin'
                                      : 'Bayar Sekarang',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── NOTIF BELUM BAYAR ──
                      if (belumBayarCount > 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$belumBayarCount tagihan belum dibayar',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/HistoryCustomer',
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Lihat',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── CHART ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            const Text(
                              'Statistik Pemakaian Air',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 16),
                            chartData.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        'Belum ada data',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  )
                                : _buildBarChart(),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4FC3F7),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Bulan Ini',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Rata-rata: ${_rataRata()} m³',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final vals = chartData.map((e) => e['nilai'] as int).toList();
    final maxVal = vals.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxVal == 0) return const SizedBox.shrink();

    // ✅ FIX: Bungkus dengan SingleChildScrollView horizontal agar tidak overflow di layar kecil
    return SizedBox(
      height: 150,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...chartData.map((item) {
              final isActive = item['isActive'] == true;
              final nilai = item['nilai'] as int;
              final barH = ((nilai / maxVal) * 110).clamp(8.0, 110.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isActive) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3F7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${nilai}m³',
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                    ],
                    Container(
                      width: 28,
                      height: barH,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF4FC3F7)
                            : const Color(0xFF144B80),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['bulan'],
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive
                            ? const Color(0xFF144B80)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  String _fmt(dynamic n) {
    final val = (n is int) ? n : int.tryParse(n.toString()) ?? 0;
    final s = val.toString();
    final b = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) b.write('.');
      b.write(s[i]);
      c++;
    }
    return b.toString().split('').reversed.join();
  }

  String _rataRata() {
    if (chartData.isEmpty) return '0';
    final total = chartData
        .map((e) => e['nilai'] as int)
        .reduce((a, b) => a + b);
    return (total / chartData.length).round().toString();
  }
}
