import 'package:flutter/material.dart';
import 'package:pdam_apps/Views/Bayartagihan.dart';
import 'package:pdam_apps/Views/DashboardAdmin.dart';
import 'package:pdam_apps/Views/DashboardCustomer.dart';
import 'package:pdam_apps/Views/Kelolalayanan.dart';
import 'package:pdam_apps/Views/Kelolapelanggan.dart';
import 'package:pdam_apps/Views/Kelolatagihan.dart';
import 'package:pdam_apps/Views/LoginAdmin.dart';
import 'package:pdam_apps/Views/LoginCustomer.dart';
import 'package:pdam_apps/Views/Pembayaranberhasil.dart';
import 'package:pdam_apps/Views/Register_View.dart';
import 'package:pdam_apps/Views/ProfileAdmin.dart';
import 'package:pdam_apps/Views/ProfileCustomer.dart';
import 'package:pdam_apps/Views/HistoryCustomer.dart';
import 'package:pdam_apps/Views/KelolaData.dart';
import 'package:pdam_apps/Views/Tambahlayanan.dart';
import 'package:pdam_apps/Views/Tambahpelanggan.dart';
import 'package:pdam_apps/Views/Tambahtagihan.dart';
import 'package:pdam_apps/Views/Verifikasipembayaran.dart';
import 'package:pdam_apps/Widgets/Splash_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        // Splash
        '/':                      (context) => const SplashScreen(),
        // Auth
        '/Register':              (context) => const RegisterView(),
        '/Login':                 (context) => const LoginAdmin(),
        '/LoginCustomer':         (context) => const LoginCustomer(),
        // Dashboard
        '/DashboardAdmin':        (context) => const DashboardAdmin(),
        '/DashboardCustomer':     (context) => const DashboardCustomer(),
        // Admin pages
        '/KelolaData':            (context) => const KelolaData(),
        '/ProfileAdmin':          (context) => const ProfileAdmin(),
        '/KelolaLayanan':         (context) => const KelolaLayanan(),
        '/TambahLayanan':         (context) => const TambahLayanan(),
        '/KelolaPelanggan':       (context) => const KelolaPelanggan(),
        '/TambahPelanggan':       (context) => const TambahPelanggan(),
        '/KelolaTagihan':         (context) => const KelolaTagihan(),
        '/TambahTagihan':         (context) => const TambahTagihan(),
        '/VerifikasiPembayaran':  (context) => const VerifikasiPembayaran(),
        // Customer pages
        '/HistoryCustomer':       (context) => const HistoryCustomer(),
        '/ProfileCustomer':       (context) => const ProfileCustomer(),
        '/BayarTagihan':          (context) => const BayarTagihan(),
        '/PembayaranBerhasil':    (context) => const PembayaranBerhasil(),
      },
    );
  }
}