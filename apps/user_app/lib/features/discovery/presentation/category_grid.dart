import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import 'cinema_theme.dart';

typedef _CategoryTileSpec = ({EventCategory category, IconData icon, String label});

/// Colorful category tiles (movies/comedy/music/theatre), matching the
/// reference's Dining/Movies/Events tile row. Tapping the already-selected
/// tile clears the filter back to "All".
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final EventCategory? selectedCategory;
  final ValueChanged<EventCategory?> onSelected;

  static const _tiles = <_CategoryTileSpec>[
    (category: EventCategory.movie, icon: Icons.local_movies, label: 'Movies'),
    (category: EventCategory.comedy, icon: Icons.mic, label: 'Comedy'),
    (category: EventCategory.music, icon: Icons.music_note, label: 'Music'),
    (category: EventCategory.theatre, icon: Icons.theater_comedy, label: 'Theatre'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final tile in _tiles) ...[
          _CategoryTile(
            spec: tile,
            selected: selectedCategory == tile.category,
            onTap: () => onSelected(
              selectedCategory == tile.category ? null : tile.category,
            ),
          ),
          if (tile != _tiles.last) const SizedBox(width: 14),
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _CategoryTileSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = CinemaColors.forCategory(spec.category);

    return Expanded(
      child: NSPressScale(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? color : color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(spec.icon, color: selected ? Colors.white : color, size: 22),
                const SizedBox(height: 6),
                Text(
                  spec.label,
                  style: CinemaTextStyles.meta.copyWith(
                    color: selected ? Colors.white : CinemaColors.textMuted,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
