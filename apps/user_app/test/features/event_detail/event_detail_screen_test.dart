import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/mocks/mock_listing_factory.dart';
import 'package:user_app/features/event_detail/presentation/event_detail_screen.dart';
import 'package:user_app/features/watchlist/application/watchlist_controller.dart';

class MockWatchlistController extends WatchlistController {
  @override
  List<Listing> build() => [];
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  final testListing = buildMockListing(
    eventTitle: 'One Night with Ariana',
    eventDescription:
        'Ariana Grande brings her dazzling energy and iconic vocals to the stage in a spectacular live performance.',
    venueName: 'Accor Arena',
    venueAddress: 'Karl-Marx-Allee 33, Berlin',
    price: 1250.0,
    category: EventCategory.music,
    venueType: VenueType.club,
    startTime: DateTime(2026, 10, 12, 19, 0),
    durationMinutes: 150,
    showtimeAttributes: const {
      'genre': 'Pop',
      'imdb_rating': 9.2,
      'tagline': 'A spectacular live concert experience.',
    },
    longitude: 13.4235,
    latitude: 52.5155,
  );

  Widget createHostWidget(Listing listing) {
    return ProviderScope(
      overrides: [
        watchlistControllerProvider
            .overrideWith(() => MockWatchlistController()),
      ],
      child: MaterialApp(
        home: EventDetailScreen(listing: listing),
      ),
    );
  }

  testWidgets('orders title, date line, schedule, venue, then description',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createHostWidget(testListing));
    await tester.pumpAndSettle();

    double top(Finder f) => tester.getTopLeft(f).dy;
    final title = top(find.text('One Night with Ariana'));
    final date = top(find.text('Mon, 12 Oct, 7:00 PM'));
    final schedule = top(find.text('DOORS OPEN'));
    final venue = top(find.text('Accor Arena'));
    final description = top(find.textContaining('Ariana Grande brings').first);

    expect(title, lessThan(date));
    expect(date, lessThan(schedule));
    expect(schedule, lessThan(venue));
    expect(venue, lessThan(description));

    // The doors box shows only the time; the date lives in the line above.
    expect(find.text('7:00 PM'), findsOneWidget);
  });

  testWidgets('venue row opens the details sheet instead of a map',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createHostWidget(testListing));
    await tester.pumpAndSettle();

    expect(find.text('Venue details'), findsNothing);

    await tester.ensureVisible(find.text('Accor Arena'));
    await tester.tap(find.text('Accor Arena'));
    await tester.pumpAndSettle();

    expect(find.text('Venue details'), findsOneWidget);
    expect(find.text('Get directions'), findsOneWidget);
    expect(find.bySemanticsLabel('Copy address'), findsOneWidget);
    expect(find.bySemanticsLabel('Share venue'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Venue details'), findsNothing);
  });

  testWidgets('renders title, venue, price and live event details accurately',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createHostWidget(testListing));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('One Night with Ariana'), findsOneWidget);

    // Verify Venue Name
    expect(find.text('Accor Arena'), findsOneWidget);

    // Verify Tagline
    expect(find.text('A spectacular live concert experience.'), findsOneWidget);

    // Verify Category / Genre tags
    expect(find.text('MUSIC'), findsOneWidget);
    expect(find.text('Pop'), findsOneWidget);
    expect(find.text('9.2'), findsOneWidget);

    // Verify "From" label & Price
    expect(find.text('From'), findsOneWidget);
    expect(find.text('\$1,250'), findsOneWidget);

    // Verify "Buy a ticket" action pill
    expect(find.text('Buy a ticket'), findsOneWidget);
    expect(find.byIcon(Icons.confirmation_number_outlined), findsOneWidget);
  });

  testWidgets('toggles description expansion when Read More is tapped',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createHostWidget(testListing));
    await tester.pumpAndSettle();

    // Initially says "Read More"
    expect(find.text('Read More'), findsOneWidget);
    expect(find.text('Read Less'), findsNothing);

    // Tap "Read More"
    await tester.tap(find.text('Read More'));
    await tester.pumpAndSettle();

    // Now should say "Read Less"
    expect(find.text('Read Less'), findsOneWidget);
    expect(find.text('Read More'), findsNothing);

    // Tap "Read Less"
    await tester.tap(find.text('Read Less'));
    await tester.pumpAndSettle();

    // Back to "Read More"
    expect(find.text('Read More'), findsOneWidget);
  });

  testWidgets('circular back button pops current screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool didPop = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchlistControllerProvider
              .overrideWith(() => MockWatchlistController()),
        ],
        child: MaterialApp(
          home: Navigator(
            onPopPage: (route, result) {
              didPop = true;
              return route.didPop(result);
            },
            pages: [
              const MaterialPage(
                  child: Scaffold(body: Text('Previous Screen'))),
              MaterialPage(child: EventDetailScreen(listing: testListing)),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap circular back button
    final backFinder = find.byIcon(Icons.arrow_back_ios_new_rounded);
    expect(backFinder, findsOneWidget);
    await tester.tap(backFinder);
    await tester.pumpAndSettle();

    expect(didPop, isTrue);
  });
}

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _FakeHttpClient();
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeHttpClientRequest();

  @override
  void close({bool force = false}) {}
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();
}

class _FakeHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final _kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);
