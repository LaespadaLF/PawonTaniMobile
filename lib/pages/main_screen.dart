import 'package:flutter/material.dart';
import '../widgets/app_bottom_navigation.dart';
import 'lahan/lahan_screen.dart';
import '../screens/beranda_screen.dart';
import '../screens/aktivitas_screen.dart';
import '../screens/panen_screen.dart';
import '../screens/penjualan_screen.dart';
import '../screens/edukasi_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Default to Beranda

  final List<Widget> _pages = const [
    BerandaScreen(),
    LahanScreen(),
    AktivitasScreen(),
    PanenScreen(),
    PenjualanScreen(),
    EdukasiScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
