import 'package:flutter/material.dart';

/// Light UI Design Tokens for Next Show (Gen Z Aesthetic)
class AppColors {
  AppColors._();

  // Background & Canvas
  static const Color lightCanvas = Color(0xFFF8F9FA); // Off-white clean background
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F3F5);

  // Black & Grey UI Elements
  static const Color darkPrimary = Color(0xFF121212); // Rich Black
  static const Color darkSecondary = Color(0xFF2B2D42);
  static const Color textPrimary = Color(0xFF111827);  // High contrast text
  static const Color textSecondary = Color(0xFF6B7280); // Muted text
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);  // Subtle borders

  // Badges & Accents
  static const Color heartRed = Color(0xFFEF4444);
  static const Color neonGreen = Color(0xFF22C55E);
  static const Color freeChipBackground = Color(0x33FFFFFF); // Translucent 20%
  static const Color freeChipBorder = Color(0x66FFFFFF);

  // Bottom Nav
  static const Color bottomNavDark = Color(0xFF121212);
  static const Color bottomNavActiveCircle = Color(0xFFFFFFFF);

  // Legacy compatibility tokens
  static const Color royalBlue = Color(0xFF2563EB);
  static const Color skyBlue = Color(0xFF60A5FA);
  static const Color deepNavy = Color(0xFF0F172A);
  static const Color iceBlue = Color(0xFFDBEAFE);
  static const Color snowWhite = Color(0xFFFCFCFD);
  static const Color border = Color(0xFFE5E7EB);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color darkCanvas = Color(0xFF121212);
  static const Color glassSurface = Color(0x1F1E293B);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const List<Color> brandGradient = [darkPrimary, darkSecondary];
  static const List<Color> topGlowGradient = [Colors.transparent, Colors.transparent];
  static const List<Color> cardGradientOverlay = [
    Colors.transparent,
    Color(0x99000000),
    Color(0xF0000000),
  ];
}
