import 'package:core_models/core_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/mocks/mock_listing_factory.dart';
import 'package:user_app/features/watchlist/application/watchlist_controller.dart';

void main() {
  final now = DateTime(2026, 11, 20, 20);

  Listing listing({required DateTime start, DateTime? end}) => buildMockListing(
        eventTitle: 'SLAYANCE',
        eventDescription: '',
        venueName: 'Bar',
        venueAddress: 'Berlin',
        longitude: 13.4,
        latitude: 52.5,
        startTime: start,
      ).copyWith(endTime: end);

  test('a show that started 30 minutes ago is still on the watchlist', () {
    expect(
        WatchlistController.isOver(
            listing(start: now.subtract(const Duration(minutes: 30))), now),
        isFalse);
  });

  test('a show without an end time is over 2 hours after it starts', () {
    expect(
        WatchlistController.isOver(
            listing(start: now.subtract(const Duration(hours: 3))), now),
        isTrue);
  });

  test('a long show stays until its end time', () {
    expect(
        WatchlistController.isOver(
            listing(
                start: now.subtract(const Duration(hours: 4)),
                end: now.add(const Duration(hours: 1))),
            now),
        isFalse);
  });
}
