import 'package:core_models/core_models.dart';
import 'package:hive/hive.dart';

/// Recursively converts a value read back out of a Hive box into plain
/// `Map<String, dynamic>`/`List<dynamic>` JSON, so it can be handed to a
/// freezed model's `fromJson`.
///
/// Hive round-trips nested maps as untyped `LinkedMap<dynamic, dynamic>`
/// (most visibly on web/IndexedDB) rather than `Map<String, dynamic>`.
/// `Map<String, dynamic>.from(raw)` only casts the *top* level — any nested
/// map (e.g. `Listing.showtimeAttributes`) is left as `LinkedMap<dynamic,
/// dynamic>`, which isn't a `Map<String, dynamic>`, so `fromJson`'s cast on
/// it throws a [TypeError]. This walks the whole structure instead.
Map<String, dynamic> deepMapFromHive(Object? raw) {
  return (_deepConvert(raw) as Map<String, dynamic>?) ?? const {};
}

Object? _deepConvert(Object? value) {
  if (value is Map) {
    return value.map((key, v) => MapEntry(key as String, _deepConvert(v)));
  }
  if (value is List) {
    return value.map(_deepConvert).toList();
  }
  return value;
}

/// Reads and parses every entry in a Hive box of `Listing.toJson()` maps.
/// Shared by every box that stores `Listing`s so they don't each hand-roll
/// the same map/parse.
List<Listing> readListingsFromBox(Box<Map> box) {
  return box.values.map((raw) => Listing.fromJson(deepMapFromHive(raw))).toList();
}
