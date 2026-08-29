import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/login_screen.dart';
import '../../../watchlist/application/watchlist_controller.dart';
import '../theme/cinema_tokens.dart';
import '../theme/nsx_motion.dart';
import 'glass.dart';
import 'neo_tag.dart';
import 'processed_image.dart';
import 'spring_tap.dart';

/// The monumental image anchor — one processed title filling most of the
/// viewport, everything else mono signage over it. Swipe through the top
/// picks. This is the surface's focal moment: on arrival (and on each swipe)
/// the poster scale-settles while the title wipes up and the metadata fades
/// in.
class MonumentalSpotlight extends ConsumerStatefulWidget {
  const MonumentalSpotlight({
    super.key,
    required this.listings,
    required this.height,
  });

  final List<Listing> listings;
  final double height;

  @override
  ConsumerState<MonumentalSpotlight> createState() =>
      _MonumentalSpotlightState();
}

class _MonumentalSpotlightState extends ConsumerState<MonumentalSpotlight>
    with SingleTickerProviderStateMixin {
  final _pager = PageController();
  int _index = 0;

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: NsxMotion.focal,
  );

  @override
  void initState() {
    super.initState();
    _entrance.value = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !NsxMotion.reduced(context)) _entrance.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _pager.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _onPage(int i) {
    setState(() => _index = i);
    if (!NsxMotion.reduced(context)) _entrance.forward(from: 0);
  }

  Future<void> _toggleSaved(Listing listing, bool isSaved) async {
    final signedIn = await ensureSignedIn(context);
    if (!signedIn || !mounted) return;
    final notifier = ref.read(watchlistControllerProvider.notifier);
    if (isSaved) {
      await notifier.remove(listing.showtimeId);
    } else {
      await notifier.add(listing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = widget.listings;
    if (listings.isEmpty) return const SizedBox.shrink();

    final current = listings[_index.clamp(0, listings.length - 1)];
    final saved = ref
        .watch(watchlistControllerProvider)
        .any((l) => l.showtimeId == current.showtimeId);

    return SizedBox(
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pager,
            itemCount: listings.length,
            onPageChanged: _onPage,
            itemBuilder: (context, i) => _Poster(
              url: listings[i].imageUrl ??
                  'https://picsum.photos/seed/${listings[i].eventId}/900/1400',
              entrance: _entrance,
              active: i == _index,
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.12, 0.4, 1],
                  colors: [
                    Color(0x730B0B0C),
                    Color(0x1A0B0B0C),
                    Color(0x000B0B0C),
                    Color(0xF20B0B0C),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: NsxSpace.gutter,
            top: NsxSpace.x3,
            child: GlassIconButton(
              icon: saved ? Icons.bookmark : Icons.bookmark_border,
              iconColor: saved ? NsxColors.accent : NsxColors.bone,
              semanticLabel:
                  saved ? 'Remove from watchlist' : 'Save to watchlist',
              onTap: () => _toggleSaved(current, saved),
            ),
          ),
          Positioned(
            left: NsxSpace.gutter,
            right: NsxSpace.gutter,
            bottom: NsxSpace.x5,
            child: _Caption(
              listing: current,
              entrance: _entrance,
              index: _index,
              count: listings.length,
            ),
          ),
          // Full-bleed tap target → detail, kept below the buttons above.
          Positioned.fill(
            child: SpringTap(
              pressedScale: 0.985,
              onTap: () => EventDetailRoute($extra: current).push(context),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

String _categoryLabel(EventCategory c) => switch (c) {
      EventCategory.movie => 'Movie',
      EventCategory.comedy => 'Comedy',
      EventCategory.music => 'Live Music',
      EventCategory.theatre => 'Theatre',
    };

class _Poster extends StatelessWidget {
  const _Poster({
    required this.url,
    required this.entrance,
    required this.active,
  });

  final String url;
  final Animation<double> entrance;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final image = ProcessedImage(url: url, lines: true);
    if (!active) return image;
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final t = NsxMotion.expoOut.transform(entrance.value);
        return Transform.scale(
          scale: 1.05 - 0.05 * t,
          child: child,
        );
      },
      child: image,
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption({
    required this.listing,
    required this.entrance,
    required this.index,
    required this.count,
  });

  final Listing listing;
  final Animation<double> entrance;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final attrs = listing.showtimeAttributes;
    final meta = <String>[
      if (listing.durationMinutes != null) '${listing.durationMinutes} MIN',
      if (attrs['language'] is String)
        (attrs['language'] as String).toUpperCase(),
      if (attrs['imdb_rating'] is double)
        'IMDB ${(attrs['imdb_rating'] as double).toStringAsFixed(1)}',
      if (listing.price != null) '€${listing.price!.toStringAsFixed(0)}',
    ].join('   ·   ');

    return AnimatedBuilder(
      animation: entrance,
      builder: (context, _) {
        final t = NsxMotion.expoOut.transform(entrance.value);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: (t * 1.4).clamp(0.0, 1.0),
              child: NeoTag(label: _categoryLabel(listing.category)),
            ),
            const SizedBox(height: NsxSpace.x3),
            // Title: an upward wipe (clip height factor) + lift.
            ClipRect(
              child: Align(
                alignment: Alignment.bottomLeft,
                heightFactor: 0.02 + 0.98 * t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 16),
                  child: Text(
                    listing.eventTitle,
                    style: NsxType.displayXl.copyWith(
                      fontSize: listing.eventTitle.length > 20 ? 34 : 42,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(height: NsxSpace.x3),
            Opacity(
              opacity: t,
              child: Text(meta, style: NsxType.mono, maxLines: 1),
            ),
            const SizedBox(height: NsxSpace.x3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < count; i++)
                  Container(
                    margin: const EdgeInsets.only(right: 5),
                    width: i == index ? 16 : 5,
                    height: 3,
                    decoration: BoxDecoration(
                      color:
                          i == index ? NsxColors.accent : NsxColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                const SizedBox(width: NsxSpace.x2),
                Text(
                  '${(index + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}',
                  style: NsxType.monoTiny,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
