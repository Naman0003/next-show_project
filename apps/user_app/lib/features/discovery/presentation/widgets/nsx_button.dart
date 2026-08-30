import 'package:flutter/widgets.dart';

import '../theme/cinema_tokens.dart';
import 'spring_tap.dart';

/// The one filled action button for the dark world: a hard-edged amber stamp
/// with an accent-ink uppercase mono label. `SpringTap` press feedback,
/// loading + disabled states.
class NsxButton extends StatelessWidget {
  const NsxButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.ghost = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  /// Ghost = transparent fill, hairline border, bone label — the secondary
  /// action. Same hard 2px stamp shape as the filled variant.
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final Color fill;
    final Color border;
    final Color ink;
    if (ghost) {
      fill = NsxColors.glassFill;
      border = NsxColors.glassBorder;
      ink = enabled ? NsxColors.bone : NsxColors.muted;
    } else {
      fill = enabled ? NsxColors.accent : NsxColors.surfaceHi;
      border = enabled ? NsxColors.accent : NsxColors.hairline;
      ink = enabled ? NsxColors.accentInk : NsxColors.muted;
    }

    return SpringTap(
      onTap: onPressed,
      haptic: true,
      enabled: enabled,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: border),
        ),
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: _Spinner(color: ink),
              )
            : Text(
                label.toUpperCase(),
                style: NsxType.mono.copyWith(color: ink, fontSize: 12),
              ),
      ),
    );
  }
}

class _Spinner extends StatefulWidget {
  const _Spinner({required this.color});

  final Color color;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
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
      builder: (context, _) => Transform.rotate(
        angle: _c.value * 6.283,
        child: CustomPaint(painter: _ArcPainter(widget.color)),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Offset.zero & size,
      0,
      4.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}
