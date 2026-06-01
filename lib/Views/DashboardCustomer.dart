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
  int tagihaBillId = 0;
  int belumBayarCount = 0;
  List<Map<String, dynamic>> chartData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Soal 9: GET /bills/me + Soal 3: GET /customers/me
      final results = await Future.wait([
        ApiService.getMyBills(),
        ApiService.getCustomerProfile(),
      ]);
      if (!mounted) return;

      final billsRes = results[0];
      final profileRes = results[1];

      // Ambil data profil
      final profileData = profileRes['data'] as Map? ?? {};
      final String nama = profileData['name'] ?? 'Pelanggan';
      final String custId = profileData['id']?.toString() ?? '';

      // Proses bills
      final List allBills = billsRes['data'] ?? [];

      // Hitung belum bayar
      final int belumBayar = allBills.where((b) => b['paid'] == false).length;

      // Tagihan terbaru (belum bayar pertama)
      Map? tagihanTerbaru;
      for (var b in allBills) {
        if (b['paid'] == false) {
          tagihanTerbaru = b;
          break;
        }
      }

      // Buat chart data dari 5 bulan terakhir
      final List<Map<String, dynamic>> chart = allBills
          .take(5)
          .map<Map<String, dynamic>>((b) {
            const bulanStr = [
              '',
              'JAN',
              'FEB',
              'MAR',
              'APR',
              'MEI',
              'JUN',
              'JUL',
              'AGT',
              'SEP',
              'OKT',
              'NOV',
              'DES',
            ];
            final int m = b['month'] ?? 0;
            return {
              'bulan': m >= 1 && m <= 12 ? bulanStr[m] : '-',
              'nilai': b['usage_value'] ?? 0,
              'isActive': b == allBills.first,
            };
          })
          .toList();

      setState(() {
        namaCustomer = nama;
        idCustomer = custId;
        belumBayarCount = belumBayar;
        chartData = chart;

        if (tagihanTerbaru != null) {
          totalTagihan = tagihanTerbaru['price'] ?? 0;
          volumeAir = tagihanTerbaru['usage_value'] ?? 0;
          tagihaBillId = tagihanTerbaru['id'] ?? 0;
          sudahBayar = tagihanTerbaru['paid'] ?? false;
          final int m = tagihanTerbaru['month'] ?? 0;
          const bStr = [
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
          jatuhTempo = m >= 1 && m <= 12 ? '30 ${bStr[m]}' : '-';
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
            padding: const EdgeInsets.all(20),
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
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Halo, $namaCustomer ',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const Text(
                                    '👋',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: $idCustomer',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
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
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Card Tagihan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: sudahBayar
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                sudahBayar ? 'Lunas' : 'Belum Bayar',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: sudahBayar
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tagihan Bulan Ini',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Rp ${_fmt(totalTagihan)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _tagInfoItem('Volume Air', '$volumeAir m³'),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.grey.shade200,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                ),
                                _tagInfoItem('Jatuh Tempo', jatuhTempo),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: !sudahBayar && tagihaBillId > 0
                                    ? () => Navigator.pushNamed(
                                        context,
                                        '/BayarTagihan',
                                        arguments: {
                                          'billId': tagihaBillId,
                                          'total': totalTagihan,
                                        },
                                      )
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
                                  sudahBayar ? 'Sudah Lunas' : 'Bayar',
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
                      const SizedBox(height: 24),

                      // Chart
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 20),
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
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
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
                                  'Rata Rata: ${_rataRata()} m³',
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

                      if (belumBayarCount > 0) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Anda memiliki $belumBayarCount tagihan yang belum dibayar',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/HistoryCustomer',
                                ),
                                child: const Text(
                                  'Lihat',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final maxVal = chartData
        .map((e) => e['nilai'] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    if (maxVal == 0) return const SizedBox.shrink();
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: chartData.map((item) {
          final isActive = item['isActive'] == true;
          final nilai = item['nilai'] as int;
          final barH = (nilai / maxVal) * 120;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isActive) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${nilai}m³',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Container(
                width: 32,
                height: barH.clamp(8.0, 120.0),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF4FC3F7)
                      : const Color(0xFF144B80),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['bulan'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? const Color(0xFF144B80) : Colors.black54,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _tagInfoItem(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A2E),
        ),
      ),
    ],
  );

  String _fmt(int n) {
    if (n == 0) return '0';
    final s = n.toString();
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
    final t = chartData.map((e) => e['nilai'] as int).reduce((a, b) => a + b);
    return (t / chartData.length).round().toString();
  }
}
