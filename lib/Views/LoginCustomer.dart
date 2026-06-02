import 'package:flutter/material.dart';
import 'package:pdam_apps/Models/User_login.dart';
import 'package:pdam_apps/Services/User.dart';
import 'package:pdam_apps/Widgets/Alert.dart';

class LoginCustomer extends StatefulWidget {
  const LoginCustomer({super.key});

  @override
  State<LoginCustomer> createState() => _LoginCustomerState();
}

class _LoginCustomerState extends State<LoginCustomer> {
  UserService user = UserService();
  final formKey = GlobalKey<FormState>();

  // ✅ Ganti nama controller dari 'email' → 'username'
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();

  bool isLoading = false;
  bool showPass = true;

  @override
  void dispose() {
    // ✅ Dispose controller agar tidak memory leak
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // ✅ Validasi form dulu
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // ✅ Field "username" sesuai API /auth
      var data = <String, String>{
        "username": username.text,
        "password": password.text,
      };

      var result = await user.loginUser(data);

      // ✅ Cek mounted sebelum update UI setelah await
      if (!mounted) return;
      setState(() => isLoading = false);

      if (result.status == true) {
        AlertMessage().showAlert(context, result.message, true);

        // ✅ Cek role untuk tentukan halaman tujuan
        final role = await UserLogin.getRole();

        if (!mounted) return;
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        if (role == 'ADMIN') {
          Navigator.pushReplacementNamed(context, '/DashboardAdmin');
        } else {
          Navigator.pushReplacementNamed(context, '/DashboardCustomer');
        }
      } else {
        AlertMessage().showAlert(context, result.message, false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      AlertMessage().showAlert(context, 'Terjadi kesalahan: $e', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF144B80),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- HEADER ---
            const Padding(
              padding: EdgeInsets.only(
                top: 80.0,
                bottom: 40.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Column(
                children: [
                  Text(
                    'Selamat Datang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Masuk ke akun PDAM Anda',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

            // --- FORM AREA ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 30.0,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: // ✅ Form widget ditambahkan di sini!
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label Username
                        const Text(
                          'Username',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // ✅ Input Username (bukan Email)
                        TextFormField(
                          controller: username,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Username',
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF144B80),
                                width: 1.5,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username harus diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Label Password
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Input Password
                        TextFormField(
                          controller: password,
                          obscureText: showPass,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF144B80),
                                width: 1.5,
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => showPass = !showPass),
                              icon: Icon(
                                showPass
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password harus diisi';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: Color(0xFF144B80),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Tombol Masuk
                        MaterialButton(
                          // ✅ Pakai fungsi _handleLogin
                          onPressed: isLoading ? null : _handleLogin,
                          color: const Color(0xFF144B80),
                          disabledColor: const Color(
                            0xFF144B80,
                          ).withOpacity(0.5),
                          minWidth: double.infinity,
                          height: 50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: InkWell(
                            onTap: () {
                              // Arahkan ke halaman register jika ada
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: 'Belum punya akun? ',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Hubungi Admin',
                                    style: TextStyle(
                                      color: Color(0xFF144B80),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bottom Menu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildBottomItem(
                              context: context,
                              icon: Icons.person,
                              label: 'Pelanggan',
                              isActive: true,
                            ),
                            const SizedBox(width: 80),
                            _buildBottomItem(
                              context: context,
                              icon: Icons.work_outline,
                              label: 'Admin',
                              isActive: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
}

Widget _buildBottomItem({
  required BuildContext context,
  required IconData icon,
  required String label,
  required bool isActive,
}) {
  Color itemColor = isActive ? const Color(0xFF144B80) : Colors.black87;
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
