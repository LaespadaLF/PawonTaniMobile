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
  // Index 4: Penjualan (Sales screen)
  int _currentIndex = 4;

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
          _buildPlaceholderScreen('Edukasi'),
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

  Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: WarnaAplikasi.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: WarnaAplikasi.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Menu $title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: WarnaAplikasi.primaryDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Halaman sedang dalam pengembangan',
                style: TextStyle(
                  fontSize: 12,
                  color: WarnaAplikasi.textGray,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; // back to Data Panen
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WarnaAplikasi.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Buka Data Panen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

