import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../models/event_model.dart';
import '../../../widgets/tap_scale_container.dart';

class HeroEventCard extends StatelessWidget {
  final Event event;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;

  const HeroEventCard({
    super.key,
    required this.event,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    // German date & time format: "12. Okt, 19:30"
    final dateStr =
        DateFormat('d. MMM, HH:mm', 'de_DE').format(event.startDate);

    return TapScaleContainer(
      onTap: onTap,
      child: Container(
        height: 290,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          boxShadow: AppTokens.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          child: Stack(
            children: [
              // Full-bleed Event Photo with Hero tag
              Positioned.fill(
                child: Hero(
                  tag: 'event-img-${event.id}',
                  child: CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    memCacheWidth: 600,
                    memCacheHeight: 600,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceSecondary,
                      child: const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.darkPrimary),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceSecondary,
                      child: const Icon(Icons.broken_image,
                          color: AppColors.textMuted, size: 32),
                    ),
                  ),
                ),
              ),

              // Bottom Dark Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.3, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              // Top Translucent "FREE" Chip (Top-Left)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1.0),
                  ),
                  child: const Text(
                    'FREE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              // Top Heart/Save Button (Top-Right)
              Positioned(
                top: 16,
                right: 16,
                child: TapScaleContainer(
                  onTap: onToggleSave,
                  scaleDown: 0.75,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSaved
                          ? AppColors.heartRed.withOpacity(0.2)
                          : Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSaved
                            ? AppColors.heartRed
                            : Colors.white.withOpacity(0.4),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      isSaved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isSaved ? AppColors.heartRed : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Bottom Event Info
              Positioned(
                bottom: 18,
                left: 18,
                right: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Venue & City
                        Expanded(
                          child: Text(
                            '${event.venueName} • ${event.city}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Date & Time (Right-Aligned)
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.95),
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
    );
  }
}
