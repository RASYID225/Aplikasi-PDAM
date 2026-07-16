import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/PdamApiService.dart';

class TambahTagihan extends StatefulWidget {
  const TambahTagihan({super.key});
  @override
  State<TambahTagihan> createState() => _TambahTagihanState();
}

class _TambahTagihanState extends State<TambahTagihan> {
  final _formKey = GlobalKey<FormState>();
  final _noMeter = TextEditingController();
  final _pemakaian = TextEditingController();
  bool _isLoading = true, _submitting = false;
  List _pelangganList = [];
  int? _customerId;
  DateTime _tanggal = DateTime.now();
  int _estimasi = 0;
  Map? _editData;

  @override
  void initState() {
    super.initState();
    _loadPelanggan();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && _editData == null) {
      _editData = args;
      _customerId = args['customer_id'];
      _noMeter.text = args['measurement_number'] ?? '';
      _pemakaian.text = args['usage_value']?.toString() ?? '';
      final int m = args['month'] ?? DateTime.now().month;
      final int y = args['year'] ?? DateTime.now().year;
      _tanggal = DateTime(y, m);
      _hitungEstimasi();
    }
  }

  @override
  void dispose() {
    _noMeter.dispose();
    _pemakaian.dispose();
    super.dispose();
  }

  Future<void> _loadPelanggan() async {
    final res = await ApiService.getPelanggan();
    if (!mounted) return;
    setState(() {
      _pelangganList = List.from(res['data'] ?? []);
      _isLoading = false;
    });
  }

  void _hitungEstimasi() {
    final p = int.tryParse(_pemakaian.text) ?? 0;
    // Cari harga dari pelanggan yang dipilih
    if (_customerId != null) {
      final cust = _pelangganList.firstWhere(
        (c) => c['id'] == _customerId,
        orElse: () => {},
      );
      final svc = cust['service'] as Map? ?? {};
      final int harga = (svc['price'] as num? ?? 2000).toInt();
      setState(() => _estimasi = (p * harga).toInt());
    } else {
      setState(() => _estimasi = p * 2000);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih pelanggan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _submitting = true);

    Map<String, dynamic> res;
    if (_editData != null) {
      // Soal 6: PATCH /bills/{id}
      res = await ApiService.updateTagihan(_editData!['id'], {
        "month": _tanggal.month,
        "year": _tanggal.year,
        "measurement_number": _noMeter.text,
        "usage_value": int.tryParse(_pemakaian.text) ?? 0,
      });
    } else {
      // Soal 6: POST /bills
      res = await ApiService.createTagihan({
        "customer_id": _customerId,
        "month": _tanggal.month,
        "year": _tanggal.year,
        "measurement_number": _noMeter.text,
        "usage_value": int.tryParse(_pemakaian.text) ?? 0,
      });
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editData != null ? 'Tagihan diperbarui' : 'Tagihan ditambahkan',
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
    const bStr = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
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
                        isEdit ? 'Edit Tagihan' : 'Tambah Tagihan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Lengkapi data di bawah ini',
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
                child: _isLoading
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
                              _label('Pelanggan'),
                              DropdownButtonFormField<int>(
                                value: _customerId,
                                hint: const Text(
                                  'Pilih Pelanggan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black38,
                                  ),
                                ),
                                isExpanded: true,
                                items: _pelangganList
                                    .map<DropdownMenuItem<int>>(
                                      (p) => DropdownMenuItem<int>(
                                        value: p['id'] as int,
                                        child: Text(
                                          '${p['name']} (${p['customer_number']})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: isEdit
                                    ? null
                                    : (v) {
                                        setState(() => _customerId = v);
                                        _hitungEstimasi();
                                      },
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
                                    v == null ? 'Pilih pelanggan' : null,
                              ),
                              const SizedBox(height: 16),
                              _label('Bulan & Tahun'),
                              InkWell(
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: _tanggal,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                    helpText: 'Pilih Bulan Tagihan',
                                  );
                                  if (d != null) setState(() => _tanggal = d);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${bStr[_tanggal.month]} ${_tanggal.year}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _label('Nomor Meter'),
                              _field(
                                _noMeter,
                                'Masukkan nomor meter',
                                type: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              _label('Nilai Pemakaian (m³)'),
                              TextFormField(
                                controller: _pemakaian,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _hitungEstimasi(),
                                decoration: InputDecoration(
                                  hintText: '0',
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
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _estimasi > 0
                                      ? const Color(0xFF144B80)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ESTIMASI TAGIHAN',
                                      style: TextStyle(
                                        color: _estimasi > 0
                                            ? Colors.white70
                                            : Colors.black38,
                                        fontSize: 11,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      _estimasi > 0
                                          ? 'Rp ${_fmt(_estimasi)}'
                                          : '-',
                                      style: TextStyle(
                                        color: _estimasi > 0
                                            ? Colors.white
                                            : Colors.black38,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
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
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _submitting ? null : _submit,
                                  icon: Icon(
                                    isEdit
                                        ? Icons.save_outlined
                                        : Icons.add_circle_outline,
                                  ),
                                  label: _submitting
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
                                              : 'Tambah Tagihan',
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
  String _fmt(int n) {
    final s = n.toString();
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
