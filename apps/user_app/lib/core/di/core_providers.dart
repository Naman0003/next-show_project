import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hive box names. Both boxes are opened by `ensureAppReady()` in
/// `core/bootstrap.dart`, and the router holds every screen but the splash
/// until that's done, so these providers can read them synchronously.
abstract class HiveBoxNames {
  static const watchlist = 'watchlist';
  static const listingCache = 'listing_cache';
}

/// Saved events the user has bookmarked. Entries are `Listing.toJson()` maps
/// keyed by `showtimeId`.
final watchlistBoxProvider = Provider<Box<Map>>((ref) {
  return Hive.box<Map>(HiveBoxNames.watchlist);
});

/// Recently viewed / prefetched listings for offline browsing. Entries are
/// `Listing.toJson()` maps keyed by `showtimeId`.
final listingCacheBoxProvider = Provider<Box<Map>>((ref) {
  return Hive.box<Map>(HiveBoxNames.listingCache);
});
