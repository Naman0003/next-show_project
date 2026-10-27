import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';
import 'tap_scale_container.dart';

class FloatingDarkNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const FloatingDarkNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      (Icons.home_rounded, Icons.home_outlined),
      (Icons.calendar_today_rounded, Icons.calendar_today_outlined),
      (Icons.favorite_rounded, Icons.favorite_border_rounded),
      (Icons.person_rounded, Icons.person_outline_rounded),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 24, left: 32, right: 32),
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bottomNavDark,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        boxShadow: AppTokens.navShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isSelected = selectedIndex == index;
          final activeIcon = icons[index].$1;
          final inactiveIcon = icons[index].$2;

          return TapScaleContainer(
            onTap: () => onItemSelected(index),
            scaleDown: 0.85,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.bottomNavActiveCircle : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppColors.bottomNavDark : Colors.white.withOpacity(0.6),
                size: 22,
              ),
            ),
          );
        }),
      ),
    );
  }
}
