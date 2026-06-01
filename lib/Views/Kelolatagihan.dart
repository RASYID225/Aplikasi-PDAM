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
  List _semua = [];
  List _filtered = [];
  int _totalHarga = 0;
  final _search = TextEditingController();

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

  // Soal 6: GET /bills
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
        final cust = t['customer'] as Map? ?? {};
        return (cust['name'] ?? '').toLowerCase().contains(q) ||
            (cust['customer_number'] ?? '').toLowerCase().contains(q);
      }).toList();
    });
  }

  // Soal 6: DELETE /bills/{id}
  Future<void> _delete(int id) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['success'] == true
                ? 'Tagihan dihapus'
                : res['message'] ?? 'Gagal',
          ),
          backgroundColor: res['success'] == true ? Colors.green : Colors.red,
        ),
      );
      if (res['success'] == true) _loadData();
    }
  }

  Color _statusColor(bool paid, bool hasPayment) {
    if (paid) return Colors.green;
    if (hasPayment) return Colors.orange;
    return Colors.red;
  }

  Color _statusBg(bool paid, bool hasPayment) {
    if (paid) return const Color(0xFFE8F5E9);
    if (hasPayment) return const Color(0xFFFFF8E1);
    return const Color(0xFFFFEBEE);
  }

  String _statusLabel(bool paid, bool hasPayment) {
    if (paid) return 'LUNAS';
    if (hasPayment) return 'MENUNGGU';
    return 'BELUM BAYAR';
  }

  @override
  Widget build(BuildContext context) {
    final bulan = [
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
    return Scaffold(
      backgroundColor: const Color(0xFF144B80),
      bottomNavigationBar: const BottomNav(1),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/TambahTagihan');
          _loadData();
        },
        backgroundColor: const Color(0xFF144B80),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Column(
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama atau nomor pelanggan',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_filtered.length} Tagihan',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Color(0xFF144B80),
                                  ),
                                  onPressed: _loadData,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _filtered.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Tidak ada tagihan',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: _filtered.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(height: 1, indent: 60),
                                    itemBuilder: (ctx, i) {
                                      final t = _filtered[i];
                                      final cust = t['customer'] as Map? ?? {};
                                      final payments = t['payments'];
                                      final bool hasPayment =
                                          payments != null &&
                                          ((payments is List &&
                                                  (payments as List)
                                                      .isNotEmpty) ||
                                              (payments is Map));
                                      final bool paid = t['paid'] == true;
                                      final nama = cust['name'] ?? '-';
                                      final int m = t['month'] ?? 0;
                                      final String periode = m >= 1 && m <= 12
                                          ? '${bulan[m]} ${t['year']}'
                                          : '-';
                                      return ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 4,
                                            ),
                                        leading: CircleAvatar(
                                          backgroundColor: const Color(
                                            0xFFE8F0FE,
                                          ),
                                          child: Text(
                                            nama.isNotEmpty
                                                ? nama[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Color(0xFF144B80),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                nama,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _statusBg(
                                                  paid,
                                                  hasPayment,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _statusLabel(paid, hasPayment),
                                                style: TextStyle(
                                                  color: _statusColor(
                                                    paid,
                                                    hasPayment,
                                                  ),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Text(
                                              periode,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${t['usage_value'] ?? 0} m³',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Rp ${_fmt(t['price'] ?? 0)}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF144B80),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: !paid && hasPayment
                                            ? TextButton(
                                                onPressed: () async {
                                                  final paymentData =
                                                      payments is List
                                                      ? (payments as List).first
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
                                                  foregroundColor: const Color(
                                                    0xFF144B80,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                      ),
                                                ),
                                                child: const Text(
                                                  'Verifikasi',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              )
                                            : !paid
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                                onPressed: () =>
                                                    _delete(t['id']),
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                          ),
                        ],
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
