import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../widgets/tap_scale_container.dart';
import '../../discovery/presentation/theme/cinema_tokens.dart';
import '../../home/application/home_providers.dart';
import '../application/feed_providers.dart';

/// Card copy derived from a [Listing]. Ingested events keep extras the
/// schema has no column for (source category, free flag) in `eventMetadata`.
extension on Listing {
  bool get isFree => eventMetadata['is_free'] == true || price == 0;

  /// The source's own label ("Workshop", "Stand-up") reads better than the
  /// four coarse app categories it was mapped onto.
  String get categoryLabel =>
      ((eventMetadata['original_category'] as String?) ?? category.name)
          .toUpperCase();

  String get blurb =>
      eventDescription ??
      (eventMetadata['breaking_headline'] as String?) ??
      venueName;
}

class EventBreakingCarouselScreen extends ConsumerStatefulWidget {
  const EventBreakingCarouselScreen({super.key});

  @override
  ConsumerState<EventBreakingCarouselScreen> createState() =>
      _EventBreakingCarouselScreenState();
}

class _EventBreakingCarouselScreenState
    extends ConsumerState<EventBreakingCarouselScreen> {
  late final PageController _pageController;
  int _activeCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.84, initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(feedForCityProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    return Scaffold(
      backgroundColor: AppColors.lightCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(begin: 0.3, end: 1.0, duration: 800.ms),
            const SizedBox(width: 8),
            // Shrinks rather than overflows next to the city pill on narrow phones.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Breaking Events',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    size: 14, color: AppColors.darkPrimary),
                const SizedBox(width: 4),
                Text(
                  selectedCity,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'LIVE CITY DIGEST',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Horizontal Carousel
            Expanded(
              child: eventsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return const Center(
                      child: Text(
                          'No events in this city right now — check back soon.',
                          style: TextStyle(color: AppColors.textMuted)),
                    );
                  }

                  return PageView.builder(
                    controller: _pageController,
                    itemCount: events.length,
                    onPageChanged: (idx) =>
                        setState(() => _activeCardIndex = idx),
                    itemBuilder: (context, index) {
                      final listing = events[index];
                      final isActive = index == _activeCardIndex;
                      final dateStr = DateFormat('d. MMM, HH:mm', 'de_DE')
                          .format(listing.startTime.toLocal());
                      final imageUrl =
                          listing.imageUrl ?? listing.showtimeImageUrl;

                      return TapScaleContainer(
                        onTap: () =>
                            EventDetailRoute($extra: listing).push(context),
                        child: AnimatedScale(
                          scale: isActive ? 1.0 : 0.93,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          child: AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.75,
                            duration: const Duration(milliseconds: 250),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: AppTokens.cardShadow,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Half: Hero Image
                                    Expanded(
                                      flex: 55,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: imageUrl == null
                                                ? Container(
                                                    color: AppColors
                                                        .surfaceSecondary,
                                                    child: const Icon(
                                                        Icons.event_rounded,
                                                        size: 48,
                                                        color: AppColors
                                                            .textMuted),
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    fit: BoxFit.cover,
                                                    memCacheWidth: 600,
                                                    memCacheHeight: 600,
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      color: AppColors
                                                          .surfaceSecondary,
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: AppColors
                                                                    .darkPrimary),
                                                      ),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      color: AppColors
                                                          .surfaceSecondary,
                                                      child: const Icon(
                                                          Icons.broken_image,
                                                          color: AppColors
                                                              .textMuted),
                                                    ),
                                                  ),
                                          ),

                                          // Translucent FREE Badge
                                          if (listing.isFree)
                                            Positioned(
                                              top: 16,
                                              left: 16,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.45),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppTokens.radiusPill),
                                                  border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.4)),
                                                ),
                                                child: const Text(
                                                  'FREE',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Bottom Half: Dark Glass Panel Description Card
                                    Expanded(
                                      flex: 45,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        color: AppColors.darkPrimary,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  listing.eventTitle,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                    height: 1.2,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  listing.blurb,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.75),
                                                    height: 1.35,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),

                                            // Bottom Row: Category + Time + Avatar
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Expanded so long venue names ellipsize
                                                // instead of pushing the row off-card.
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        listing.categoryLabel,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color:
                                                              AppColors.skyBlue,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        '$dateStr · ${listing.venueName}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.white
                                                              .withValues(
                                                                  alpha: 0.6),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),

                                                // Organizer Avatar / Icon
                                                CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: Colors.white
                                                      .withValues(alpha: 0.15),
                                                  child: const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.darkPrimary),
                ),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Couldn't load events.",
                          style: TextStyle(color: AppColors.error)),
                      TextButton(
                        onPressed: () => ref.invalidate(feedListingsProvider),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Keep the cards clear of the floating glass dock.
            SizedBox(height: AppTokens.dockClearance(context)),
          ],
        ),
      ),
    );
  }
}
