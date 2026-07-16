import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';

class BayarTagihan extends StatefulWidget {
  const BayarTagihan({super.key});

  @override
  State<BayarTagihan> createState() => _BayarTagihanState();
}

class _BayarTagihanState extends State<BayarTagihan> {
  // ... [Logic variabel dan fungsi dibiarkan sama] ...
  bool _isLoading = false, _argsLoaded = false;
  Uint8List? _buktiBytes;
  String _buktiNama = '';
  int _billId = 0;
  String _periode = '-';
  final ImagePicker _picker = ImagePicker();
  static const _bulan = [
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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _billId =
          int.tryParse((args['billId'] ?? args['id'])?.toString() ?? '0') ?? 0;
      final month = int.tryParse(args['month']?.toString() ?? '0') ?? 0;
      final year = args['year']?.toString() ?? '';
      if (month >= 1 && month <= 12 && year.isNotEmpty)
        _periode = '${_bulan[month]} $year';
    }
    _argsLoaded = true;
  }

  Future<void> _pilihFoto(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _buktiBytes = bytes;
      _buktiNama = picked.name;
    });
  }

  Future<void> _pilihDokumen() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      if (!mounted) return;
      setState(() {
        _buktiBytes = result.files.single.bytes;
        _buktiNama = result.files.single.name;
      });
    }
  }

  Future<void> _kirimBukti() async {
    // 1. Cek validasi data
    if (_buktiBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih file bukti terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Keluar dari fungsi jika tidak ada file
    }

    setState(() => _isLoading = true);

    try {
      // 2. Panggil API
      final res = await ApiService.uploadPaymentProof(
        _billId,
        _buktiBytes!,
        _buktiNama.isEmpty ? 'bukti.jpg' : _buktiNama,
      );

      // 3. PENTING: Cek apakah widget masih "mounted" (terpasang) di layar
      // Jika user pindah halaman saat proses upload, fungsi ini akan berhenti di sini
      if (!mounted) return;

      setState(() => _isLoading = false);

      if (res['success'] == true) {
        Navigator.pushReplacementNamed(
          context,
          '/PembayaranBerhasil',
          arguments: {'payment': res['data'] ?? {}},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 4. Handle error dan cek mounted
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text(
          'Upload Bukti',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'Tagihan Periode',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    _periode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _showPickSourceSheet(),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _buktiBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_upload_rounded,
                            size: 50,
                            color: Color(0xFF4364F7),
                          ),
                          const SizedBox(height: 10),
                          const Text('Klik untuk upload bukti'),
                        ],
                      )
                    : Image.memory(_buktiBytes!, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kirimBukti,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4364F7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'KIRIM BUKTI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galeri'),
            onTap: () {
              Navigator.pop(ctx);
              _pilihFoto(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Kamera'),
            onTap: () {
              Navigator.pop(ctx);
              _pilihFoto(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Dokumen (PDF)'),
            onTap: () {
              Navigator.pop(ctx);
              _pilihDokumen();
            },
          ),
        ],
      ),
    );
  }
}
