import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/cinema_tokens.dart';
import '../theme/nsx_motion.dart';

/// Every image on the Discovery surface goes through here — the brief bans raw
/// stock photography. The treatment: desaturate toward a warm monochrome,
/// crush shadows into the ground color, lay a fine film grain over the top,
/// and (for large anchors) a faint horizontal linework pass. Applied at the
/// widget layer so it works identically on today's picsum placeholders and on
/// real posters later.
class ProcessedImage extends StatelessWidget {
  const ProcessedImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.lines = false,
    this.grainOpacity = 0.09,
  });

  final String url;
  final BoxFit fit;

  /// Horizontal linework overlay — on for the monumental spotlight, off for
  /// small thumbnails where it would moiré.
  final bool lines;
  final double grainOpacity;

  /// Full desaturate, hard contrast bump, and a warm bias in the output so the
  /// result reads as a printed plate, not a colour photo.
  static const double _c = 1.42; // contrast
  static const double _t =
      (-0.5 * _c + 0.5) * 255; // contrast pivot at mid-grey
  static const ColorFilter _plate = ColorFilter.matrix(<double>[
    0.34 * _c, 0.60 * _c, 0.06 * _c, 0, _t + 10, //
    0.32 * _c, 0.59 * _c, 0.06 * _c, 0, _t + 2, //
    0.27 * _c, 0.50 * _c, 0.05 * _c, 0, _t - 12, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: _plate,
            child: Image.network(
              url,
              fit: fit,
              gaplessPlayback: true,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const _PosterSkeleton(),
              errorBuilder: (context, _, __) => const _PosterFallback(),
            ),
          ),
          // Crush shadows into the ground, warm the whole frame, vignette the
          // edges — one graded material, never a raw photo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x330B0B0C), Color(0xC20B0B0C)],
              ),
            ),
          ),
          const ColoredBox(color: Color(0x1CFFA424)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.2,
                colors: [Color(0x000B0B0C), Color(0x590B0B0C)],
              ),
            ),
          ),
          if (lines)
            const Positioned.fill(
              child: CustomPaint(painter: _LineworkPainter()),
            ),
          Positioned.fill(
            child: CustomPaint(painter: _GrainPainter(grainOpacity)),
          ),
        ],
      ),
    );
  }
}

class _PosterSkeleton extends StatefulWidget {
  const _PosterSkeleton();

  @override
  State<_PosterSkeleton> createState() => _PosterSkeletonState();
}

class _PosterSkeletonState extends State<_PosterSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final x = _c.value * 2 - 1;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: const [
                NsxColors.surface,
                NsxColors.shimmer,
                NsxColors.surface,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NsxColors.surface,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: NsxColors.hairline),
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Text('NO IMAGE', style: NsxType.monoTiny),
      ),
    );
  }
}

/// Seeded film grain. Deterministic per size, repaints only when the box
/// resizes — a static overlay, not an animation.
class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.opacity);

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(1917);
    final count = (size.width * size.height / 70).round();
    final light = Paint()..color = NsxColors.bone.withOpacity(opacity);
    final dark = Paint()..color = NsxColors.ground.withOpacity(opacity * 1.5);
    for (var i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      canvas.drawRect(
        Rect.fromLTWH(dx, dy, 1.2, 1.2),
        rng.nextBool() ? light : dark,
      );
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.opacity != opacity;
}

/// Faint 1px horizontal rules — the "linework" pass for large imagery.
class _LineworkPainter extends CustomPainter {
  const _LineworkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NsxColors.ground.withOpacity(0.28)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_LineworkPainter old) => false;
}

/// Shared reduced-motion-aware fade-in for imagery arriving on screen.
class ImageReveal extends StatelessWidget {
  const ImageReveal({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (NsxMotion.reduced(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: NsxMotion.slow,
      curve: NsxMotion.expoOut,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: child,
    );
  }
}
