import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart'; // Sesuaikan dengan lokasi ApiService kamu

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

    final minVal = int.tryParse(_min.text.trim());
    final maxVal = int.tryParse(_max.text.trim());
    final priceVal = int.tryParse(_harga.text.trim());

    if (minVal == null || maxVal == null || priceVal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Min, Max, dan Harga harus berupa angka valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (minVal > maxVal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batasan Min tidak boleh lebih besar dari Max'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final body = {
      "name": _nama.text.trim(),
      "min_usage": minVal,
      "max_usage": maxVal,
      "price": priceVal,
    };

    Map<String, dynamic> res;
    if (_editData != null) {
      final id = int.tryParse(_editData!['id'].toString());
      if (id == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID layanan tidak valid'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      res = await ApiService.updateLayanan(id, body);
    } else {
      res = await ApiService.createLayanan(body);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editData != null
                ? 'Layanan berhasil diperbarui!'
                : 'Layanan berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message']?.toString() ?? 'Gagal menyimpan data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(_editData != null ? 'Edit Layanan' : 'Tambah Layanan', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF144B80),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Nama Golongan Tarif / Layanan'),
              _field(_nama, 'Contoh: Rumah Tangga A', type: TextInputType.text),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Batasan Min (m³)'),
                        _field(_min, '0', type: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Batasan Max (m³)'),
                        _field(_max, '20', type: TextInputType.number),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _label('Harga per m³ (Rupiah)'),
              _field(_harga, 'Tarif rupiah angka saja, misal: 1500', type: TextInputType.number),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF144B80),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_editData != null ? 'Simpan Perubahan' : 'Tambah Layanan Baru', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
  );

  Widget _field(TextEditingController c, String h, {TextInputType? type}) => TextFormField(
    controller: c,
    keyboardType: type,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: h,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF144B80), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
  );
}