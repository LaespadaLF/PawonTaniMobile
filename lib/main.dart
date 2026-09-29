import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawon_mobile/features/beranda/screens/layar_beranda.dart';
import 'package:pawon_mobile/features/panen/screens/layar_panen.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_aktivitas.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_lahan.dart';
import 'package:pawon_mobile/features/penjualan/screens/layar_penjualan.dart';
import 'package:pawon_mobile/core/widgets/navigasi_bawah_pawon.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PawonTaniApp());
}

class PawonTaniApp extends StatelessWidget {
  const PawonTaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawonTani Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: WarnaAplikasi.primaryBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: WarnaAplikasi.primary,
          primary: WarnaAplikasi.primary,
          surface: Colors.white,
        ),
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  // Index 0: Beranda (Home screen)
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onNavigateTab: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          LandScreen(
            onBackToHome: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ), // Lahan screen
          ActivityScreen(
            onBackToHome: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          const HarvestScreen(), // Panen screen
          const PenjualanScreen(),
        ],
      ),
      bottomNavigationBar: PawonBottomNav(
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
