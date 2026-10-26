import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/glass_decorations.dart';
import 'tap_scale_container.dart';

class FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const FloatingBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.favorite_rounded, Icons.favorite_border_rounded, 'Saved'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 40, right: 40),
      height: 64,
      child: GlassDecorations.glassContainer(
        borderRadius: 100,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: const Color(0x3D090D16),
        blur: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final activeIcon = items[index].$1;
            final inactiveIcon = items[index].$2;
            final isSelected = selectedIndex == index;

            return TapScaleContainer(
              onTap: () => onItemSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.royalBlue.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  border: isSelected
                      ? Border.all(color: AppColors.royalBlue, width: 1.2)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? activeIcon : inactiveIcon,
                      color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                      size: 24,
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Text(
                        items[index].$3,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
