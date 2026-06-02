import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/ApiService.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class KelolaTagihan extends StatefulWidget {
  const KelolaTagihan({super.key});
  @override
  State<KelolaTagihan> createState() => _KelolaTagihanState();
}

class _KelolaTagihanState extends State<KelolaTagihan> {
  bool _isLoading = true;
  bool _initialized = false;
  List _semua = [];
  List _filtered = [];
  int _totalHarga = 0;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      return;
    }
    final route = ModalRoute.of(context);
    if (route?.isCurrent == true) _loadData();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getTagihan();
    if (!mounted) return;
    final data = List.from(res['data'] ?? []);
    int total = 0;
    for (var t in data) {
      total += (t['price'] as int? ?? 0);
    }
    setState(() {
      _semua = data;
      _filtered = data;
      _totalHarga = total;
      _isLoading = false;
    });
  }

  void _onSearch() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = _semua.where((t) {
        final c = t['customer'] as Map? ?? {};
        return (c['name'] ?? '').toLowerCase().contains(q) ||
            (c['customer_number'] ?? '').toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> _hapus(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Tagihan'),
        content: const Text('Yakin ingin menghapus tagihan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final res = await ApiService.deleteTagihan(id);
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tagihan dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'Gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _statusLabel(Map t) {
    if (t['paid'] == true) return 'LUNAS';
    final payments = t['payments'];
    if (payments != null) {
      if (payments is List && payments.isNotEmpty) return 'MENUNGGU';
      if (payments is Map) return 'MENUNGGU';
    }
    return 'BELUM BAYAR';
  }

  Color _statusColor(String s) => s == 'LUNAS'
      ? Colors.green
      : s == 'MENUNGGU'
      ? Colors.orange
      : Colors.red;
  Color _statusBg(String s) => s == 'LUNAS'
      ? const Color(0xFFE8F5E9)
      : s == 'MENUNGGU'
      ? const Color(0xFFFFF8E1)
      : const Color(0xFFFFEBEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF144B80),
      bottomNavigationBar: const BottomNav(1),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/TambahTagihan');
          _loadData();
        },
        backgroundColor: const Color(0xFF007BFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kelola Tagihan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Semua tagihan pelanggan',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL TAGIHAN',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${_fmt(_totalHarga)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama pelanggan',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── LIST ──
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
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
                        child: Text(
                          'Tidak ada tagihan',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final t = _filtered[i];
                          final cust = t['customer'] as Map? ?? {};
                          final nama = cust['name'] ?? '-';
                          final int m = t['month'] ?? 0;
                          final String periode = m >= 1 && m <= 12
                              ? '${_bulan[m]} ${t['year']}'
                              : '-';
                          final status = _statusLabel(t);
                          final payments = t['payments'];
                          final paymentsList = payments is List
                              ? payments
                              : null;
                          final bool hasPayment =
                              payments != null &&
                              ((paymentsList != null &&
                                      paymentsList.isNotEmpty) ||
                                  payments is Map);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xFFE8F0FE),
                                  child: Text(
                                    nama.isNotEmpty
                                        ? nama[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Color(0xFF144B80),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // ✅ FIX: Expanded + maxLines
                                          Expanded(
                                            child: Text(
                                              nama,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusBg(status),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              status,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: _statusColor(status),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$periode • ${t['usage_value'] ?? 0} m³ • Rp ${_fmt(t['price'] ?? 0)}',
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
                                // Action button
                                if (!t['paid'] && hasPayment)
                                  // ✅ FIX: TextButton tanpa minimumSize bawaan
                                  TextButton(
                                    onPressed: () async {
                                      final paymentData = paymentsList != null
                                          ? paymentsList.first
                                          : payments;
                                      await Navigator.pushNamed(
                                        ctx,
                                        '/VerifikasiPembayaran',
                                        arguments: {
                                          'bill': t,
                                          'payment': paymentData,
                                        },
                                      );
                                      _loadData();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF144B80),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Verifikasi',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else if (!t['paid'])
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _hapus(t['id']),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                              ],
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
