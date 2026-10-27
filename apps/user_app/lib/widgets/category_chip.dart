import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';
import '../models/event_model.dart';
import 'tap_scale_container.dart';

class CategoryChip extends StatelessWidget {
  final EventCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleContainer(
      onTap: onTap,
      scaleDown: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkPrimary : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(
            color: isSelected ? AppColors.darkPrimary : AppColors.borderLight,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0x1F000000) : Colors.transparent,
              blurRadius: isSelected ? 10 : 0,
              offset: isSelected ? const Offset(0, 4) : Offset.zero,
            ),
          ],
        ),
        child: Text(
          category.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
