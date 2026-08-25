import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../core/di/core_providers.dart';

/// Boots the app: `main()` already opened the Hive boxes before `runApp`
/// (moving that into this widget would mean re-touching platform channels
/// mid-tree, which isn't worth it for what's already a fast, synchronous
/// step by the time this screen mounts) — what this screen actually
/// *awaits* is a warm read of both boxes as the "initial data check", so a
/// slow/corrupt box would surface here rather than as a stutter on the
/// Watchlist tab. Then it hands off to the main shell.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _minDisplayDuration = Duration(milliseconds: 1600);

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
    final watchlistCount = ref.read(watchlistBoxProvider).length;
    final cacheCount = ref.read(listingCacheBoxProvider).length;
    debugPrint(
      '[splash] initial data check: $watchlistCount saved, $cacheCount cached listings',
    );

    final completer = Completer<void>();
    _minDurationTimer = Timer(_minDisplayDuration, completer.complete);
    await completer.future;

    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NSColors.deepNavy,
      body: Center(
        child: const NSLogo(fontSize: 34)
            .animate()
            .fadeIn(duration: 500.ms, curve: Curves.easeOut)
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
            .then(delay: 150.ms)
            .shimmer(duration: 900.ms, color: Colors.white.withOpacity(0.55)),
      ),
    );
  }
}
