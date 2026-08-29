import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';

import 'theme/cinema_tokens.dart';
import 'widgets/glass.dart';
import 'widgets/spring_tap.dart';

/// Compatibility surface for the dark screens that predate the "Marquee After
/// Dark" redesign (Search, Event Detail, Watchlist, Profile, auth). They keep
/// their layouts; these shims re-point the old `Cinema*` names at the new
/// [NsxColors] / [NsxType] tokens so the whole feature app shifts to the warm
/// near-black + amber world in one move. New Discovery code imports the tokens
/// directly.
class CinemaColors {
  CinemaColors._();

  static const Color background = NsxColors.ground;
  static const Color surfaceElevated = NsxColors.surface;
  static const Color glassFill = NsxColors.glassFill;
  static const Color glassBorder = NsxColors.glassBorder;
  static const Color textPrimary = NsxColors.bone;
  static const Color textMuted = NsxColors.muted;
  static const Color shimmerHighlight = NsxColors.shimmer;

  /// The palette is now a single accent — every category resolves to amber.
  /// Kept as a function so old call sites still compile.
  static Color forCategory(EventCategory category) => NsxColors.accent;
}

class CinemaTextStyles {
  CinemaTextStyles._();

  static TextStyle get spotlightTitle =>
      NsxType.displayXl.copyWith(fontSize: 28, letterSpacing: -0.8);
  static TextStyle get sectionHeader => NsxType.display.copyWith(fontSize: 20);
  static TextStyle get cardTitle => NsxType.title.copyWith(fontSize: 15);
  static TextStyle get meta => NsxType.textMuted.copyWith(fontSize: 12);
  static TextStyle get body => NsxType.text;
}

/// A frosted pill badge (icon + label).
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
    return GlassSurface(
      glow: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? NsxColors.bone),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: NsxType.mono.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// The "Ne‹chair›tShow" wordmark — the director's-chair mark inline for the
/// 'x'. Kept per the redesign brief; restyled to the display face.
class CinemaWordmark extends StatelessWidget {
  const CinemaWordmark({super.key, this.fontSize = 20});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = NsxType.display.copyWith(
      fontSize: fontSize,
      letterSpacing: -1.4,
      height: 1,
    );
    final iconSize = fontSize * 0.72;

    // The mark PNG carries transparent side padding; clamp its layout footprint
    // (OverflowBox lets the glyph render full-size past the narrower box) so
    // "Ne·chair·tShow" reads as one word, not three.
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Ne', style: style),
        SizedBox(
          width: iconSize * 0.60,
          height: iconSize,
          child: OverflowBox(
            maxWidth: iconSize,
            maxHeight: iconSize,
            child: Padding(
              padding: EdgeInsets.only(bottom: fontSize * 0.06),
              child: ColorFiltered(
                colorFilter:
                    const ColorFilter.mode(NsxColors.accent, BlendMode.srcATop),
                child: Image.asset(
                  'packages/ui_kit/assets/logo_mark_transparent.png',
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
          ),
        ),
        Text('tShow', style: style),
      ],
    );
  }
}

/// Shared empty/loading/error message shape for the dark screens.
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
            Icon(icon, size: 52, color: NsxColors.muted),
            const SizedBox(height: 16),
            Text(
              title,
              style: NsxType.title.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: CinemaTextStyles.meta, textAlign: TextAlign.center),
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

/// Dark ghost/secondary button — API-compatible with the old one.
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
    return SpringTap(
      enabled: !isLoading && onPressed != null,
      onTap: onPressed,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: NsxColors.glassFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NsxColors.glassBorder),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: NsxColors.bone),
              )
            : Text(
                label,
                style: NsxType.mono.copyWith(fontSize: 12),
              ),
      ),
    );
  }
}

/// A circular frosted icon button (old name kept; delegates to the new one).
class CinemaGlassIconButton extends StatelessWidget {
  const CinemaGlassIconButton({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      GlassIconButton(icon: icon, onTap: onTap, size: 36);
}
