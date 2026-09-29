import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/harvest_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/land_screen.dart';
import 'widgets/pawon_bottom_nav.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF9FAF9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF285438),
          primary: const Color(0xFF285438),
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
  // Index 0: Beranda
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
          _buildPlaceholderScreen('Penjualan'),
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
      backgroundColor: const Color(0xFFF9FAF9),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Color(0xFF285438),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Menu $title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF162A1D),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Halaman sedang dalam pengembangan',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B8072),
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
                  backgroundColor: const Color(0xFF285438),
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
