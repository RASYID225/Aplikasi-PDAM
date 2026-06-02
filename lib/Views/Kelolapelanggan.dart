import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/ApiService.dart';
import 'package:pdam_apps/Widgets/Navbar.dart';

class KelolaPelanggan extends StatefulWidget {
  const KelolaPelanggan({super.key});
  @override
  State<KelolaPelanggan> createState() => _KelolaPelangganState();
}

class _KelolaPelangganState extends State<KelolaPelanggan> {
  bool _isLoading = true;
  List _semua = [], _filtered = [];
  int _total = 0;
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final res = await ApiService.getPelanggan();
    if (!mounted) return;
    final data = List.from(res['data'] ?? []);
    setState(() {
      _semua = data;
      _filtered = data;
      _total = res['count'] ?? data.length;
      _isLoading = false;
    });
  }

  void _onSearch() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered = _semua
          .where(
            (p) =>
                (p['name'] ?? '').toLowerCase().contains(q) ||
                (p['customer_number'] ?? '').toLowerCase().contains(q),
          )
          .toList();
    });
  }

  Future<void> _hapus(int id, String nama) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pelanggan'),
        content: Text('Yakin hapus "$nama"?'),
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
      final res = await ApiService.deletePelanggan(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['success'] == true
                ? 'Pelanggan dihapus'
                : res['message'] ?? 'Gagal',
          ),
          backgroundColor: res['success'] == true ? Colors.green : Colors.red,
        ),
      );
      if (res['success'] == true) _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF144B80),
      bottomNavigationBar: const BottomNav(1),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/TambahPelanggan');
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kelola Pelanggan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Total: $_total Pelanggan',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _loadData,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama atau nomor pelanggan',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
                          'Tidak ada data',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                            child: Row(
                              children: [
                                Text(
                                  '${_filtered.length} Pelanggan',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                // OK karena Row ini simple, tidak ada text dinamis panjang
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                100,
                              ),
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (ctx, i) {
                                final p = _filtered[i];
                                final String nama = p['name'] ?? '-';
                                final String noP = p['customer_number'] ?? '-';
                                final String adr = p['address'] ?? '-';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
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
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // ✅ Expanded mencegah overflow
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
                                              'No.$noP • $adr',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // ✅ Tombol action compact
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Color(0xFF144B80),
                                          size: 18,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        onPressed: () async {
                                          await Navigator.pushNamed(
                                            ctx,
                                            '/TambahPelanggan',
                                            arguments: p,
                                          );
                                          _loadData();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        onPressed: () => _hapus(p['id'], nama),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // ── STAT BOTTOM ──
                          Container(
                            margin: const EdgeInsets.all(14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF144B80), Color(0xFF007BFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        '$_total',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tampil',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Text(
                                        '${_filtered.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
}
