import 'dart:ui' as ui;

import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_kit/ui_kit.dart';

/// Dark, cinematic design tokens for the Discovery homepage only — the rest
/// of the app stays on `ui_kit`'s light `NSColors`/`NSTextStyles`. Brand
/// accent (royal blue) is unchanged from the rest of the app; only the
/// surface/background palette is new here.
class CinemaColors {
  CinemaColors._();

  static const Color background = Color(0xFF0A0E17);
  static const Color surfaceElevated = Color(0xFF161B29);
  static final Color glassFill = Colors.white.withOpacity(0.06);
  static final Color glassBorder = Colors.white.withOpacity(0.10);
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color shimmerHighlight = Color(0xFF2A3450);

  /// One saturated color per [EventCategory], for the category tile grid
  /// only — every other accent on this screen stays [NSColors.royalBlue].
  static Color forCategory(EventCategory category) => switch (category) {
        EventCategory.movie => const Color(0xFFE0435D),
        EventCategory.comedy => const Color(0xFFF5A623),
        EventCategory.music => const Color(0xFF22C55E),
        EventCategory.theatre => const Color(0xFF8B5CF6),
      };
}

class CinemaTextStyles {
  CinemaTextStyles._();

  static TextStyle get spotlightTitle => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w800,
        color: CinemaColors.textPrimary,
        fontSize: 28,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get sectionHeader => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        color: CinemaColors.textPrimary,
        fontSize: 22,
      );

  static TextStyle get cardTitle => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w600,
        color: CinemaColors.textPrimary,
        fontSize: 15,
      );

  static TextStyle get meta => GoogleFonts.inter(
        color: CinemaColors.textMuted,
        fontSize: 12,
      );

  /// Comfortable long-form reading color on dark — brighter than [meta]
  /// (which is for short labels), dimmer than [CinemaColors.textPrimary]
  /// (which is for headings) so paragraphs don't glare.
  static TextStyle get body => GoogleFonts.inter(
        color: const Color(0xFFC7CDD9),
        fontSize: 14,
        height: 1.5,
      );
}

/// A frosted-glass pill badge (icon + label) — same `BackdropFilter`
/// technique as `search_screen.dart`'s glass search bar and `ui_kit`'s
/// `NSBottomNavBar`, restyled for the dark cinema background.
class CinemaGlassBadge extends StatelessWidget {
  const CinemaGlassBadge({
    super.key,
    this.icon,
    required this.label,
    this.iconColor,
  });

  final IconData? icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: CinemaColors.glassFill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: CinemaColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: iconColor ?? CinemaColors.textPrimary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: CinemaTextStyles.meta.copyWith(
                  color: CinemaColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The "Ne[chair]tShow" wordmark — the director's-chair mark inline in
/// place of the 'x', sized to the text and using the transparent-background
/// asset so it blends directly into the dark page instead of sitting in a
/// white tile.
class CinemaWordmark extends StatelessWidget {
  const CinemaWordmark({super.key, this.fontSize = 20});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: CinemaColors.textPrimary,
    );
    final iconSize = fontSize * 0.9;

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          const TextSpan(text: 'Ne'),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Image.asset(
              'packages/ui_kit/assets/logo_mark_transparent.png',
              width: iconSize,
              height: iconSize,
            ),
          ),
          const TextSpan(text: 'tShow'),
        ],
      ),
    );
  }
}

/// Shared shape for empty/loading/error messages on the cinema-dark
/// screens: icon, title, optional subtitle, optional action. The light-mode
/// `NSEmptyState`/`NSErrorState` hardcode dark-on-light colors and render
/// illegibly here.
class CinemaEmptyState extends StatelessWidget {
  const CinemaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: CinemaColors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: CinemaTextStyles.meta, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Dark-friendly ghost/secondary button — same API as `ui_kit`'s
/// `NSSecondaryButton`, but that one is styled for a light background
/// (transparent fill, light-gray border, dark text) and renders illegibly
/// on the cinema-dark screens.
class CinemaSecondaryButton extends StatelessWidget {
  const CinemaSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return NSPressScale(
      enabled: !isLoading && onPressed != null,
      child: SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: CinemaColors.glassFill,
            side: BorderSide(color: CinemaColors.glassBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: CinemaColors.textPrimary),
                )
              : Text(
                  label,
                  style: CinemaTextStyles.meta.copyWith(
                    color: CinemaColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
        ),
      ),
    );
  }
}

/// A circular frosted-glass icon button, for the spotlight card's bookmark
/// action.
class CinemaGlassIconButton extends StatelessWidget {
  const CinemaGlassIconButton({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NSPressScale(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CinemaColors.glassFill,
                shape: BoxShape.circle,
                border: Border.all(color: CinemaColors.glassBorder),
              ),
              child: Icon(icon, size: 18, color: CinemaColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
