import 'package:flutter/widgets.dart';

/// Motion constants for the Discovery surface. The signature feel is
/// physics-based: taps settle on a spring with a small overshoot rather than
/// easing linearly to rest.
class NsxMotion {
  NsxMotion._();

  /// Confident deceleration for entrances and layout moves (expo-out).
  static const Curve expoOut = Cubic(0.16, 1, 0.3, 1);

  /// Press feedback: snappy, lightly underdamped so it overshoots on release.
  static const SpringDescription press =
      SpringDescription(mass: 1, stiffness: 420, damping: 22);

  /// Larger elements coming to rest (selection pill, spotlight swap).
  static const SpringDescription settle =
      SpringDescription(mass: 1, stiffness: 240, damping: 26);

  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration focal = Duration(milliseconds: 700);

  /// True when the platform asks for reduced motion (OS "Remove animations",
  /// or the accessibility navigation mode). Callers should drop spatial
  /// movement and overshoot, keeping fades and state changes.
  static bool reduced(BuildContext context) {
    final mq = MediaQuery.maybeOf(context);
    return mq?.disableAnimations ?? false;
  }
}
