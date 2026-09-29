import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pawon_mobile/features/penjualan/screens/layar_penjualan.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const PenjualanTestApp());
}

class PenjualanTestApp extends StatelessWidget {
  const PenjualanTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawonTani - Penjualan',
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
      home: const PenjualanScreen(),
    );
  }
}

