import 'package:flutter/material.dart';
import 'package:pdam_apps/Models/User_login.dart';

class BottomNav extends StatefulWidget {
  final int activePage;
  const BottomNav(this.activePage, {super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  String role = '';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    // ✅ FIX: pakai loadFromPrefs, bukan getUserLogin() yang tidak ada
    final user = await UserLogin.loadFromPrefs();
    if (!mounted) return;

    if (user.token == null || user.token!.isEmpty) {
      // Token kosong → belum login → kembali ke Login
      Navigator.pushReplacementNamed(context, '/Login');
      return;
    }

    setState(() {
      role = user.role ?? '';
    });
  }

  void _getLink(int index) {
    // ✅ FIX: role API adalah "ADMIN" dan "CUSTOMER" (uppercase)
    if (role == 'ADMIN') {
      if (index == 0) Navigator.pushReplacementNamed(context, '/DashboardAdmin');
      if (index == 1) Navigator.pushReplacementNamed(context, '/KelolaData');
      if (index == 2) Navigator.pushReplacementNamed(context, '/ProfileAdmin');
    } else if (role == 'CUSTOMER') {
      if (index == 0) Navigator.pushReplacementNamed(context, '/DashboardCustomer');
      if (index == 1) Navigator.pushReplacementNamed(context, '/HistoryCustomer');
      if (index == 2) Navigator.pushReplacementNamed(context, '/ProfileCustomer');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role == 'ADMIN') {
      return BottomNavigationBar(
        selectedItemColor: const Color(0xFF144B80),
        unselectedItemColor: Colors.grey,
        currentIndex: widget.activePage,
        onTap: _getLink,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Kelola Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      );
    } else if (role == 'CUSTOMER') {
      return BottomNavigationBar(
        selectedItemColor: const Color(0xFF144B80),
        unselectedItemColor: Colors.grey,
        currentIndex: widget.activePage,
        onTap: _getLink,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      );
    }

    // Saat role masih loading tampilkan kosong
    return const SizedBox.shrink();
  }
}