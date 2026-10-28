import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/bootstrap.dart';
import '../../../core/di/core_providers.dart';
import 'theme/cinema_tokens.dart';

/// Boots the app: `main()` starts [ensureAppReady] (Supabase, Hive, date
/// formats) without awaiting it, so this screen is the first frame. It waits
/// for that to finish, plus a short minimum so the logo animation reads, then
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

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _minDisplayDuration = Duration(milliseconds: 700);

  Timer? _minDurationTimer;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _minDurationTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final minDuration = Completer<void>();
    _minDurationTimer = Timer(_minDisplayDuration, minDuration.complete);
    await Future.wait([ensureAppReady(), minDuration.future]);
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
        body: Center(
          child: const SplashWordmark()
              .animate()
              .fadeIn(duration: 500.ms, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1, 1),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),
        ),
      ),
    );
  }
}

/// "Ne[chair]tShow": the director's chair stands in for the x, per the brand
/// wordmark. Light-weight platform system font (SF Pro on iOS, Roboto on
/// Android), so it renders on the first frame with no font fetch.
class SplashWordmark extends StatelessWidget {
  const SplashWordmark({super.key, this.fontSize = 46});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
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
    // The chair fills roughly the middle 60% x 72% of its square PNG. Sized at
    // 1.2x the font and clipped near that region, it stands a little taller
    // than the capitals and spaces like a letter. A WidgetSpan's baseline is
    // its bottom edge; the nudge down lets the legs dip just past the
    // baseline, as in the wordmark.
    final chair = Transform.translate(
      offset: Offset(0, fontSize * 0.08),
      child: ClipRect(
        child: Align(
          widthFactor: 0.8,
          heightFactor: 0.8,
          child: Image.asset(
            'packages/ui_kit/assets/logo_mark_transparent.png',
            width: fontSize * 1.2,
            height: fontSize * 1.2,
          ),
        ),
      ),
    );

    return Semantics(
      label: 'Next Show',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            const TextSpan(text: 'Ne'),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: chair,
            ),
            const TextSpan(text: 'tShow'),
          ],
        ),
      ),
    );
  }
}
