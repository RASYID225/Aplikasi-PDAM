import 'package:flutter/material.dart';
import 'package:pdam_apps/Services/User.dart';
import 'package:pdam_apps/Views/LoginAdmin.dart';
import 'package:pdam_apps/Widgets/Alert.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  UserService user = UserService();
  final formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController username = TextEditingController(); 
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    name.dispose();
    username.dispose();
    phone.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var data = <String, String>{
        "name": name.text,
        "username": username.text,   
        "phone": phone.text,
        "password": password.text,
      };

      var result = await user.registerUser(data);

      if (!mounted) return;

      if (result.status == true) {
        name.clear();
        username.clear();
        phone.clear();
        password.clear();
        setState(() => _isLoading = false);
        AlertMessage().showAlert(context, result.message, true);
      } else {
        setState(() => _isLoading = false);
        AlertMessage().showAlert(context, result.message, false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AlertMessage().showAlert(context, 'Terjadi kesalahan: $e', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Selamat Datang',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Daftar akun Admin PDAM Anda',
                            style: TextStyle(color: Colors.blue[900], fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Field: Nama
                          TextFormField(
                            controller: name,
                            decoration: _inputDecoration('Nama Lengkap', Icons.person),
                            validator: (value) =>
                                (value == null || value.isEmpty) ? 'Nama harus diisi' : null,
                          ),
                          const SizedBox(height: 20),

                          // Field: UserName
                          TextFormField(
                            controller: username,
                            decoration: _inputDecoration('Username', Icons.alternate_email),
                            validator: (value) =>
                                (value == null || value.isEmpty) ? 'Username harus diisi' : null,
                          ),
                          const SizedBox(height: 20),

                          // Field: Phone
                          TextFormField(
                            controller: phone,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration('Nomor Telepon', Icons.phone),
                            validator: (value) =>
                                (value == null || value.isEmpty) ? 'Nomor telepon harus diisi' : null,
                          ),
                          const SizedBox(height: 20),

                          // Field: Password
                          TextFormField(
                            controller: password,
                            obscureText: _isPasswordObscured,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_isPasswordObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () => setState(
                                    () => _isPasswordObscured = !_isPasswordObscured),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Password harus diisi';
                              if (value.length < 6) return 'Password minimal 6 karakter';
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Tombol Daftar
                          MaterialButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            color: Colors.blue[900],
                            disabledColor: Colors.blue[200],
                            minWidth: double.infinity,
                            height: 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    'Daftar',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                          const SizedBox(height: 16),

                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginAdmin()),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Sudah punya akun? ',
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: 'Masuk Sekarang',
                                      style: TextStyle(
                                          color: Colors.blue[900],
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildBottomItem(
                                context: context,
                                icon: Icons.person_outline,
                                label: 'Pelanggan',
                                isActive: false,
                              ),
                              const SizedBox(width: 80),
                              _buildBottomItem(
                                context: context,
                                icon: Icons.work,
                                label: 'Admin',
                                isActive: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.5),
    ),
  );
}

Widget _buildBottomItem({
  required BuildContext context,
  required IconData icon,
  required String label,
  required bool isActive,
}) {
  Color itemColor = isActive ? const Color(0xFF007BFF) : Colors.black87;
  return InkWell(
    onTap: () {
      if (label == 'Admin') {
        Navigator.pushNamed(context, '/Login');
      } else if (label == 'Pelanggan') {
        Navigator.pushNamed(context, '/LoginCustomer');
      }
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: itemColor, width: 2),
          ),
          child: Icon(icon, color: itemColor, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: itemColor,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}