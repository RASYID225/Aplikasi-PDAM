import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';
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

  static const _bulan = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tagihan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin ingin menghapus tagihan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      final res = await ApiService.deleteTagihan(id);
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tagihan dihapus'), backgroundColor: Colors.green));
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal'), backgroundColor: Colors.red));
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

  Color _statusColor(String s) => s == 'LUNAS' ? Colors.green : s == 'MENUNGGU' ? Colors.orange : Colors.red;
  Color _statusBg(String s) => s == 'LUNAS' ? const Color(0xFFE8F5E9) : s == 'MENUNGGU' ? const Color(0xFFFFF8E1) : const Color(0xFFFFEBEE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      bottomNavigationBar: const BottomNav(1),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/TambahTagihan');
          _loadData();
        },
        backgroundColor: const Color(0xFF4364F7),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text('Kelola Tagihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A2E))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4364F7)),
            onPressed: _loadData,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // --- STAT CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0052D4), Color(0xFF4364F7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: const Color(0xFF4364F7).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TOTAL TAGIHAN KESELURUHAN', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('Rp ${_fmt(_totalHarga)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // --- SEARCH BAR ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama pelanggan...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // --- LIST TAGIHAN ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4364F7)))
                  : _filtered.isEmpty
                      ? const Center(child: Text('Tidak ada tagihan', style: TextStyle(color: Colors.black54)))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            final t = _filtered[i];
                            final cust = t['customer'] as Map? ?? {};
                            final nama = cust['name'] ?? '-';
                            final int m = t['month'] ?? 0;
                            final String periode = m >= 1 && m <= 12 ? '${_bulan[m]} ${t['year']}' : '-';
                            final status = _statusLabel(t);
                            final payments = t['payments'];
                            final paymentsList = payments is List ? payments : null;
                            final bool hasPayment = payments != null && ((paymentsList != null && paymentsList.isNotEmpty) || payments is Map);

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.blue.shade50,
                                    child: Text(nama.isNotEmpty ? nama[0].toUpperCase() : '?', style: const TextStyle(color: Color(0xFF0052D4), fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child: Text(nama, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E)), overflow: TextOverflow.ellipsis)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: _statusBg(status), borderRadius: BorderRadius.circular(8)),
                                              child: Text(status, style: TextStyle(color: _statusColor(status), fontSize: 9, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text('Periode: $periode', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                        const SizedBox(height: 2),
                                        Text('${t['usage_value'] ?? 0} m³ • Rp ${_fmt(t['price'] ?? 0)}', style: const TextStyle(fontSize: 12, color: Color(0xFF4364F7), fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!t['paid'] && hasPayment)
                                    ElevatedButton(
                                      onPressed: () async {
                                        final paymentData = paymentsList != null ? paymentsList.first : payments;
                                        await Navigator.pushNamed(ctx, '/VerifikasiPembayaran', arguments: {'bill': t, 'payment': paymentData});
                                        _loadData();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0052D4),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      child: const Text('Cek Bukti', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                    )
                                  else if (!t['paid'])
                                    IconButton(
                                      icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                                      onPressed: () => _hapus(t['id']),
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
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) b.write('.');
      b.write(s[i]);
      c++;
    }
    return b.toString().split('').reversed.join();
  }
}