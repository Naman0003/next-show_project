import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../core/router/app_router.dart';
import 'cinema_theme.dart';

/// A single "Now Showing" poster card — 2:3 poster, glass rating badge,
/// title and genre below.
class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({super.key, required this.listing, this.width = 140});

  final Listing listing;

  /// Card width; the poster keeps its 2:3 ratio within it.
  final double width;

  @override
  Widget build(BuildContext context) {
    final rating = listing.showtimeAttributes['imdb_rating'] as double?;
    final genre = listing.showtimeAttributes['genre'] as String?;
    final imageUrl = listing.imageUrl ??
        'https://picsum.photos/seed/${listing.eventId}/800/1200';

    return NSPressScale(
      child: GestureDetector(
        onTap: () => EventDetailRoute($extra: listing).push(context),
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: CinemaColors.surfaceElevated,
                          child: const Icon(Icons.movie,
                              color: CinemaColors.textMuted, size: 32),
                        ),
                      ),
                      if (rating != null)
                        Positioned(
                          left: 8,
                          top: 8,
                          child: CinemaGlassBadge(
                            icon: Icons.star,
                            iconColor: const Color(0xFFFBBF24),
                            label: rating.toStringAsFixed(1),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                listing.eventTitle,
                style: CinemaTextStyles.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (genre != null) ...[
                const SizedBox(height: 2),
                Text(
                  genre,
                  style: CinemaTextStyles.meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
