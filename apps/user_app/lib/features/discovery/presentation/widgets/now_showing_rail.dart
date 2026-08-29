import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import '../theme/cinema_tokens.dart';
import 'processed_image.dart';
import 'spring_tap.dart';

/// "Now Showing" — a horizontal run of processed poster cards under a signage
/// header. Replaces the old inline `PageView` + `MoviePosterCard`.
class NowShowingRail extends StatelessWidget {
  const NowShowingRail({super.key, required this.listings});

  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NsxSpace.gutter),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('Now Showing', style: NsxType.display),
              const SizedBox(width: NsxSpace.x3),
              Text(
                listings.length.toString().padLeft(2, '0'),
                style: NsxType.monoTiny.copyWith(color: NsxColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: NsxSpace.x4),
        if (listings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NsxSpace.gutter),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(NsxSpace.x4),
              decoration: BoxDecoration(
                border: Border.all(color: NsxColors.hairline),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text('NOTHING IN THIS CATEGORY TONIGHT',
                  style: NsxType.mono.copyWith(color: NsxColors.muted)),
            ),
          )
        else
          SizedBox(
            height: 300,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: NsxSpace.gutter),
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(width: NsxSpace.x3),
              itemBuilder: (context, i) => _PosterCard(listing: listings[i]),
            ),
          ),
      ],
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final genre = listing.showtimeAttributes['genre'] as String?;
    final rating = listing.showtimeAttributes['imdb_rating'] as double?;
    final url = listing.imageUrl ??
        'https://picsum.photos/seed/${listing.eventId}/600/900';

    return SpringTap(
      onTap: () => EventDetailRoute($extra: listing).push(context),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: NsxColors.hairline),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: ProcessedImage(url: url),
                ),
              ),
            ),
            const SizedBox(height: NsxSpace.x2),
            Text(
              listing.eventTitle,
              style: NsxType.title.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: NsxSpace.x1),
            Text(
              [
                if (genre != null) genre.toUpperCase(),
                if (rating != null) 'IMDB ${rating.toStringAsFixed(1)}',
              ].join('   ·   '),
              style: NsxType.monoTiny,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              listing.venueName,
              style: NsxType.textMuted.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
