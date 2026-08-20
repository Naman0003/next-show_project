// lib/theme/app_theme.dart
//
// Color and type tokens sourced from the NextShow brand moodboard
// (apps/user_app/assets/moodboard.jpg). Keep this file as the single
// source of truth for brand color/type — screens should reference
// AppColors / AppTheme rather than hardcoding hex values.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color royalBlue = Color(0xFF2563EB);
  static const Color deepNavy = Color(0xFF0F172A);
  static const Color skyBlue = Color(0xFF60A5FA);
  static const Color iceBlue = Color(0xFFDBEAFE);
  static const Color snowWhite = Color(0xFFFCFCFD);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  /// Brand gradient (Royal Blue -> Sky Blue) for hero text/logo treatments.
  static const List<Color> brandGradient = [royalBlue, skyBlue];
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light();
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      displayMedium: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      displaySmall: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      headlineSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
      titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleSmall: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.inter(color: AppColors.textPrimary),
      bodySmall: GoogleFonts.inter(color: AppColors.textSecondary),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: AppColors.textSecondary),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.snowWhite,
      primaryColor: AppColors.royalBlue,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.royalBlue,
        secondary: AppColors.skyBlue,
        surface: AppColors.snowWhite,
        error: AppColors.error,
        onPrimary: AppColors.snowWhite,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.manrope(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.royalBlue),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.royalBlue,
          foregroundColor: AppColors.snowWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.royalBlue,
        foregroundColor: AppColors.snowWhite,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.white,
        selectedColor: AppColors.royalBlue,
        side: const BorderSide(color: AppColors.border),
        labelStyle: GoogleFonts.inter(color: AppColors.textPrimary),
        secondaryLabelStyle: GoogleFonts.inter(color: AppColors.snowWhite),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
    );
  }
}
