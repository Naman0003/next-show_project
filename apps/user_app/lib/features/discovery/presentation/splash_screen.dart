import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/bootstrap.dart';
import '../../../core/di/core_providers.dart';
import 'theme/cinema_tokens.dart';

/// Boots the app: `main()` starts [ensureAppReady] (Supabase, Hive, date
/// formats) without awaiting it, so this screen is the first frame. It plays
/// the wordmark intro — a folded director's chair springs open into the "x",
/// then "Ne" and "tShow" slide out from behind it — and waits for both that
/// and init to finish, then
/// does a warm read of both Hive boxes as the "initial data check" (a
/// slow/corrupt box surfaces here rather than as a stutter on the Watchlist
/// tab) and hands off to [from], or the main shell.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, this.from});

  /// Where the router was headed before it held the app on the splash.
  final String? from;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _introDuration = Duration(milliseconds: 2200);

  late final AnimationController _intro =
      AnimationController(vsync: this, duration: _introDuration);

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // Reduced motion: show the finished wordmark and skip the wait.
    final reduceMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
    final Future<void> intro;
    if (reduceMotion) {
      _intro.value = 1;
      intro = Future.value();
    } else {
      intro = _intro.forward().orCancel.catchError((_) {});
    }
    await Future.wait([ensureAppReady(), intro]);
    if (!mounted) return;

    final watchlistCount = ref.read(watchlistBoxProvider).length;
    final cacheCount = ref.read(listingCacheBoxProvider).length;
    debugPrint(
      '[splash] initial data check: $watchlistCount saved, $cacheCount cached listings',
    );

    context.go(widget.from ?? '/');
  }

  @override
  Widget build(BuildContext context) {
    // White to match the native launch screen, with dark status bar icons.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: SplashWordmark(progress: _intro)),
      ),
    );
  }
}

/// "Ne[chair]tShow": the director's chair stands in for the x, per the brand
/// wordmark. Light-weight platform system font (SF Pro on iOS, Roboto on
/// Android), so it renders on the first frame with no font fetch.
///
/// Driven by [progress] (0 -> 1) it plays the intro; without one it renders
/// the finished wordmark.
class SplashWordmark extends StatelessWidget {
  const SplashWordmark({super.key, this.fontSize = 46, this.progress});

  final double fontSize;
  final Animation<double>? progress;

  // Intro timeline, as fractions of the controller's run.
  static const _appear = Interval(0.0, 0.14, curve: Curves.easeOut);
  static const _unfold = Interval(0.12, 0.52, curve: Curves.easeOutBack);
  static const _fabric = Interval(0.38, 0.62, curve: Curves.easeOutCubic);
  static const _letters = Interval(0.52, 0.82, curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final anim = progress;
    if (anim == null) return _build(context, 1);
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) => _build(context, anim.value),
    );
  }

  Widget _build(BuildContext context, double t) {
    // Typography supplies the platform's system font family explicitly, so
    // the app theme's Google Font isn't inherited.
    final style = Typography.material2021(platform: Theme.of(context).platform)
        .black
        .displayLarge!
        .copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w300,
          color: NsxColors.bone,
          letterSpacing: -0.5,
          height: 1,
        );

    final appear = _appear.transform(t);
    final letters = _letters.transform(t);

    // The chair spans roughly the middle 80% of its 640-unit artboard; the
    // box is that region at 1.2x the font, so it stands a little taller than
    // the capitals and spaces like a letter. A WidgetSpan's baseline is its
    // bottom edge; the nudge down lets the legs dip just past the baseline.
    final chairSize = fontSize * 1.2 * 0.8;
    final chair = Transform.translate(
      offset: Offset(0, fontSize * 0.08 - (1 - appear) * fontSize * 0.4),
      child: Opacity(
        opacity: appear,
        child: CustomPaint(
          size: Size.square(chairSize),
          painter: _DirectorsChairPainter(
            open: _unfold.transform(t),
            fabric: _fabric.transform(t),
          ),
        ),
      ),
    );

    // The letters start tucked behind the chair and slide out to their spots.
    Widget word(String text, double tuckedOffset) => Opacity(
          opacity: letters,
          child: Transform.translate(
            offset: Offset((1 - letters) * tuckedOffset, 0),
            child: Text(text, style: style),
          ),
        );

    return Semantics(
      label: 'Next Show',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: word('Ne', fontSize * 0.9),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: chair,
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: word('tShow', -fontSize * 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

/// The logo's director's chair (`ui_kit/assets/logo_mark.png`) as vectors, so
/// it can fold. [open] 0 is folded flat — sides pressed together, legs nearly
/// parallel — and 1 is the logo, legs crossed in the X. [fabric] unrolls the
/// blue backrest from the top.
class _DirectorsChairPainter extends CustomPainter {
  _DirectorsChairPainter({required this.open, required this.fabric});

  final double open;
  final double fabric;

  static const _frame = Color(0xFF0B1433);
  static const _canvas = NsxColors.accent;

  @override
  void paint(Canvas canvas, Size size) {
    // Work in the logo's 640-unit artboard, cropped to its middle 80%.
    canvas.save();
    canvas.scale(size.width / 512);
    canvas.translate(-64, -64);

    // Folding squeezes everything toward the centre line. easeOutBack
    // overshoots past 1, so the chair briefly opens a touch too wide.
    final w = 0.14 + 0.86 * open;
    double x(double v) => 320 + (v - 320) * w;

    final stroke = Paint()
      ..color = _frame
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = _canvas;

    // Legs first so the seat sits over their tops.
    canvas.drawLine(Offset(x(205), 356), Offset(x(465), 540), stroke);
    canvas.drawLine(Offset(x(435), 356), Offset(x(175), 540), stroke);

    // Back posts and armrests.
    canvas.drawLine(Offset(x(197), 108), Offset(x(197), 330), stroke);
    canvas.drawLine(Offset(x(443), 108), Offset(x(443), 330), stroke);
    canvas.drawLine(Offset(x(143), 252), Offset(x(197), 252), stroke);
    canvas.drawLine(Offset(x(443), 252), Offset(x(497), 252), stroke);

    // Backrest canvas, unrolling downward.
    final f = fabric.clamp(0.0, 1.0);
    if (f > 0) {
      canvas.drawRect(
        Rect.fromLTRB(x(212), 135, x(428), 135 + 93 * f),
        fill,
      );
    }

    // Seat.
    canvas.drawRRect(
      RRect.fromLTRBR(x(138), 310, x(502), 356, const Radius.circular(23)),
      fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DirectorsChairPainter old) =>
      old.open != open || old.fabric != fabric;
}
