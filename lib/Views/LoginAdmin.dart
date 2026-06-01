import 'package:flutter/material.dart';
import 'package:pdam_apps/Models/User_login.dart';
import 'package:pdam_apps/Services/User.dart';
import 'package:pdam_apps/Views/Register_View.dart';
import 'package:pdam_apps/Widgets/Alert.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  UserService user = UserService();
  final formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isLoading = false;
  bool showPass = true;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      var data = <String, String>{
        "username": username.text,
        "password": password.text,
      };

      var result = await user.loginUser(data);

      if (!mounted) return;
      setState(() => isLoading = false);

      if (result.status == true) {
        AlertMessage().showAlert(context, result.message, true);

        // Cek role → arahkan ke dashboard yang sesuai
        final role = await UserLogin.getRole();
        if (!mounted) return;
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;

        if (role == 'ADMIN') {
          Navigator.pushReplacementNamed(context, '/DashboardAdmin');
        } else {
          // Kalau ternyata login sebagai customer, arahkan ke dashboard customer
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
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              // --- HEADER ---
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
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
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 15,
                            ),
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
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Label & Input Username
                                const Text(
                                  'Username',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                      borderSide: BorderSide(
                                        color: Colors.blue.shade900,
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

                                // Label & Input Password
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: password,
                                  obscureText: showPass,
                                  decoration: InputDecoration(
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
                                      borderSide: BorderSide(
                                        color: Colors.blue.shade900,
                                        width: 1.5,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
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

                                const SizedBox(height: 32),

                                // Tombol Masuk
                                MaterialButton(
                                  onPressed: isLoading ? null : _handleLogin,
                                  color: Colors.blue[900],
                                  disabledColor: Colors.blue[200],
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
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),

                                const SizedBox(height: 16),

                                // Link ke Register
                                Center(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterView(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Belum punya akun? ',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Daftar Sekarang',
                                            style: TextStyle(
                                              color: Colors.blue[900],
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
                        ),
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

Widget _buildBottomItem({
  required BuildContext context,
  required IconData icon,
  required String label,
  required bool isActive,
}) {
  Color itemColor = isActive ? Colors.blue.shade900 : Colors.black87;
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
