import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/mocks/mock_listing_factory.dart';
import 'package:user_app/features/watchlist/application/watchlist_controller.dart';
import 'package:user_app/features/watchlist/presentation/watchlist_screen.dart';

/// In-memory watchlist so the test needs no Hive box.
class _FakeWatchlist extends WatchlistController {
  @override
  List<Listing> build() => [
        buildMockListing(
          showtimeId: 'st-1',
          eventTitle: 'Saved Show',
          eventDescription: '',
          venueName: 'Kino',
          venueAddress: 'Berlin',
          longitude: 13.4,
          latitude: 52.5,
          imageUrl: 'invalid://no-image',
        ),
      ];

  @override
  Future<void> remove(String showtimeId) async {
    state = state.where((l) => l.showtimeId != showtimeId).toList();
  }
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(402, 874);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [watchlistControllerProvider.overrideWith(_FakeWatchlist.new)],
    child: const MaterialApp(home: WatchlistScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('swiping up no longer removes a saved event', (tester) async {
    await _pump(tester);

    await tester.fling(find.text('Saved Show'), const Offset(0, -400), 2000);
    await tester.pumpAndSettle();

    expect(find.text('Saved Show'), findsOneWidget);
  });

  testWidgets('tapping the heart removes the saved event', (tester) async {
    await _pump(tester);

    await tester.tap(find.bySemanticsLabel('Remove from watchlist'));
    await tester.pumpAndSettle();

    expect(find.text('Saved Show'), findsNothing);
    expect(find.text('Your watchlist is empty'), findsOneWidget);
  });
}
