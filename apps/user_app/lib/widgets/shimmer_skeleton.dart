import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/glass_decorations.dart';

class ShimmerSkeletonLoader extends StatelessWidget {
  const ShimmerSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0x1F1E293B),
      highlightColor: const Color(0x3DFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending Carousel Skeleton
          Container(
            height: 280,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: GlassDecorations.card(borderRadius: 24),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Upcoming List Skeletons
          ...List.generate(3, (index) {
            return Container(
              height: 110,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: GlassDecorations.card(borderRadius: 20),
            );
          }),
        ],
      ),
    );
  }
}
