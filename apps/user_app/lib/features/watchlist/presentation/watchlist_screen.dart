import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
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
        title: Text('Watchlist', style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 20)),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: AppTokens.dockClearance(context)),
        child: FloatingActionButton.extended(
          // TODO(phase-3): remove once real save-to-watchlist flows exist.
          onPressed: () =>
              ref.read(watchlistControllerProvider.notifier).addMockEntry(),
          icon: const Icon(Icons.bug_report_outlined),
          label: const Text('Insert mock (debug)'),
        ),
      ),
      body: watchlist.isEmpty
          ? const CinemaEmptyState(
              icon: Icons.bookmark_border,
              title: 'Your watchlist is empty',
              subtitle: 'Save events to see them here — offline, powered by Hive.',
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 20, 20, AppTokens.dockClearance(context)),
              child: Wrap(
                spacing: 14,
                runSpacing: 20,
                children: [
                  for (final listing in watchlist)
                    Dismissible(
                      key: ValueKey(listing.showtimeId),
                      direction: DismissDirection.up,
                      onDismissed: (_) => ref
                          .read(watchlistControllerProvider.notifier)
                          .remove(listing.showtimeId),
                      child: MoviePosterCard(listing: listing),
                    ),
                ].animate(interval: 60.ms).fadeIn(duration: 350.ms).scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                    ),
              ),
            ),
    );
  }
}
