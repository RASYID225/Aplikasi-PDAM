import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdam_apps/Services/ApiService.dart';

class BayarTagihan extends StatefulWidget {
  const BayarTagihan({super.key});
  @override
  State<BayarTagihan> createState() => _BayarTagihanState();
}

class _BayarTagihanState extends State<BayarTagihan> {
  String _metode = 'QRIS';
  bool _isLoading = false;
  File? _bukti;
  int _billId = 0, _total = 0;
  bool _argsLoaded = false;

  final _metodeList = [
    {'id': 'QRIS', 'label': 'QRIS', 'icon': Icons.qr_code},
    {'id': 'Mandiri', 'label': 'Bank Mandiri', 'icon': Icons.account_balance},
    {'id': 'BRI', 'label': 'Bank BRI', 'icon': Icons.account_balance},
    {'id': 'BNI', 'label': 'Bank BNI', 'icon': Icons.account_balance},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
      _billId = args['billId'] ?? 0;
      _total = args['total'] ?? 0;
      _argsLoaded = true;
    }
  }

  Future<void> _pilihGambar() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih Sumber',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFF144B80),
              ),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF144B80),
              ),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (src == null) return;
    final picked = await ImagePicker().pickImage(
      source: src,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (picked != null && mounted) setState(() => _bukti = File(picked.path));
  }

  Future<void> _konfirmasi() async {
    if (_bukti == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload bukti transfer dulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_billId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data tagihan tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final res = await ApiService.uploadPayment(_billId, _bukti!.path);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (res['success'] == true) {
      Navigator.pushReplacementNamed(
        context,
        '/PembayaranBerhasil',
        arguments: {'payment': res['data'], 'total': _total},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF144B80),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bayar Tagihan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Upload bukti transfer untuk konfirmasi',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Total
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Tagihan',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // ✅ FittedBox cegah overflow nominal besar
                            FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Rp ${_fmt(_total)}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F4FD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Transfer tepat Rp ${_fmt(_total)} sesuai nominal tagihan.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF0369A1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Metode
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.6,
                        children: _metodeList.map((m) {
                          final sel = _metode == m['id'];
                          return InkWell(
                            onTap: () =>
                                setState(() => _metode = m['id'] as String),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: sel
                                      ? const Color(0xFF144B80)
                                      : Colors.grey.shade200,
                                  width: sel ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: sel
                                    ? const Color(0xFFEEF3FF)
                                    : Colors.white,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    m['icon'] as IconData,
                                    color: sel
                                        ? const Color(0xFF144B80)
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    m['label'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: sel
                                          ? const Color(0xFF144B80)
                                          : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Instruksi transfer
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Color(0xFF144B80),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Instruksi Transfer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Nama Rekening',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                            const Text(
                              'BCA Virtual Account - PDAM JAYA REGIONAL',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Nomor Virtual Account',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                            Row(
                              children: [
                                const Flexible(
                                  child: Text(
                                    '123-456-7890',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.copy,
                                    color: Color(0xFF144B80),
                                    size: 16,
                                  ),
                                  onPressed: () {},
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Upload bukti
                      const Text(
                        'Upload Bukti Transfer',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pilihGambar,
                        child: Container(
                          width: double.infinity,
                          height: _bukti != null ? 180 : 110,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _bukti != null
                                  ? const Color(0xFF144B80)
                                  : Colors.grey.shade300,
                              width: _bukti != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: _bukti != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: Image.file(
                                        _bukti!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: InkWell(
                                        onTap: () =>
                                            setState(() => _bukti = null),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_outlined,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Ketuk untuk upload bukti',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'JPG, PNG (Maks. 5MB)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _konfirmasi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF144B80),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Konfirmasi Pembayaran',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
