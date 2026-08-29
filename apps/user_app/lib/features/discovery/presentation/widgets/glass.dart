import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/cinema_tokens.dart';
import 'spring_tap.dart';

/// The one frosted-glass primitive for the dark surfaces: a backdrop blur, a
/// faint bone fill, a crisp 1px inner border, and a soft top-edge inner glow.
/// Blur sigma is capped low and never animated — `BackdropFilter` is the
/// expensive effect on this screen, so it stays bounded to small elements
/// (pills, icon buttons, the nav dock), never a full-bleed layer.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = 999,
    this.blurSigma = 18,
    this.padding = EdgeInsets.zero,
    this.glow = true,
    this.shadow,
  });

  /// Fully rounded by default (pill). Pass a small value for a rect.
  final double borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry padding;

  /// The top-edge inner highlight. Turn off for tiny elements.
  final bool glow;
  final List<BoxShadow>? shadow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: shadow),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: NsxColors.glassFill,
              borderRadius: radius,
              border: Border.all(color: NsxColors.glassBorder, width: 1),
              gradient: glow
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.4],
                      colors: [Color(0x30EDE9E1), Color(0x00EDE9E1)],
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A circular frosted icon button — bookmark on the spotlight, bell in the
/// header.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.iconColor = NsxColors.bone,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color iconColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SpringTap(
      onTap: onTap,
      haptic: true,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: SizedBox(
          width: size,
          height: size,
          child: GlassSurface(
            glow: false,
            child: Center(
              child: Icon(icon, size: size * 0.46, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}
