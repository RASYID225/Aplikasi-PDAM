import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/ApiService.dart';

class TambahLayanan extends StatefulWidget {
  const TambahLayanan({super.key});
  @override
  State<TambahLayanan> createState() => _TambahLayananState();
}

class _TambahLayananState extends State<TambahLayanan> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();
  final _harga = TextEditingController();
  bool _isLoading = false;

  // Cek apakah ada data edit yang dikirim via arguments
  Map? _editData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && _editData == null) {
      _editData = args;
      _nama.text = args['name']?.toString() ?? '';
      _min.text = args['min_usage']?.toString() ?? '';
      _max.text = args['max_usage']?.toString() ?? '';
      _harga.text = args['price']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nama.dispose();
    _min.dispose();
    _max.dispose();
    _harga.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final body = {
      "name": _nama.text,
      "min_usage": _min.text,
      "max_usage": _max.text,
      "price": _harga.text,
    };

    Map<String, dynamic> res;
    if (_editData != null) {
      // Soal 4: PATCH /services/{id}
      res = await ApiService.updateLayanan(_editData!['id'], body);
    } else {
      // Soal 4: POST /services
      res = await ApiService.createLayanan(body);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editData != null ? 'Layanan diperbarui' : 'Layanan ditambahkan',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
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
    final isEdit = _editData != null;
    return Scaffold(
      backgroundColor: const Color(0xFF144B80),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Layanan' : 'Tambah Layanan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Data layanan PDAM',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Nama Layanan'),
                        _field(_nama, 'Contoh : Rumah Tangga A3'),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Min. Pemakaian (m³)'),
                                  _field(
                                    _min,
                                    'Contoh : 20',
                                    type: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Maks. Pemakaian (m³)'),
                                  _field(
                                    _max,
                                    'Contoh : 25',
                                    type: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _label('Harga per m³ (Rp)'),
                        _field(
                          _harga,
                          'Contoh : 1400',
                          type: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F4FD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF0369A1),
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Pastikan data pemakaian sudah sesuai dengan foto meteran fisik di lapangan.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0369A1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _submit,
                            icon: Icon(
                              isEdit
                                  ? Icons.save_outlined
                                  : Icons.add_circle_outline,
                            ),
                            label: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isEdit
                                        ? 'Simpan Perubahan'
                                        : 'Tambah Layanan',
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF144B80),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );
  Widget _field(TextEditingController c, String h, {TextInputType? type}) =>
      TextFormField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: h,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
      );
}
