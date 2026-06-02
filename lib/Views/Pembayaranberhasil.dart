import 'package:flutter/material.dart';

class PembayaranBerhasil extends StatefulWidget {
  const PembayaranBerhasil({super.key});
  @override
  State<PembayaranBerhasil> createState() => _PembayaranBerhasilState();
}

class _PembayaranBerhasilState extends State<PembayaranBerhasil> {
  Map _payment = {};
  int _total = 0;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
      _payment = args['payment'] as Map? ?? {};
      _total = args['total'] ?? _payment['total_amount'] ?? 0;
      _loaded = true;
    }
  }

  String _fmtTgl(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw.length > 10 ? raw.substring(0, 10) : raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String idTrx = _payment['id']?.toString() ?? '-';
    final String waktu = _fmtTgl(_payment['payment_date']?.toString());
    final bool verified = _payment['verified'] == true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Column(
                  children: [
                    // Ikon sukses
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pembayaran Berhasil!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // ✅ FittedBox cegah overflow nominal
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Rp ${_fmt(_total)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: verified
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        verified
                            ? '✓ Terverifikasi'
                            : 'Menunggu Verifikasi Admin',
                        style: TextStyle(
                          color: verified ? Colors.green[700] : Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Detail pembayaran
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Detail Pembayaran',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _row('ID Transaksi', idTrx),
                                const SizedBox(height: 12),
                                // ✅ Status row dengan Flexible
                                Row(
                                  children: [
                                    const Text(
                                      'Status',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      verified
                                          ? Icons.check_circle
                                          : Icons.access_time,
                                      color: verified
                                          ? const Color(0xFF4CAF50)
                                          : Colors.orange,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      verified ? 'Terverifikasi' : 'Menunggu',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: verified
                                            ? const Color(0xFF4CAF50)
                                            : Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _row('Waktu', waktu),
                                const SizedBox(height: 12),
                                _row('Total', 'Rp ${_fmt(_total)}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4FD),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF0369A1),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bukti pembayaran sudah dikirim dan sedang menunggu verifikasi admin.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Bantuan
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F4FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.help_outline,
                              color: Color(0xFF0369A1),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ada Masalah?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Hubungi kami sekarang!',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/DashboardCustomer',
                        (r) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF144B80),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  // ✅ Row helper anti-overflow
  Widget _row(String l, String v) => Row(
    children: [
      Text(l, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          v,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  String _fmt(dynamic n) {
    final v = (n is int) ? n : int.tryParse(n.toString()) ?? 0;
    final s = v.toString();
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
