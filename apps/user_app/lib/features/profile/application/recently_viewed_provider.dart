import 'package:core_models/core_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/storage/hive_json.dart';

/// Reads the `listing_cache` Hive box as-is. Nothing writes to this box yet
/// (that lands with real browsing in a later phase) — for Phase 2 this only
/// proves the box opens and the UI can read from it.
final recentlyViewedProvider = Provider<List<Listing>>((ref) {
  return readListingsFromBox(ref.watch(listingCacheBoxProvider));
});
