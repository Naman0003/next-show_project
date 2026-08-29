import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/nsx_motion.dart';

/// A tap target that punches down on press and springs back with a small
/// overshoot on release — the base feedback gesture for the Discovery
/// surface. Replaces `ui_kit`'s `NSPressScale` here (that one eases linearly
/// and has no haptic).
///
/// Uses [GestureDetector] rather than a raw [Listener] so it yields the
/// pointer to an ancestor scrollable through the gesture arena instead of
/// firing mid-drag.
class SpringTap extends StatefulWidget {
  const SpringTap({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.94,
    this.haptic = false,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// How far the child shrinks while held.
  final double pressedScale;

  /// Fire [HapticFeedback.selectionClick] on a completed tap.
  final bool haptic;

  final bool enabled;

  @override
  State<SpringTap> createState() => _SpringTapState();
}

class _SpringTapState extends State<SpringTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale = AnimationController.unbounded(
    vsync: this,
    value: 1,
  );

  bool get _active => widget.enabled && widget.onTap != null;

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  void _down(BuildContext context) {
    if (!_active) return;
    if (NsxMotion.reduced(context)) {
      _scale.animateTo(0.98,
          duration: NsxMotion.fast, curve: NsxMotion.expoOut);
    } else {
      _scale.animateTo(widget.pressedScale,
          duration: const Duration(milliseconds: 90), curve: NsxMotion.expoOut);
    }
  }

  void _release(BuildContext context) {
    if (!_active) return;
    if (NsxMotion.reduced(context)) {
      _scale.animateTo(1, duration: NsxMotion.fast, curve: NsxMotion.expoOut);
    } else {
      _scale.animateWith(
        SpringSimulation(NsxMotion.press, _scale.value, 1, 0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _down(context),
      onTapUp: (_) => _release(context),
      onTapCancel: () => _release(context),
      onTap: _active
          ? () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
