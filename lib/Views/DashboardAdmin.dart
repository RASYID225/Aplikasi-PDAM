import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});
  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  // ... [Fungsi logika dibiarkan persis sama] ...
  bool _isLoading = true;
  int totalPelanggan = 0; int totalLayanan = 0; int belumDiverifikasi = 0;
  List aktivitasTerbaru = [];
  static const _bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([ApiService.getPelanggan(), ApiService.getLayanan(), ApiService.getAllPayments(), ApiService.getTagihan()]);
      if (!mounted) return;
      final List allPayments = results[2]['data'] ?? [];
      final List allTagihan = results[3]['data'] ?? [];
      setState(() {
        totalPelanggan = results[0]['count'] ?? 0;
        totalLayanan = results[1]['count'] ?? 0;
        belumDiverifikasi = allPayments.where((p) => p['verified'] == false).length;
        aktivitasTerbaru = allTagihan.take(4).toList();
        _isLoading = false;
      });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dashboard Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 4),
                        Text('Pantau performa PDAM hari ini', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                    const CircleAvatar(radius: 24, backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, color: Color(0xFF0052D4))),
                  ],
                ),
                const SizedBox(height: 24),

                // --- MAIN STAT CARD ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0052D4), Color(0xFF4364F7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFF4364F7).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL PELANGGAN', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w600)),
                          _isLoading ? const SizedBox(height: 30, width: 30, child: CircularProgressIndicator(color: Colors.white)) 
                                     : Text('$totalPelanggan', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- SUB STATS ---
                Row(
                  children: [
                    Expanded(child: _buildMiniStatCard(Icons.water_drop_rounded, 'Total Layanan', _isLoading ? '...' : '$totalLayanan', Colors.blue)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMiniStatCard(Icons.pending_actions_rounded, 'Perlu Verifikasi', _isLoading ? '...' : '$belumDiverifikasi', Colors.orange)),
                  ],
                ),
                const SizedBox(height: 30),

                // --- QUICK ACTIONS ---
                const Text('Menu Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildActionBtn(context, Icons.person_add_alt_1, 'Pelanggan Baru', '/TambahPelanggan', const Color(0xFF0052D4))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildActionBtn(context, Icons.settings, 'Tarif & Layanan', '/KelolaLayanan', const Color(0xFF1A1A2E))),
                  ],
                ),
                const SizedBox(height: 30),

                // --- AKTIVITAS TERBARU ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Aktivitas Tagihan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    TextButton(onPressed: () => Navigator.pushNamed(context, '/KelolaTagihan'), child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF4364F7), fontWeight: FontWeight.bold))),
                  ],
                ),
                
                _isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF4364F7))))
                    : aktivitasTerbaru.isEmpty
                        ? Container(
                            width: double.infinity, padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: const Column(children: [Icon(Icons.inbox_rounded, color: Colors.grey, size: 40), SizedBox(height: 10), Text('Belum ada aktivitas', style: TextStyle(color: Colors.grey))]),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: aktivitasTerbaru.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final item = aktivitasTerbaru[i];
                              final String nama = item['customer']?['name'] ?? '-';
                              final bool paid = item['paid'] == true;
                              final hasPayment = item['payments'] != null && ((item['payments'] is List && item['payments'].isNotEmpty) || item['payments'] is Map);
                              
                              final statusTxt = paid ? 'Lunas' : hasPayment ? 'Cek Bukti' : 'Menunggu';
                              final statusColor = paid ? Colors.green : hasPayment ? Colors.orange : Colors.red;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                                child: Row(
                                  children: [
                                    CircleAvatar(backgroundColor: Colors.blue.shade50, child: Text(nama.isNotEmpty ? nama[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF0052D4), fontWeight: FontWeight.bold))),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text('Bulan ${item['month']} ${item['year']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                      child: Text(statusTxt, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, IconData icon, String label, String route, Color bgColor) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}