import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    final serif = GoogleFonts.fraunces;
    final sans = GoogleFonts.dmSans;

    return TextTheme(
      displayLarge: serif(fontSize: 40, fontWeight: FontWeight.w600, height: 1.1, color: AppColors.textPrimary),
      displayMedium: serif(fontSize: 32, fontWeight: FontWeight.w600, height: 1.15, color: AppColors.textPrimary),
      headlineMedium: serif(fontSize: 24, fontWeight: FontWeight.w600, height: 1.2, color: AppColors.textPrimary),
      titleLarge: sans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleMedium: sans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: sans(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textPrimary),
      bodyMedium: sans(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.textSecondary),
      labelLarge: sans(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: AppColors.textPrimary),
      labelSmall: sans(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.4, color: AppColors.textSecondary),
    );
  }
}