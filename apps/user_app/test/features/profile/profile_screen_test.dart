import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:core_models/core_models.dart' hide EventCategory;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/mocks/mock_listing_factory.dart';
import 'package:user_app/features/home/application/home_providers.dart';
import 'package:user_app/features/profile/application/recently_viewed_provider.dart';
import 'package:user_app/features/profile/presentation/profile_screen.dart';
import 'package:user_app/features/watchlist/application/watchlist_controller.dart';
import 'package:user_app/theme/app_theme.dart';

class _PresetWatchlistController extends WatchlistController {
  final List<Listing> _initial;
  _PresetWatchlistController(this._initial);

  @override
  List<Listing> build() => _initial;
}

Widget createProfileScreenHost({
  List<Listing> watchlist = const [],
  List<Listing> recentlyViewed = const [],
  String selectedCity = 'All Cities',
}) {
  return ProviderScope(
    overrides: [
      watchlistControllerProvider.overrideWith(() => _PresetWatchlistController(watchlist)),
      recentlyViewedProvider.overrideWithValue(recentlyViewed),
      selectedCityProvider.overrideWith((ref) => selectedCity),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const ProfileScreen(),
    ),
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _FakeHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  testWidgets('renders profile screen title, guest header, and quick stats',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createProfileScreenHost());
    await tester.pumpAndSettle();

    // App Bar & Title
    expect(find.text('Profile'), findsOneWidget);

    // Guest Account Card
    expect(find.text('Join NextShow'), findsOneWidget);
    expect(find.text('Unlock tickets & sync saved gigs'), findsOneWidget);
    expect(find.text('Sign In or Register'), findsOneWidget);

    // Quick Stats Bar
    expect(find.text('Tickets'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('City'), findsOneWidget);
    expect(find.text('All Cities'), findsAtLeastNWidgets(1));
  });

  testWidgets('tapping Tickets stat opens the ticket info bottom sheet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createProfileScreenHost());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tickets'));
    await tester.pumpAndSettle();

    expect(find.text('My Tickets & Bookings'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.text('My Tickets & Bookings'), findsNothing);
  });

  testWidgets('tapping City chip opens city selection bottom sheet and updates city',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createProfileScreenHost(selectedCity: 'All Cities'));
    await tester.pumpAndSettle();

    // Tap City in Quick Stats Bar
    await tester.tap(find.text('City'));
    await tester.pumpAndSettle();

    expect(find.text('Select Your City'), findsOneWidget);
    expect(find.text('Berlin'), findsOneWidget);
    expect(find.text('Munich'), findsOneWidget);

    await tester.tap(find.text('Berlin'));
    await tester.pumpAndSettle();

    expect(find.text('Select Your City'), findsNothing);
    expect(find.text('Berlin'), findsAtLeastNWidgets(1));
  });

  testWidgets('city selection sheet does not overflow and scrolls smoothly on small phone screens',
      (WidgetTester tester) async {
    // Small phone viewport (e.g. 360x600 logical pixels)
    tester.view.physicalSize = const Size(360 * 2.0, 600 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createProfileScreenHost(selectedCity: 'Berlin'));
    await tester.pumpAndSettle();

    // Tap City in Quick Stats Bar
    await tester.tap(find.text('City'));
    await tester.pumpAndSettle();

    expect(find.text('Select Your City'), findsOneWidget);
    // Should render without any RenderFlex overflow exceptions
    expect(tester.takeException(), isNull);

    // Scroll to the bottom city in the list
    await tester.drag(find.widgetWithText(ListTile, 'Berlin'), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Leipzig'), findsOneWidget);
    await tester.tap(find.text('Leipzig'));
    await tester.pumpAndSettle();

    expect(find.text('Select Your City'), findsNothing);
    expect(find.text('Leipzig'), findsAtLeastNWidgets(1));
  });

  testWidgets('toggles category preferences chips',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createProfileScreenHost());
    await tester.pumpAndSettle();

    // Verify favorite genres heading
    expect(find.text('Favorite Genres'), findsOneWidget);
    expect(find.text('Concerts'), findsOneWidget);
    expect(find.text('Sports'), findsOneWidget);

    // Tap Sports to toggle it on
    await tester.tap(find.text('Sports'));
    await tester.pumpAndSettle();

    // Verify it is still present and tappable
    expect(find.text('Sports'), findsOneWidget);
  });

  testWidgets('renders notification toggles and supports switching',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createProfileScreenHost());
    await tester.pumpAndSettle();

    // Scroll down to notifications section
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Notification Alerts'), findsOneWidget);
    expect(find.text('Doors & Showtime Alerts'), findsOneWidget);
    expect(find.text('Free Ticket Drops'), findsOneWidget);
    expect(find.text('Weekend Gig Digest'), findsOneWidget);

    // Switches should be present
    final switches = find.byType(Switch);
    expect(switches, findsWidgets);

    // Tap a switch
    await tester.tap(switches.first);
    await tester.pumpAndSettle();
  });

  testWidgets('renders app preferences and support tiles with dialog interactions',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createProfileScreenHost());
    await tester.pumpAndSettle();

    // Scroll down to support & legal
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Support & Legal'), findsOneWidget);
    expect(find.text('Help & Concierge Support'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms of Service'), findsOneWidget);

    // Tap Help & Concierge Support
    await tester.tap(find.text('Help & Concierge Support'));
    await tester.pumpAndSettle();

    expect(find.text('NextShow Concierge'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Close'), findsNothing);
  });

  testWidgets('renders recently viewed horizontal carousel when items exist',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final listing = buildMockListing(
      eventTitle: 'Berghain Klubnacht',
      eventDescription: 'Legendary weekend club session in Berlin Friedrichshain.',
      venueName: 'Berghain',
      venueAddress: 'Am Wriezener Bahnhof, Berlin',
      longitude: 13.44,
      latitude: 52.51,
    );

    await tester.pumpWidget(createProfileScreenHost(recentlyViewed: [listing]));
    await tester.pumpAndSettle();

    // Scroll down to recently viewed section
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Recently Viewed'), findsOneWidget);
    expect(find.text('Berghain Klubnacht'), findsOneWidget);
    expect(find.textContaining('Berghain'), findsAtLeastNWidgets(1));
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// HTTP OVERRIDES FOR IMAGE LOADING IN WIDGET TESTS
// ─────────────────────────────────────────────────────────────────────────────

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _FakeHttpClientRequest();
  }
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _FakeHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse();
  }
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
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
]);
