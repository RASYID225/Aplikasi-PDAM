import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/ApiService.dart';

class TambahPelanggan extends StatefulWidget {
  const TambahPelanggan({super.key});
  @override
  State<TambahPelanggan> createState() => _TambahPelangganState();
}

class _TambahPelangganState extends State<TambahPelanggan> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _alamat = TextEditingController();
  final _noCustomer = TextEditingController();
  bool _obscure = true, _isLoading = false, _loadingLayanan = true;
  int? _serviceId;
  List _layananList = [];
  Map? _editData;

  @override
  void initState() {
    super.initState();
    _loadLayanan();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && _editData == null) {
      _editData = args;
      _nama.text = args['name'] ?? '';
      _phone.text = args['phone'] ?? '';
      _alamat.text = args['address'] ?? '';
      _noCustomer.text = args['customer_number'] ?? '';
      _serviceId = args['service_id'];
    }
  }

  @override
  void dispose() {
    _nama.dispose();
    _username.dispose();
    _password.dispose();
    _phone.dispose();
    _alamat.dispose();
    _noCustomer.dispose();
    super.dispose();
  }

  // Ambil daftar layanan untuk dropdown
  Future<void> _loadLayanan() async {
    final res = await ApiService.getLayanan();
    if (!mounted) return;
    setState(() {
      _layananList = List.from(res['data'] ?? []);
      _loadingLayanan = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_serviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih layanan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    Map<String, dynamic> res;
    if (_editData != null) {
      // Soal 5: PATCH /customers/{id}
      res = await ApiService.updatePelanggan(_editData!['id'], {
        "name": _nama.text,
        "phone": _phone.text,
        "address": _alamat.text,
        "customer_number": _noCustomer.text,
        "service_id": _serviceId,
      });
    } else {
      // Soal 5: POST /customers
      res = await ApiService.createPelanggan({
        "username": _username.text,
        "password": _password.text,
        "name": _nama.text,
        "phone": _phone.text,
        "address": _alamat.text,
        "customer_number": _noCustomer.text,
        "service_id": _serviceId,
      });
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editData != null
                ? 'Pelanggan diperbarui'
                : 'Pelanggan ditambahkan',
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
                        isEdit ? 'Edit Pelanggan' : 'Data Pelanggan Baru',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Lengkapi formulir data pelanggan',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
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
                child: _loadingLayanan
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF144B80),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Nama Lengkap'),
                              _field(_nama, 'Masukkan Nama Lengkap'),
                              if (!isEdit) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _label('Username'),
                                          _field(_username, 'Username login'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _label('Password'),
                                          TextFormField(
                                            controller: _password,
                                            obscureText: _obscure,
                                            decoration: InputDecoration(
                                              hintText: '••••••',
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscure
                                                      ? Icons.visibility
                                                      : Icons.visibility_off,
                                                  size: 18,
                                                ),
                                                onPressed: () => setState(
                                                  () => _obscure = !_obscure,
                                                ),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 14,
                                                  ),
                                            ),
                                            validator: (v) =>
                                                (v == null || v.isEmpty)
                                                ? 'Wajib'
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                              _label('Nomor Pelanggan'),
                              _field(
                                _noCustomer,
                                'Contoh: PLG-001',
                                type: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              _label('Nomor Telepon'),
                              _field(
                                _phone,
                                '+62 812-3456-7890',
                                type: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              _label('Pilih Layanan'),
                              DropdownButtonFormField<int>(
                                value: _serviceId,
                                hint: const Text(
                                  'Pilih kategori layanan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black38,
                                  ),
                                ),
                                items: _layananList
                                    .map<DropdownMenuItem<int>>(
                                      (l) => DropdownMenuItem<int>(
                                        value: l['id'] as int,
                                        child: Text(l['name'] ?? '-'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _serviceId = v),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                                validator: (v) =>
                                    v == null ? 'Pilih layanan' : null,
                              ),
                              const SizedBox(height: 16),
                              _label('Alamat'),
                              TextFormField(
                                controller: _alamat,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText:
                                      'Masukkan alamat lengkap sesuai KTP',
                                  hintStyle: const TextStyle(
                                    color: Colors.black38,
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _submit,
                                  icon: Icon(
                                    isEdit
                                        ? Icons.save_outlined
                                        : Icons.person_add_outlined,
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
                                              : 'Tambah Pelanggan',
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF144B80),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
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
