import 'package:flutter/material.dart';

/// Gen Z Dark Glassmorphism Design Tokens & Color Palette
class AppColors {
  AppColors._();

  // Primary & Background
  static const Color royalBlue = Color(0xFF2563EB); // Sign-in / Brand primary
  static const Color skyBlue = Color(0xFF60A5FA);
  static const Color topGlowPrimary = Color(0xFF3B82F6);
  static const Color topGlowSecondary = Color(0xFF8B5CF6);

  // Legacy compatibility tokens
  static const Color deepNavy = Color(0xFF0F172A);
  static const Color iceBlue = Color(0xFFDBEAFE);
  static const Color snowWhite = Color(0xFFFCFCFD);
  static const Color border = Color(0xFFE2E8F0);
  static const Color warning = Color(0xFFF59E0B);
  static const List<Color> brandGradient = [royalBlue, skyBlue];

  // Dark Canvas & Glass Surfaces
  static const Color darkCanvas = Color(0xFF090D16);
  static const Color surfaceCard = Color(0xFF131B2E);
  static const Color glassSurface = Color(0x1F1E293B); // Translucent 12%
  static const Color glassBorder = Color(0x26FFFFFF);  // White 15%
  static const Color glassHighlight = Color(0x3DFFFFFF); // White 24%

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Accents
  static const Color neonGreen = Color(0xFF4ADE80); // FREE Badge
  static const Color accentPink = Color(0xFFF472B6);  // Music
  static const Color accentCyan = Color(0xFF22D3EE);  // Film
  static const Color accentOrange = Color(0xFFFB923C); // Sports
  static const Color accentPurple = Color(0xFFC084FC); // Art
  static const Color accentYellow = Color(0xFFFACC15); // Food
  static const Color accentIndigo = Color(0xFF818CF8); // Nightlife
  static const Color accentTeal = Color(0xFF2DD4BF);   // Education / Community

  // Functional
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  // Gradients
  static const List<Color> topGlowGradient = [
    Color(0x994F46E5), // Indigo glow
    Color(0x662563EB), // Royal Blue glow
    Colors.transparent,
  ];

  static const List<Color> cardGradientOverlay = [
    Colors.transparent,
    Color(0x99090D16),
    Color(0xF0090D16),
  ];
}
