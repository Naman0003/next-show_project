// lib/widgets/voice_search_overlay.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/voice_input_service.dart';
import '../theme/app_theme.dart';

class VoiceSearchResult {
  final String? transcript;
  final bool permissionDenied;

  const VoiceSearchResult.transcript(this.transcript) : permissionDenied = false;
  const VoiceSearchResult.cancelled()
      : transcript = null,
        permissionDenied = false;
  const VoiceSearchResult.permissionDenied()
      : transcript = null,
        permissionDenied = true;
}

/// Pushes the full-screen voice overlay and resolves once it's done —
/// either with a transcript to submit, a cancellation, or a
/// permission-denied signal for the caller to surface.
Future<VoiceSearchResult> showVoiceSearchOverlay(BuildContext context) async {
  final result = await Navigator.of(context).push<VoiceSearchResult>(
    PageRouteBuilder(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => const VoiceSearchOverlay(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
  return result ?? const VoiceSearchResult.cancelled();
}

class VoiceSearchOverlay extends StatefulWidget {
  const VoiceSearchOverlay({Key? key}) : super(key: key);

  @override
  State<VoiceSearchOverlay> createState() => _VoiceSearchOverlayState();
}

class _VoiceSearchOverlayState extends State<VoiceSearchOverlay> with SingleTickerProviderStateMixin {
  // speech_to_text's web implementation hardcodes SpeechRecognitionResult's
  // isFinal to false (see speech_to_text_web.dart _onResult) — the browser's
  // real event.results[i].isFinal never reaches Dart. So `finalResult`
  // triggering auto-submit only ever fires there via a slow ~2s fallback
  // timer inside the package, stacked after our own pauseFor — up to ~4s
  // total. This local timer is the actual, reliable silence-based trigger:
  // it resets on every transcript update regardless of the (unreliable)
  // isFinal flag, and fires the submit itself after real silence.
  static const _silenceTimeout = Duration(milliseconds: 1800);

  late final AnimationController _pulseController;
  Timer? _silenceTimer;
  String _transcript = "";
  double _soundLevel = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _startListening();
  }

  Future<void> _startListening() async {
    await VoiceInputService.listen(
      onResult: (transcript, isFinal) {
        if (!mounted) return;
        setState(() => _transcript = transcript);
        _resetSilenceTimer();
      },
      onSoundLevelChange: (level) {
        if (!mounted) return;
        // Roughly normalizes the raw dB-ish level speech_to_text reports
        // into a 0..1 range for the pulse — an approximation, not real
        // frequency analysis, which is fine for an ambient reactive pulse.
        setState(() => _soundLevel = ((level + 2) / 12).clamp(0.0, 1.0));
      },
      // Still wired: on platforms where isFinal genuinely works (unlike
      // web), this can resolve faster than our own timer. Whichever path
      // fires first wins — both funnel through the same _done guard.
      onDone: (reason) {
        if (!mounted || _done) return;
        switch (reason) {
          case VoiceStopReason.silence:
            _finish(_transcript);
            break;
          case VoiceStopReason.permissionDenied:
            _done = true;
            _silenceTimer?.cancel();
            Navigator.of(context).pop(const VoiceSearchResult.permissionDenied());
            break;
          case VoiceStopReason.error:
            _done = true;
            _silenceTimer?.cancel();
            Navigator.of(context).pop(const VoiceSearchResult.cancelled());
            break;
        }
      },
    );
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(_silenceTimeout, () => _finish(_transcript));
  }

  void _finish(String transcript) {
    if (!mounted || _done) return;
    _done = true;
    _silenceTimer?.cancel();

    final result = transcript.trim();
    debugPrint('[voice] silence detected — submitting transcript: "$result"');

    if (result.isEmpty) {
      VoiceInputService.cancel();
      Navigator.of(context).pop(const VoiceSearchResult.cancelled());
    } else {
      VoiceInputService.stop();
      Navigator.of(context).pop(VoiceSearchResult.transcript(result));
    }
  }

  void _cancel() {
    _done = true;
    _silenceTimer?.cancel();
    VoiceInputService.cancel();
    Navigator.of(context).pop(const VoiceSearchResult.cancelled());
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _done = true;
        _silenceTimer?.cancel();
        VoiceInputService.cancel();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.deepNavy,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: _cancel,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                "Listening...",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                "What are you in the mood for?",
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 180,
                height: 180,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _PulsePainter(
                        progress: _pulseController.value,
                        soundLevel: _soundLevel,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _transcript.isEmpty ? " " : _transcript,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  final double progress; // 0..1, loops
  final double soundLevel; // 0..1

  _PulsePainter({required this.progress, required this.soundLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseRadius = size.shortestSide / 5;
    final reactiveBoost = soundLevel * size.shortestSide / 6;

    const ringColors = [AppColors.royalBlue, AppColors.skyBlue, AppColors.royalBlue];

    for (var i = 0; i < 3; i++) {
      final ringProgress = (progress + i / 3) % 1.0;
      final radius = baseRadius + ringProgress * (size.shortestSide / 2 - baseRadius) + reactiveBoost;
      final opacity = (1.0 - ringProgress) * 0.35;

      final paint = Paint()
        ..color = ringColors[i].withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(center, radius, paint);
    }

    final corePaint = Paint()..color = AppColors.royalBlue.withOpacity(0.9);
    canvas.drawCircle(center, baseRadius * 0.55 + reactiveBoost * 0.4, corePaint);
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.soundLevel != soundLevel;
  }
}

