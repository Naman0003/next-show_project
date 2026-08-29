import 'package:core_models/core_models.dart';
import 'package:flutter/widgets.dart';

import '../theme/cinema_tokens.dart';
import 'neo_tag.dart';
import 'spring_tap.dart';

/// The category filter, rebuilt as a single horizontal run of mono chips.
/// Replaces the four saturated color tiles — the brief bans evenly
/// distributed colorful palettes, so the accent marks only the active chip.
/// `null` = "ALL".
class CategoryStrip extends StatelessWidget {
  const CategoryStrip({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final EventCategory? selected;
  final ValueChanged<EventCategory?> onSelected;

  static const _order = <EventCategory?>[
    null,
    EventCategory.movie,
    EventCategory.comedy,
    EventCategory.music,
    EventCategory.theatre,
  ];

  static String _label(EventCategory? c) => switch (c) {
        null => 'All',
        EventCategory.movie => 'Movies',
        EventCategory.comedy => 'Comedy',
        EventCategory.music => 'Music',
        EventCategory.theatre => 'Theatre',
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: NsxSpace.gutter),
        itemCount: _order.length,
        separatorBuilder: (_, __) => const SizedBox(width: NsxSpace.x2),
        itemBuilder: (context, i) {
          final category = _order[i];
          return SpringTap(
            haptic: true,
            onTap: () => onSelected(category),
            child:
                NeoTag(label: _label(category), filled: category == selected),
          );
        },
      ),
    );
  }
}
