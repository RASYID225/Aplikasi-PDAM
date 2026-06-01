import 'package:flutter/material.dart';
import 'package:pdam_apps/Models/User_login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Tampilkan splash 3 detik
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // ✅ Cek apakah user sudah pernah login
    final isLoggedIn = await UserLogin.isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      final role = await UserLogin.getRole();
      if (!mounted) return;
      if (role == 'ADMIN') {
        Navigator.pushReplacementNamed(context, '/DashboardAdmin');
      } else {
        Navigator.pushReplacementNamed(context, '/DashboardCustomer');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/Register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('Assets/Images/PDAM.png', width: 200, height: 200),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF144B80),
                  Color(0xFF007BFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: const Text(
                'PDAM',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'MENGALIR UNTUK KEHIDUPAN',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFF144B80),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}