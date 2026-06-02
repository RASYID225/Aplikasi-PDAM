import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/ApiService.dart';
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
    _search.addListener(_onSearch);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // GET /bills/me
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
        final String s =
            '${m >= 1 && m <= 12 ? _bulan[m].toLowerCase() : ''} ${item['year'] ?? ''}';
        return s.contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF144B80),
      bottomNavigationBar: const BottomNav(1),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Riwayat Tagihan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Semua tagihan dan status pembayaran Anda',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _search,
                            decoration: const InputDecoration(
                              hintText: 'Cari bulan atau tahun',
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _loadData,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // ── LIST ──
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF144B80),
                        ),
                      )
                    : _filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.black26,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada riwayat tagihan',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) {
                          final r = _filtered[i];
                          final bool paid = r['paid'] == true;
                          final payments = r['payments'];
                          final bool menunggu = !paid &&
                              payments != null &&
                              ((payments is List && payments.isNotEmpty) ||
                                  (payments is Map && payments.isNotEmpty));
                          final int m = r['month'] ?? 0;
                          final String periode =
                              '${m >= 1 && m <= 12 ? _bulan[m] : '-'} ${r['year'] ?? ''}';

                          return GestureDetector(
                            onTap: () async {
                              // Hanya bisa bayar jika belum bayar DAN belum upload bukti
                              if (!paid && !menunggu) {
                                await Navigator.pushNamed(
                                  ctx,
                                  '/BayarTagihan',
                                  arguments: {
                                    'billId': r['id'],
                                    'total': r['price'] ?? 0,
                                  },
                                );
                                _loadData(); // ✅ Reload setelah bayar
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
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
                                  // ── Baris 1: Periode + Badge ──
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Periode',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            periode,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: paid
                                              ? const Color(0xFFE8F5E9)
                                              : menunggu
                                                  ? const Color(0xFFFFF8E1)
                                                  : const Color(0xFFFFEBEE),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          paid
                                              ? '✓ Lunas'
                                              : menunggu
                                                  ? '⏳ Menunggu'
                                                  : 'Belum Bayar',
                                          style: TextStyle(
                                            color: paid
                                                ? Colors.green[700]
                                                : menunggu
                                                    ? Colors.orange[700]
                                                    : Colors.red[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),
                                  // ── Baris 2: Pemakaian + Tagihan ──
                                  // ✅ FIX: Expanded bukan Row+Spacer bebas
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Pemakaian',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              '${r['usage_value'] ?? 0} m³',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Total Tagihan',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              'Rp ${_fmt(r['price'] ?? 0)}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF144B80),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Hint ketuk untuk bayar (hanya jika belum ada bukti)
                                  if (!paid && !menunggu) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F4FD),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Ketuk untuk membayar →',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF144B80),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  // Info menunggu verifikasi
                                  if (menunggu) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF8E1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '⏳ Menunggu verifikasi admin',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) b.write('.');
      b.write(s[i]);
      c++;
    }
    return b.toString().split('').reversed.join();
  }
}
