import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';

class VerifikasiPembayaran extends StatefulWidget {
  const VerifikasiPembayaran({super.key});
  @override
  State<VerifikasiPembayaran> createState() => _VerifikasiPembayaranState();
}

class _VerifikasiPembayaranState extends State<VerifikasiPembayaran> {
  Map _bill = {};
  Map _payment = {};
  bool _argsLoaded = false,
      _isLoading = false,
      _proofLoading = true,
      _proofError = false;
  Uint8List? _proofBytes;

  static const _namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    _bill = args['bill'] as Map? ?? {};
    _payment = args['payment'] as Map? ?? {};
    _argsLoaded = true;
    _loadProof();
  }

  String get _namaCustomer =>
      (_bill['customer'] as Map? ?? {})['name']?.toString() ?? '-';
  String get _noCustomer =>
      (_bill['customer'] as Map? ?? {})['customer_number']?.toString() ?? '-';
  int get _paymentId => int.tryParse(_payment['id']?.toString() ?? '0') ?? 0;
  String get _proofFileName => _payment['payment_proof']?.toString() ?? '';
  bool get _isImageProof {
    final name = _proofFileName.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png');
  }

  String get _periode {
    final bulan = int.tryParse(_bill['month']?.toString() ?? '0') ?? 0;
    final tahun = _bill['year']?.toString() ?? '';
    if (bulan >= 1 && bulan <= 12 && tahun.isNotEmpty)
      return '${_namaBulan[bulan]} $tahun';
    return '-';
  }

  Future<void> _loadProof() async {
    setState(() {
      _proofLoading = true;
      _proofError = false;
    });
    if (_proofFileName.isEmpty) {
      if (!mounted) return;
      setState(() {
        _proofLoading = false;
        _proofError = true;
      });
      return;
    }
    final bytes = await ApiService.fetchPaymentProof(_proofFileName);
    if (!mounted) return;
    setState(() {
      _proofBytes = bytes != null ? Uint8List.fromList(bytes) : null;
      _proofLoading = false;
      _proofError = bytes == null;
    });
  }

  Future<void> _terima() async {
    if (_paymentId == 0)
      return _showSnack('Data pembayaran tidak valid', false);
    final konfirmasi = await _dialog(
      'Terima Pembayaran',
      'Bukti sudah sesuai dan pembayaran diterima?',
      confirmLabel: 'Terima',
      confirmColor: const Color(0xFF4364F7),
    );
    if (konfirmasi != true) return;

    setState(() => _isLoading = true);
    final res = await ApiService.verifyPayment(_paymentId);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _showSnack('Pembayaran diterima — tagihan lunas', true);
      Navigator.pop(context, true);
    } else {
      _showSnack(res['message']?.toString() ?? 'Gagal menerima', false);
    }
  }

  Future<void> _tolak() async {
    if (_paymentId == 0)
      return _showSnack('Data pembayaran tidak valid', false);
    final konfirmasi = await _dialog(
      'Tolak Pembayaran',
      'Yakin menolak bukti ini?\nPelanggan harus upload ulang.',
      confirmLabel: 'Tolak',
      confirmColor: Colors.red,
    );
    if (konfirmasi != true) return;

    setState(() => _isLoading = true);
    final res = await ApiService.rejectPayment(_paymentId);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      _showSnack('Bukti pembayaran ditolak', true);
      Navigator.pop(context, true);
    } else {
      _showSnack(res['message']?.toString() ?? 'Gagal menolak', false);
    }
  }

  void _showSnack(String msg, bool ok) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );

  Future<bool?> _dialog(
    String title,
    String content, {
    required String confirmLabel,
    required Color confirmColor,
  }) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            confirmLabel,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text(
          'Verifikasi Pembayaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- INFO PELANGGAN CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      _namaCustomer.isNotEmpty
                          ? _namaCustomer[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF4364F7),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _namaCustomer,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No. $_noCustomer',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Periode: $_periode',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'MENUNGGU',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- BUKTI TRANSFER PREVIEW ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'File Bukti Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildProofPreview(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF4364F7)),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _tolak,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Tolak Bukti',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _terima,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4364F7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: const Color(0xFF4364F7).withOpacity(0.4),
                      ),
                      child: const Text(
                        'Terima & Lunas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofPreview() {
    if (_proofLoading)
      return Container(
        height: 260,
        color: const Color(0xFFF8FAFC),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF4364F7)),
        ),
      );
    if (_proofError || _proofBytes == null)
      return Container(
        height: 180,
        color: const Color(0xFFF8FAFC),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              const Text(
                'Gagal memuat file',
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(onPressed: _loadProof, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    if (_isImageProof)
      return Image.memory(
        _proofBytes!,
        width: double.infinity,
        fit: BoxFit.contain,
      );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 50, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            _proofFileName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dokumen tidak dapat dipratinjau.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
