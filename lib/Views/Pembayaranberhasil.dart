import 'package:flutter/material.dart';

class PembayaranBerhasil extends StatelessWidget {
  const PembayaranBerhasil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Ikon sukses
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 44),
                    ),
                    const SizedBox(height: 20),
                    const Text('Pembayran Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 8),
                    const Text('IDR 245.000,00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E), letterSpacing: -0.5)),
                    const SizedBox(height: 32),
                    // Detail pembayaran
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Detail Pembayaran', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(children: [
                              _row('Nomor Transaksi', '000085752257'),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Status Pembayaran', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                  Row(children: [
                                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
                                    const SizedBox(width: 4),
                                    const Text('Berhasil', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50))),
                                  ]),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _row('Waktu Pembayaran', '27-05-2026, 13:46:16'),
                              const SizedBox(height: 14),
                              _row('Total Pembayaran', 'IDR 245.000,00'),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Bantuan
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: Color(0xFFE8F4FD), shape: BoxShape.circle),
                            child: const Icon(Icons.help_outline, color: Color(0xFF0369A1), size: 22),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Ada Masalah Dengan\nPembayaran?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Beritahu kami Sekarang!', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ]),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tombol bawah
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Unduh PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF144B80),
                        side: const BorderSide(color: Color(0xFF144B80)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/DashboardCustomer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF144B80), foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Selesai', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(l, style: const TextStyle(fontSize: 13, color: Colors.black54)), Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))]);
}