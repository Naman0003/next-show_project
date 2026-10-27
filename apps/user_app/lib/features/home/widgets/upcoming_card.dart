import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_decorations.dart';
import '../../../models/event_model.dart';
import '../../../widgets/tap_scale_container.dart';

class UpcomingCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  const UpcomingCard({
    super.key,
    required this.event,
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
      child: Container(
        height: 125,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: GlassDecorations.card(borderRadius: 22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Background Image with Gradient Overlay
              Positioned.fill(
                child: Hero(
                  tag: 'upcoming-event-img-${event.id}',
                  child: CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: AppColors.surfaceCard),
                    errorWidget: (context, url, error) => Container(color: AppColors.surfaceCard),
                  ),
                ),
              ),

              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xD9090D16),
                        const Color(0xF2090D16),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // Content Padding
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Left Date Box
                    GlassDecorations.glassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      borderRadius: 16,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            monthStr.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dayStr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Middle Event Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              // Category Tag
                              GlassDecorations.glassContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                borderRadius: 8,
                                backgroundColor: accentColor.withOpacity(0.2),
                                borderColor: accentColor.withOpacity(0.6),
                                child: Text(
                                  event.category.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // FREE Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.neonGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.neonGreen, width: 0.8),
                                ),
                                child: const Text(
                                  'FREE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.neonGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 12, color: AppColors.skyBlue),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${event.venueName} • ${event.city}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
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

                    // Save Heart Icon Button
                    TapScaleContainer(
                      onTap: onToggleSave,
                      scaleDown: 0.8,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          event.isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: event.isSaved ? AppColors.error : AppColors.textMuted,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
