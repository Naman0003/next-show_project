import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../core/bootstrap.dart';
import '../../../core/di/core_providers.dart';

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
          child: const NSLogo(fontSize: 34)
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
