import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// A Siri-style animated waveform. Purely decorative/reactive — the caller
/// is responsible for only mounting this while `speech_to_text` is actually
/// listening, and for feeding [amplitude] from its live sound level.
class SiriWaveformWidget extends StatefulWidget {
  const SiriWaveformWidget({super.key, this.amplitude = 0.3, this.height = 56});

  /// 0..1 live sound level. Higher values make the bars taller/faster.
  final double amplitude;
  final double height;

  @override
  State<SiriWaveformWidget> createState() => _SiriWaveformWidgetState();
}

class _SiriWaveformWidgetState extends State<SiriWaveformWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _SiriWaveformPainter(
            phase: _controller.value,
            amplitude: widget.amplitude,
          ),
        ),
      ),
    );
  }
}

class _SiriWaveformPainter extends CustomPainter {
  _SiriWaveformPainter({required this.phase, required this.amplitude});

  final double phase; // 0..1, loops
  final double amplitude; // 0..1

  static const _barCount = 32;

  // t, centerBoost, and each bar's color are all purely index-dependent
  // (not phase/amplitude-dependent), so they're computed once here instead
  // of every paint() call — this was ~1,920 Color.lerp calls/sec at 60fps
  // while listening.
  static final List<double> _t =
      List.generate(_barCount, (i) => i / (_barCount - 1));
  static final List<double> _centerBoost =
      _t.map((t) => 1 - (2 * (t - 0.5)).abs()).toList();
  static final List<Color> _barColors = _t
      .map((t) => Color.lerp(NSColors.royalBlue, NSColors.skyBlue, t)!)
      .toList();
  static final Paint _paint = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / _barCount;
    final mid = size.height / 2;
    final level = 0.15 + amplitude.clamp(0.0, 1.0) * 0.85;

    for (var i = 0; i < _barCount; i++) {
      final t = _t[i];

      // Two overlapping sine waves at different frequencies/phases so the
      // bars don't move in obvious lockstep.
      final wave = math.sin((t * 4 * math.pi) + phase * 2 * math.pi) * 0.6 +
          math.sin((t * 6 * math.pi) - phase * 2 * math.pi * 1.7) * 0.4;
      final barHeight =
          (wave.abs() * 0.7 + 0.3) * _centerBoost[i] * level * size.height;

      final x = barWidth * i + barWidth / 2;
      _paint.color = _barColors[i];
      canvas.drawLine(
        Offset(x, mid - barHeight / 2),
        Offset(x, mid + barHeight / 2),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SiriWaveformPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.amplitude != amplitude;
}
