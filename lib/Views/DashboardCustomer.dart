import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class DashboardCustomer extends StatefulWidget {
  const DashboardCustomer({super.key});
  @override
  State<DashboardCustomer> createState() => _DashboardCustomerState();
}

class _DashboardCustomerState extends State<DashboardCustomer> {
  // ... [Variabel dan initState sama persis dengan aslinya] ...
  bool _isLoading = true;
  String namaCustomer = '';
  String idCustomer = '';
  int totalTagihan = 0;
  int volumeAir = 0;
  String jatuhTempo = '-';
  bool sudahBayar = false;
  bool menungguVerifikasi = false;
  int billId = 0;
  int billMonth = 0;
  int billYear = 0;
  int belumBayarCount = 0;
  List<Map<String, dynamic>> chartData = [];

  static const _bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([ApiService.getMyBills(), ApiService.getCustomerProfile()]);
      if (!mounted) return;
      final billsRes = results[0];
      final profileRes = results[1];
      final profileData = profileRes['data'] as Map? ?? {};
      final List allBills = billsRes['data'] ?? [];

      Map? latest;
      for (var b in allBills) { if (b['paid'] == false) { latest = b; break; } }
      final chart = allBills.take(5).toList().reversed.map<Map<String, dynamic>>((b) {
        final int m = b['month'] ?? 0;
        return {'bulan': m >= 1 && m <= 12 ? _bulan[m] : '-', 'nilai': (b['usage_value'] ?? 0) as int, 'isActive': false};
      }).toList();
      if (chart.isNotEmpty) chart.last['isActive'] = true;

      setState(() {
        namaCustomer = profileData['name'] ?? 'Pelanggan';
        idCustomer = profileData['id']?.toString() ?? '';
        belumBayarCount = allBills.where((b) => b['paid'] == false).length;
        chartData = chart;
        if (latest != null) {
          totalTagihan = latest['price'] ?? 0; volumeAir = latest['usage_value'] ?? 0;
          billId = latest['id'] ?? 0; billMonth = latest['month'] ?? 0; billYear = latest['year'] ?? 0;
          sudahBayar = false;
          final payments = latest['payments'];
          menungguVerifikasi = payments != null && ((payments is List && payments.isNotEmpty) || (payments is Map && payments.isNotEmpty));
          final int m = latest['month'] ?? 0;
          jatuhTempo = m >= 1 && m <= 12 ? '30 ${_bulan[m]}' : '-';
        } else if (allBills.isNotEmpty) {
          final last = allBills.first;
          totalTagihan = last['price'] ?? 0; volumeAir = last['usage_value'] ?? 0;
          billId = 0; sudahBayar = true; menungguVerifikasi = false;
          final int m = last['month'] ?? 0;
          jatuhTempo = m >= 1 && m <= 12 ? '30 ${_bulan[m]}' : '-';
        } else { menungguVerifikasi = false; }
        _isLoading = false;
      });
    } catch (e) { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      bottomNavigationBar: const BottomNav(0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: _isLoading
                ? const SizedBox(height: 400, child: Center(child: CircularProgressIndicator(color: Color(0xFF4364F7))))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Selamat datang,', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(
                                  namaCustomer,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Text('ID: $idCustomer', style: const TextStyle(fontSize: 12, color: Color(0xFF0052D4), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.notifications_none_rounded, color: Color(0xFF0052D4)),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),

                      // --- KARTU TAGIHAN PREMIUM ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0052D4), Color(0xFF4364F7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: const Color(0xFF4364F7).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Tagihan Bulan Ini', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: sudahBayar ? Colors.greenAccent.withOpacity(0.2) : menungguVerifikasi ? Colors.orangeAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    sudahBayar ? '✓ Lunas' : menungguVerifikasi ? '⏳ Verifikasi' : 'Belum Bayar',
                                    style: TextStyle(color: sudahBayar ? Colors.greenAccent : menungguVerifikasi ? Colors.orangeAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Rp ${_fmt(totalTagihan)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1)),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTagihanInfo(Icons.water_drop_outlined, 'Volume', '$volumeAir m³'),
                                _buildTagihanInfo(Icons.calendar_today_outlined, 'Jatuh Tempo', jatuhTempo),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (!sudahBayar && billId > 0 && !menungguVerifikasi) ? () async {
                                  await Navigator.pushNamed(context, '/BayarTagihan', arguments: {'billId': billId, 'month': billMonth, 'year': billYear});
                                  _loadData();
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0052D4),
                                  disabledBackgroundColor: Colors.white.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text(sudahBayar ? 'Sudah Terbayar' : menungguVerifikasi ? 'Menunggu Konfirmasi Admin' : 'Bayar Tagihan Sekarang', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- NOTIFIKASI TERTUNGGAK ---
                      if (belumBayarCount > 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade100)),
                          child: Row(
                            children: [
                              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade100, shape: BoxShape.circle), child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20)),
                              const SizedBox(width: 12),
                              Expanded(child: Text('Kamu memiliki $belumBayarCount tagihan tertunggak!', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600))),
                              TextButton(onPressed: () => Navigator.pushNamed(context, '/HistoryCustomer'), child: const Text('Lihat', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                      if (belumBayarCount > 0) const SizedBox(height: 24),

                      // --- CHART SECTION ---
                      const Text('Statistik Pemakaian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Column(
                          children: [
                            chartData.isEmpty ? const Padding(padding: EdgeInsets.all(20), child: Text('Belum ada data', style: TextStyle(color: Colors.black54))) : _buildBarChart(),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [const Icon(Icons.analytics_outlined, color: Colors.grey, size: 18), const SizedBox(width: 8), Text('Rata-rata pemakaian', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))]),
                                Text('${_rataRata()} m³', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0052D4))),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagihanInfo(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  Widget _buildBarChart() {
    final vals = chartData.map((e) => e['nilai'] as int).toList();
    final maxVal = vals.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxVal == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.map((item) {
          final isActive = item['isActive'] == true;
          final nilai = item['nilai'] as int;
          final barH = ((nilai / maxVal) * 110).clamp(8.0, 110.0);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(color: const Color(0xFF4364F7), borderRadius: BorderRadius.circular(6)),
                  child: Text('${nilai}m³', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              Container(
                width: 32, height: barH,
                decoration: BoxDecoration(
                  gradient: isActive ? const LinearGradient(colors: [Color(0xFF6FB1FC), Color(0xFF4364F7)], begin: Alignment.topCenter, end: Alignment.bottomCenter) : null,
                  color: isActive ? null : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(item['bulan'], style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? const Color(0xFF4364F7) : Colors.grey.shade500)),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _fmt(dynamic n) {
    final val = (n is int) ? n : int.tryParse(n.toString()) ?? 0;
    final s = val.toString();
    final b = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) { if (c > 0 && c % 3 == 0) b.write('.'); b.write(s[i]); c++; }
    return b.toString().split('').reversed.join();
  }
  String _rataRata() {
    if (chartData.isEmpty) return '0';
    final total = chartData.map((e) => e['nilai'] as int).reduce((a, b) => a + b);
    return (total / chartData.length).round().toString();
  }
}