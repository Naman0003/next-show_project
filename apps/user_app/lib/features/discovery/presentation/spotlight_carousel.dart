import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../core/router/app_router.dart';
import '../../auth/presentation/login_screen.dart';
import '../../watchlist/application/watchlist_controller.dart';
import 'cinema_theme.dart';

/// "In the spotlight" — a horizontally-snapping peek-carousel of large
/// featured cards (not a full-screen banner): the next card visibly peeks
/// in on the right edge, matching the District reference.
///
/// Owns its [PageController] (rather than constructing one inline in
/// `build`) so a parent rebuild — e.g. toggling the category filter above —
/// doesn't hand PageView a brand-new controller and silently snap the
/// carousel back to page 0.
class SpotlightCarousel extends StatefulWidget {
  const SpotlightCarousel({super.key, required this.listings});

  final List<Listing> listings;

  @override
  State<SpotlightCarousel> createState() => _SpotlightCarouselState();
}

class _SpotlightCarouselState extends State<SpotlightCarousel> {
  final _controller = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.listings.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 14),
          child: _SpotlightCard(listing: widget.listings[index]),
        ),
      ),
    );
  }
}

class _SpotlightCard extends ConsumerWidget {
  const _SpotlightCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = listing.showtimeAttributes['imdb_rating'] as double?;
    final tagline = listing.showtimeAttributes['tagline'] as String?;
    final imageUrl = listing.imageUrl ??
        'https://picsum.photos/seed/${listing.eventId}/800/1200';
    final isSaved = ref
        .watch(watchlistControllerProvider)
        .any((l) => l.showtimeId == listing.showtimeId);

    return NSPressScale(
      child: GestureDetector(
        onTap: () => EventDetailRoute($extra: listing).push(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: CinemaColors.surfaceElevated,
                  child: const Icon(Icons.movie, color: CinemaColors.textMuted, size: 48),
                ),
              ),
              // Bottom-up scrim so the title/tagline stay legible over any
              // poster art — motivated, not decorative.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [
                      CinemaColors.background.withOpacity(0),
                      CinemaColors.background.withOpacity(0.92),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 14,
                top: 14,
                child: CinemaGlassBadge(
                  icon: Icons.local_fire_department,
                  iconColor: Color(0xFFFB923C),
                  label: 'Trending',
                ),
              ),
              Positioned(
                right: 14,
                top: 14,
                child: CinemaGlassIconButton(
                  icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                  onTap: () async {
                    final signedIn = await ensureSignedIn(context);
                    if (!signedIn || !context.mounted) return;
                    final notifier =
                        ref.read(watchlistControllerProvider.notifier);
                    if (isSaved) {
                      await notifier.remove(listing.showtimeId);
                    } else {
                      await notifier.add(listing);
                    }
                  },
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      listing.eventTitle,
                      style: CinemaTextStyles.spotlightTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tagline != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        tagline,
                        style: CinemaTextStyles.meta.copyWith(color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (rating != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: CinemaTextStyles.meta.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
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
