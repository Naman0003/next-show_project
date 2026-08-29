import 'package:flutter/widgets.dart';

import '../theme/cinema_tokens.dart';

/// A hard-edged mono label — the neo-brutalist counterweight to the frosted
/// glass. Near-zero corner radius, a 1px border, no shadow. Used for category
/// tags on posters and the category filter chips.
class NeoTag extends StatelessWidget {
  const NeoTag({
    super.key,
    required this.label,
    this.filled = false,
    this.dense = false,
  });

  final String label;

  /// Filled = the accent (current / selected) state. Outline otherwise.
  final bool filled;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? NsxSpace.x2 : NsxSpace.x3,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: filled ? NsxColors.accent : NsxColors.ground.withOpacity(0.55),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: filled ? NsxColors.accent : NsxColors.glassBorder,
          width: 1,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: NsxType.mono.copyWith(
          color: filled ? NsxColors.accentInk : NsxColors.bone,
          fontSize: dense ? 10 : 11,
        ),
      ),
    );
  }
}
