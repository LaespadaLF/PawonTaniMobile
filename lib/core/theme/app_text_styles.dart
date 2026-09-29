import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display / Page Title: fontSize 30-32, fontWeight 700-800
  static TextStyle display = GoogleFonts.inter(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Section Title: fontSize 22-24, fontWeight 700
  static TextStyle sectionTitle = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Card Title: fontSize 18-20, fontWeight 600-700
  static TextStyle cardTitle = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body: fontSize 15-16
  static TextStyle body = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // Secondary: fontSize 13-14
  static TextStyle secondary = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Caption: fontSize 12-13
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );
}
