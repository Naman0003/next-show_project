import 'package:core_models/core_models.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/mocks/mock_listing_factory.dart';
import '../../../core/storage/hive_json.dart';

part 'watchlist_controller.g.dart';

@riverpod
class WatchlistController extends _$WatchlistController {
  @override
  List<Listing> build() {
    final box = ref.watch(watchlistBoxProvider);
    return _readAll(box);
  }

  List<Listing> _readAll(Box<Map> box) {
    final listings = readListingsFromBox(box);
    listings.sort((a, b) => a.startTime.compareTo(b.startTime));
    return listings;
  }

  Future<void> add(Listing listing) async {
    final box = ref.read(watchlistBoxProvider);
    await box.put(listing.showtimeId, listing.toJson());
    final withoutExisting =
        state.where((l) => l.showtimeId != listing.showtimeId).toList();
    state = [...withoutExisting, listing]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Debug-only helper (Phase 2) that proves the Hive cache persists across
  /// hot restarts without any network/Supabase dependency.
  Future<void> addMockEntry() => add(_buildMockListing());

  Future<void> remove(String showtimeId) async {
    final box = ref.read(watchlistBoxProvider);
    await box.delete(showtimeId);
    state = state.where((l) => l.showtimeId != showtimeId).toList();
  }

  bool contains(String showtimeId) {
    return state.any((l) => l.showtimeId == showtimeId);
  }

  Listing _buildMockListing() {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    return buildMockListing(
      showtimeId: 'mock-showtime-$id',
      eventId: 'mock-event-$id',
      venueId: 'mock-venue-$id',
      eventTitle: 'Mock Movie #$id',
      eventDescription: 'Inserted by the Phase 2 debug button.',
      venueName: 'Kino Debug Berlin',
      venueAddress: 'Karl-Marx-Allee 1, Berlin',
      longitude: 13.4050,
      latitude: 52.5200,
    );
  }
}
