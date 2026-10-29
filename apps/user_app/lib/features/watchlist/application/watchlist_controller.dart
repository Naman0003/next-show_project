import 'package:core_models/core_models.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/storage/hive_json.dart';

part 'watchlist_controller.g.dart';

@riverpod
class WatchlistController extends _$WatchlistController {
  @override
  List<Listing> build() {
    final box = ref.watch(watchlistBoxProvider);
    // Drop entries left by the removed "Insert mock (debug)" button.
    final mockKeys =
        box.keys.where((k) => k.toString().startsWith('mock-showtime-'));
    if (mockKeys.isNotEmpty) box.deleteAll(mockKeys.toList());
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

  Future<void> remove(String showtimeId) async {
    final box = ref.read(watchlistBoxProvider);
    await box.delete(showtimeId);
    state = state.where((l) => l.showtimeId != showtimeId).toList();
  }

  bool contains(String showtimeId) {
    return state.any((l) => l.showtimeId == showtimeId);
  }
}
