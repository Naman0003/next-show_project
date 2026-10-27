import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';

class ShimmerSkeletonLoader extends StatelessWidget {
  const ShimmerSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF3F4F6),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            height: 280,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            ),
          );
        }),
      ),
    );
  }
}
