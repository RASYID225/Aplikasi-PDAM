import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';

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
      res = await ApiService.updatePelanggan(_editData!['id'], {
        "name": _nama.text,
        "phone": _phone.text,
        "address": _alamat.text,
        "customer_number": _noCustomer.text,
        "service_id": _serviceId,
      });
    } else {
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
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Pelanggan' : 'Pelanggan Baru',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: _loadingLayanan
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4364F7)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Nama Lengkap'),
                      _field(
                        _nama,
                        'Masukkan Nama Lengkap',
                        Icons.person_outline,
                      ),
                      if (!isEdit) ...[
                        const SizedBox(height: 16),
                        _label('Username'),
                        _field(
                          _username,
                          'Username login',
                          Icons.alternate_email,
                        ),
                        const SizedBox(height: 16),
                        _label('Password'),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: '••••••',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF4364F7),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Wajib' : null,
                        ),
                      ],
                      const SizedBox(height: 16),
                      _label('Nomor Pelanggan'),
                      _field(
                        _noCustomer,
                        'Contoh: PLG-001',
                        Icons.badge_outlined,
                        type: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      _label('Nomor Telepon'),
                      _field(
                        _phone,
                        '+62 812-3456-7890',
                        Icons.phone_outlined,
                        type: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _label('Pilih Layanan'),
                      DropdownButtonFormField<int>(
                        value: _serviceId,
                        hint: const Text(
                          'Pilih kategori layanan',
                          style: TextStyle(color: Colors.black38),
                        ),
                        items: _layananList
                            .map<DropdownMenuItem<int>>(
                              (l) => DropdownMenuItem<int>(
                                value: l['id'] as int,
                                child: Text(l['name'] ?? '-'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _serviceId = v),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          prefixIcon: const Icon(
                            Icons.water_drop_outlined,
                            color: Color(0xFF4364F7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => v == null ? 'Pilih layanan' : null,
                      ),
                      const SizedBox(height: 16),
                      _label('Alamat Lengkap'),
                      TextFormField(
                        controller: _alamat,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Masukkan alamat lengkap sesuai KTP',
                          hintStyle: const TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submit,
                          icon: Icon(
                            isEdit
                                ? Icons.save_outlined
                                : Icons.person_add_outlined,
                            color: Colors.white,
                          ),
                          label: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  isEdit
                                      ? 'Simpan Perubahan'
                                      : 'Tambah Pelanggan',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4364F7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                            shadowColor: const Color(
                              0xFF4364F7,
                            ).withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      t,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A2E),
      ),
    ),
  );

  Widget _field(
    TextEditingController c,
    String h,
    IconData icon, {
    TextInputType? type,
  }) => TextFormField(
    controller: c,
    keyboardType: type,
    decoration: InputDecoration(
      hintText: h,
      hintStyle: const TextStyle(color: Colors.black38),
      prefixIcon: Icon(icon, color: const Color(0xFF4364F7)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
    validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
  );
}
