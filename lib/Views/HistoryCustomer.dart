import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class HistoryCustomer extends StatefulWidget {
  const HistoryCustomer({super.key});
  @override
  State<HistoryCustomer> createState() => _HistoryCustomerState();
}

class _HistoryCustomerState extends State<HistoryCustomer> {
  bool _isLoading = true;
  List _semua = [];
  List _filtered = [];
  final _search = TextEditingController();

  static const _bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  void initState() {
    super.initState();
    _loadData();
    _search.addListener(_onSearch);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getMyBills();
    if (!mounted) return;
    final data = List.from(res['data'] ?? []);
    setState(() {
      _semua = data;
      _filtered = data;
      _isLoading = false;
    });
  }

  void _onSearch() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = _semua.where((item) {
        final int m = item['month'] ?? 0;
        final String s = '${m >= 1 && m <= 12 ? _bulan[m].toLowerCase() : ''} ${item['year'] ?? ''}';
        return s.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      bottomNavigationBar: const BottomNav(1),
      appBar: AppBar(
        title: const Text('Riwayat Tagihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A2E))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    hintText: 'Cari bulan atau tahun...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4364F7)))
                  : _filtered.isEmpty
                      ? const Center(child: Text('Belum ada riwayat tagihan', style: TextStyle(color: Colors.black54)))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            final r = _filtered[i];
                            final bool paid = r['paid'] == true;
                            final payments = r['payments'];
                            final bool menunggu = !paid && payments != null && ((payments is List && payments.isNotEmpty) || (payments is Map && payments.isNotEmpty));
                            final int m = r['month'] ?? 0;
                            final String periode = '${m >= 1 && m <= 12 ? _bulan[m] : '-'} ${r['year'] ?? ''}';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Periode', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                          Text(periode, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: paid ? Colors.green.shade50 : menunggu ? Colors.orange.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                                        child: Text(paid ? '✓ Lunas' : menunggu ? '⏳ Menunggu' : 'Belum Bayar', style: TextStyle(color: paid ? Colors.green : menunggu ? Colors.orange : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Pemakaian', style: TextStyle(fontSize: 11, color: Colors.grey)), Text('${r['usage_value'] ?? 0} m³', style: const TextStyle(fontWeight: FontWeight.w600))]),
                                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Total', style: TextStyle(fontSize: 11, color: Colors.grey)), Text('Rp ${_fmt(r['price'] ?? 0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0052D4)))]),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
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
    for (int i = s.length - 1; i >= 0; i--) { if (c > 0 && c % 3 == 0) b.write('.'); b.write(s[i]); c++; }
    return b.toString().split('').reversed.join();
  }
}