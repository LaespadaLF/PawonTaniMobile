import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_colors.dart';
import 'pages/main_screen.dart';

void main() {
  runApp(const PawonTaniApp());
}

class PawonTaniApp extends StatelessWidget {
  const PawonTaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawonTani',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: GoogleFonts.inter().fontFamily,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
