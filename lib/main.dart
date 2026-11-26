import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/theme/tema_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawon_mobile/features/beranda/screens/layar_beranda.dart';
import 'package:pawon_mobile/features/panen/screens/layar_panen.dart';
import 'package:pawon_mobile/features/aktivitas/screens/layar_aktivitas.dart';
import 'package:pawon_mobile/features/lahan/screens/layar_lahan.dart';
import 'package:pawon_mobile/features/penjualan/screens/layar_penjualan.dart';
import 'package:pawon_mobile/core/widgets/navigasi_bawah_pawon.dart';
import 'package:pawon_mobile/features/auth/screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TemaController.instance.inisialisasi();
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: TemaController.instance.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'PawonTani Mobile',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: WarnaAplikasi.primaryBackground,
            colorScheme: ColorScheme.fromSeed(
              seedColor: WarnaAplikasi.primary,
              primary: WarnaAplikasi.primary,
              surface: Colors.white,
              brightness: Brightness.light,
            ),
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF141916),
            cardColor: const Color(0xFF1D2420),
            dividerColor: const Color(0xFF28332C),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Color(0xFF1D2420),
              surfaceTintColor: Colors.transparent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              fillColor: const Color(0xFF1D2420),
              filled: true,
              hintStyle: const TextStyle(color: Color(0xFFA0B3A6), fontSize: 13),
              labelStyle: const TextStyle(color: Color(0xFFE2E9E4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF28332C)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF28332C)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF488A62), width: 1.5),
              ),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF488A62),
              secondary: Color(0xFF6EE7B7),
              surface: Color(0xFF1D2420),
              onPrimary: Colors.white,
              onSurface: Color(0xFFF1F5F2),
            ),
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
          home: const AuthGate(),
        );
      },
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
