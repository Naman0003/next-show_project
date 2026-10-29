import 'package:core_models/core_models.dart' as core;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:user_app/features/home/presentation/home_screen.dart';
import 'package:user_app/features/newsfeed/application/feed_providers.dart';
import 'package:user_app/features/watchlist/application/watchlist_controller.dart';

class _EmptyWatchlist extends WatchlistController {
  @override
  List<core.Listing> build() => [];
}

core.Listing _listing(int i, String title, String label, {String? image}) => core.Listing(
      showtimeId: 'st-$i',
      startTime: DateTime.now().add(Duration(days: i)),
      price: 0,
      showtimeAttributes: const {},
      bookingUrl: 'https://example.org/$i',
      eventId: 'ev-$i',
      category: core.EventCategory.comedy,
      eventTitle: title,
      eventDescription: 'Live in Berlin.',
      imageUrl: image,
      eventMetadata: {'original_category': label, 'city': 'Berlin', 'is_free': true},
      venueId: 'v-$i',
      venueName: 'Göttin der Weisheit',
      venueType: core.VenueType.club,
      latitude: 52.49,
      longitude: 13.42,
    );

void main() {
  setUpAll(() => initializeDateFormatting('de_DE'));

  testWidgets('Discover renders real listings (no mock events), including ones without images',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        watchlistControllerProvider.overrideWith(_EmptyWatchlist.new),
        feedListingsProvider.overrideWith((ref) => Stream.value([
              _listing(1, "Beer 'n Mic: English stand-up", 'Comedy'),
              _listing(2, 'Halloween im Strassmanns', 'Parties'),
              _listing(3, "MOZART'S REQUIEM", 'Concerts'),
            ])),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.textContaining("Beer 'n Mic", findRichText: true), findsWidgets);
    expect(find.textContaining('Beyoncé', findRichText: true), findsNothing); // old mock data
    expect(tester.takeException(), isNull);
  });
}
