import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_decorations.dart';
import '../../../models/event_model.dart';
import '../../../widgets/tap_scale_container.dart';

class TrendingCard extends StatelessWidget {
  final Event event;
  final bool isCenter;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  const TrendingCard({
    super.key,
    required this.event,
    this.isCenter = true,
    required this.onTap,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    final monthStr = DateFormat('MMM').format(event.startDate);
    final dayStr = DateFormat('dd').format(event.startDate);
    final accentColor = event.category.accentColor;

    return TapScaleContainer(
      onTap: onTap,
      child: AnimatedScale(
        scale: isCenter ? 1.0 : 0.93,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: GlassDecorations.card(borderRadius: 28),
            child: Stack(
              children: [
                // Full-bleed Image with Hero animation
                Positioned.fill(
                  child: Hero(
                    tag: 'trending-event-img-${event.id}',
                    child: CachedNetworkImage(
                      imageUrl: event.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceCard,
                        child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.skyBlue),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceCard,
                        child: const Icon(Icons.broken_image,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),

                // Dark Gradient Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.cardGradientOverlay,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Top Bar Badges
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Row(
                    children: [
                      // Category Pill
                      GlassDecorations.glassContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        borderRadius: 100,
                        backgroundColor: accentColor.withOpacity(0.25),
                        borderColor: accentColor,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(event.category.icon,
                                size: 14, color: accentColor),
                            const SizedBox(width: 4),
                            Text(
                              event.category.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // FREE Badge
                      GlassDecorations.glassContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        borderRadius: 100,
                        backgroundColor: AppColors.neonGreen.withOpacity(0.25),
                        borderColor: AppColors.neonGreen,
                        child: const Text(
                          'FREE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.neonGreen,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Date Badge (Day + Month)
                      GlassDecorations.glassContainer(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        borderRadius: 14,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              monthStr.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              dayStr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Info Section
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  event.subtitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Heart/Save Button
                          TapScaleContainer(
                            onTap: onToggleSave,
                            scaleDown: 0.8,
                            child: GlassDecorations.glassContainer(
                              padding: const EdgeInsets.all(10),
                              borderRadius: 100,
                              backgroundColor: event.isSaved
                                  ? AppColors.error.withOpacity(0.25)
                                  : AppColors.glassSurface,
                              borderColor: event.isSaved
                                  ? AppColors.error
                                  : AppColors.glassBorder,
                              child: Icon(
                                event.isSaved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: event.isSaved
                                    ? AppColors.error
                                    : AppColors.textPrimary,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Location & City
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 14, color: AppColors.skyBlue),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${event.venueName} • ${event.city}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
