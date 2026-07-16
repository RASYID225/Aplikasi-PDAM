import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pelanggan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Yakin hapus "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
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
            res['success'] == true ? 'Pelanggan dihapus' : res['message'] ?? 'Gagal',
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
      backgroundColor: const Color(0xFFF4F7FE),
      bottomNavigationBar: const BottomNav(1),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/TambahPelanggan');
          _loadData();
        },
        backgroundColor: const Color(0xFF4364F7),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        title: const Text('Kelola Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A2E))),
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
                          child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL PELANGGAN AKTIF', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('$_total', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          ],
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
                        hintText: 'Cari nama atau no pelanggan...',
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
            
            // --- LIST PELANGGAN ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4364F7)))
                  : _filtered.isEmpty
                      ? const Center(child: Text('Tidak ada data pelanggan', style: TextStyle(color: Colors.black54)))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            final p = _filtered[i];
                            final String nama = p['name'] ?? '-';
                            final String noP = p['customer_number'] ?? '-';
                            final String adr = p['address'] ?? '-';
                            
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
                                    child: Text(
                                      nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Color(0xFF0052D4), fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E)), overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text('No. $noP', style: const TextStyle(fontSize: 12, color: Color(0xFF4364F7), fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(adr, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis, maxLines: 1),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, color: Color(0xFF0052D4), size: 20),
                                        onPressed: () async {
                                          await Navigator.pushNamed(ctx, '/TambahPelanggan', arguments: p);
                                          _loadData();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                                        onPressed: () => _hapus(p['id'], nama),
                                      ),
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
}