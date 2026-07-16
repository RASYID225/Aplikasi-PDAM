import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _phone = TextEditingController();
  final _alamat = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Sesuaikan dengan method API Anda untuk mengambil data profil saat ini
    final res = await ApiService.getCustomerProfile();
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() {
        _nama.text = res['data']['name'] ?? '';
        _phone.text = res['data']['phone'] ?? '';
        _alamat.text = res['data']['address'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Sesuaikan nama fungsi dengan ApiService Anda (misal: updateProfile)
    final res = await ApiService.updateProfile({
      "name": _nama.text,
      "phone": _phone.text,
      "address": _alamat.text,
    });

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Gagal memperbarui'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _nama.dispose();
    _phone.dispose();
    _alamat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A2E))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Nama Lengkap'),
                _field(_nama, 'Masukkan nama', Icons.person_outline),
                const SizedBox(height: 16),
                _label('Nomor Telepon'),
                _field(_phone, '+62 8xx-xxxx-xxxx', Icons.phone_outlined, type: TextInputType.phone),
                const SizedBox(height: 16),
                _label('Alamat'),
                TextFormField(
                  controller: _alamat,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Alamat lengkap',
                    prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF4364F7)),
                    filled: true, fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4364F7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 5, shadowColor: const Color(0xFF4364F7).withOpacity(0.4),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('SIMPAN PERUBAHAN', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(padding: const EdgeInsets.only(bottom: 8, top: 4), child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))));
  
  Widget _field(TextEditingController c, String h, IconData icon, {TextInputType? type}) => TextFormField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: h,
          prefixIcon: Icon(icon, color: const Color(0xFF4364F7)),
          filled: true, fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
      );
}