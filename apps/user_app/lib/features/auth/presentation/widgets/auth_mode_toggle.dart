import 'package:flutter/widgets.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../discovery/presentation/theme/cinema_tokens.dart';

/// Which account flow the auth sheet's email phase is showing.
enum AuthMode { signIn, signUp }

/// The dark-world skin of [NSSegmentedToggle] for the auth sheet: an amber
/// active thumb, hard 2px corners, and uppercase Martian Mono labels — matching
/// [NsxButton]. Mirrors how `SpringTap` / `cinema_theme.dart` re-dress shared
/// primitives for "Marquee After Dark".
class AuthModeToggle extends StatelessWidget {
  const AuthModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return NSSegmentedToggle(
      segments: const ['SIGN IN', 'SIGN UP'],
      selectedIndex: mode.index,
      onChanged: (i) => onChanged(AuthMode.values[i]),
      trackColor: NsxColors.glassFill,
      borderColor: NsxColors.glassBorder,
      thumbColor: NsxColors.accent,
      borderRadius: 2,
      selectedLabelStyle:
          NsxType.mono.copyWith(color: NsxColors.accentInk, fontSize: 12),
      unselectedLabelStyle:
          NsxType.mono.copyWith(color: NsxColors.muted, fontSize: 12),
    );
  }
}
