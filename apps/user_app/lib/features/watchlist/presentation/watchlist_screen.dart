import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../widgets/tap_scale_container.dart';
import '../../discovery/presentation/cinema_theme.dart';
import '../../discovery/presentation/movie_poster_card.dart';
import '../application/watchlist_controller.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistControllerProvider);

    return Scaffold(
      backgroundColor: CinemaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: CinemaColors.textPrimary),
        title: Text('Watchlist',
            style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 20)),
      ),
      body: watchlist.isEmpty
          ? const CinemaEmptyState(
              icon: Icons.bookmark_border,
              title: 'Your watchlist is empty',
              subtitle:
                  'Save events to see them here — offline, powered by Hive.',
            )
          : LayoutBuilder(
              builder: (context, box) {
                const hPad = 20.0, gap = 14.0, columns = 2;
                // Size cards so the columns fill the row edge to edge.
                final cardWidth =
                    (box.maxWidth - hPad * 2 - gap * (columns - 1)) / columns;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                      hPad, 20, hPad, AppTokens.dockClearance(context)),
                  child: Wrap(
                    spacing: gap,
                    runSpacing: 20,
                    children: [
                      for (final listing in watchlist)
                        // Removing is an explicit heart tap — a swipe was too easy to trigger.
                        Stack(
                          key: ValueKey(listing.showtimeId),
                          children: [
                            MoviePosterCard(listing: listing, width: cardWidth),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: _UnsaveHeart(
                                onTap: () => ref
                                    .read(watchlistControllerProvider.notifier)
                                    .remove(listing.showtimeId),
                              ),
                            ),
                          ],
                        ),
                    ].animate(interval: 60.ms).fadeIn(duration: 350.ms).scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                        ),
                  ),
                );
              },
            ),
    );
  }
}

/// Filled heart on a saved card; tapping it removes the event from the
/// watchlist. Matches the saved state of the Discover cards' heart.
class _UnsaveHeart extends StatelessWidget {
  const _UnsaveHeart({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Remove from watchlist',
      child: TapScaleContainer(
        onTap: onTap,
        scaleDown: 0.75,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.heartRed),
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: AppColors.heartRed,
            size: 18,
          ),
        ),
      ),
    );
  }
}
