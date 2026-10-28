import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:user_app/features/newsfeed/application/feed_providers.dart';
import 'package:user_app/features/newsfeed/presentation/event_breaking_carousel.dart';
import 'package:user_app/widgets/shimmer_skeleton.dart';

Listing _listing(int i, {required String venue, String? originalCategory}) => Listing(
      showtimeId: 'st-$i',
      startTime: DateTime.utc(2026, 11, 5, 9),
      price: 0,
      showtimeAttributes: const {},
      bookingUrl: 'https://example.org/$i',
      eventId: 'ev-$i',
      category: EventCategory.theatre,
      eventTitle: 'Berlin Science Week: Design a tool for anonymous data donation $i',
      eventDescription: 'A long description that should wrap and be clipped to three lines on the card.',
      eventMetadata: {
        'is_free': true,
        'city': 'Berlin',
        if (originalCategory != null) 'original_category': originalCategory,
      },
      venueId: 'v-$i',
      venueName: venue,
      venueType: VenueType.theatre,
      longitude: 13.37,
      latitude: 52.5,
    );

void main() {
  setUpAll(() => initializeDateFormatting('de_DE'));

  testWidgets('feed cards with very long venue/category names do not overflow on a small phone',
      (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        feedListingsProvider.overrideWith((ref) => Stream.value([
              _listing(1,
                  venue: 'American Church in Berlin - Lutherkirche am Dennewitzplatz, Schöneberg',
                  originalCategory: 'Workshop / Citizen Science / Data Donation / Hackathon'),
              _listing(2, venue: 'Curly Bar'),
            ])),
      ],
      child: const MaterialApp(home: EventBreakingCarouselScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('American Church in Berlin'), findsOneWidget);
    expect(find.text('WORKSHOP / CITIZEN SCIENCE / DATA DONATION / HACKATHON'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading skeleton fits the 306x662 slot it gets on Home', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Center(
        child: SizedBox(width: 306, height: 662, child: ShimmerSkeletonLoader()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
