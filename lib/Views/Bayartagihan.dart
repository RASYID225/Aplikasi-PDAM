import 'package:flutter/material.dart';

class BayarTagihan extends StatefulWidget {
  const BayarTagihan({super.key});
  @override
  State<BayarTagihan> createState() => _BayarTagihanState();
}

class _BayarTagihanState extends State<BayarTagihan> {
  String _selectedMetode = 'QRIS';
  bool _isLoading = false;
  final List<Map<String, dynamic>> _metode = [
    {'id': 'QRIS', 'label': 'QRIS', 'icon': Icons.qr_code},
    {'id': 'Mandiri', 'label': 'Bank Mandiri', 'icon': Icons.account_balance},
    {'id': 'BRI', 'label': 'Bank BRI', 'icon': Icons.account_balance},
    {'id': 'BNI', 'label': 'Bank BNI', 'icon': Icons.account_balance},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF144B80),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                InkWell(onTap: () => Navigator.pop(context),
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, color: Colors.white, size: 20))),
                const SizedBox(width: 14),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Bayar Tagihan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Satu langkah lagi untuk menyelesaikan\npembayaran tagihan Anda.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total tagihan
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(14)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Total Tagihan', style: TextStyle(fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 4),
                          const Text('Rp 245.000', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.timer_outlined, size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            const Text('Batas Waktu ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            const Text('00:05:59', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                          ]),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      // Metode pembayaran
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Metode Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        TextButton(onPressed: () {}, child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF144B80)))),
                      ]),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.2,
                        children: _metode.map((m) {
                          final selected = _selectedMetode == m['id'];
                          return InkWell(
                            onTap: () => setState(() => _selectedMetode = m['id']),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: selected ? const Color(0xFF144B80) : Colors.grey.shade200, width: selected ? 2 : 1),
                                borderRadius: BorderRadius.circular(12),
                                color: selected ? const Color(0xFFEEF3FF) : Colors.white,
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(m['icon'] as IconData, color: selected ? const Color(0xFF144B80) : Colors.grey, size: 22),
                                const SizedBox(height: 4),
                                Text(m['label'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: selected ? const Color(0xFF144B80) : Colors.grey)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      // Instruksi Transfer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [const Icon(Icons.info_outline, size: 16, color: Color(0xFF144B80)), const SizedBox(width: 6), const Text('Instruksi Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
                          const SizedBox(height: 12),
                          const Text('Nama Rekening', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          const Text('BCA Virtual Account - PDAM JAYA REGIONAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          const Text('Nomor Virtual Account', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Row(children: [
                            const Text('123-456-7890', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const Spacer(),
                            IconButton(icon: const Icon(Icons.copy, color: Color(0xFF144B80), size: 20), onPressed: () {}),
                          ]),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFE8F4FD), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Harus transfer tepat sebesar Rp 245.000. Perbedaan nominal dapat menghambat proses verifikasi otomatis.', style: TextStyle(fontSize: 11, color: Color(0xFF0369A1))),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      // Upload bukti
                      const Text('Upload Bukti Transfer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: const Column(children: [
                            Icon(Icons.upload_outlined, size: 36, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Unggah Bukti Pembayaran', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                            Text('Format JPG, PNG (Maks. 5MB)', style: TextStyle(fontSize: 11, color: Colors.black38)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            setState(() => _isLoading = true);
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                setState(() => _isLoading = false);
                                Navigator.pushReplacementNamed(context, '/PembayaranBerhasil');
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF144B80), foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Konfirmasi Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}