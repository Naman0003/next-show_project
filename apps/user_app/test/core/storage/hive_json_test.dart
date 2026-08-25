import 'package:core_models/core_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/core/storage/hive_json.dart';

void main() {
  group('deepMapFromHive', () {
    test('deep-casts nested untyped maps, not just the top level', () {
      // Mirrors what Hive actually hands back for a stored Listing: the top
      // map and its nested `showtimeAttributes`/`eventMetadata` maps come
      // back as untyped LinkedHashMap<dynamic, dynamic>, not
      // Map<String, dynamic> — reproduces the bug this helper fixes.
      final Map<dynamic, dynamic> rawFromHive = {
        'showtimeId': 's1',
        'startTime': DateTime(2026, 1, 1).toIso8601String(),
        'showtimeAttributes': <dynamic, dynamic>{'language': 'OV'},
        'bookingUrl': 'https://example.com',
        'eventId': 'e1',
        'category': 'movie',
        'eventTitle': 'Test Movie',
        'eventMetadata': <dynamic, dynamic>{'runtimeMinutes': 120},
        'venueId': 'v1',
        'venueName': 'Test Cinema',
        'venueType': 'cinema',
        'longitude': 13.4,
        'latitude': 52.5,
      };

      final converted = deepMapFromHive(rawFromHive);

      // Must not throw the TypeError this helper exists to prevent.
      final listing = Listing.fromJson(converted);

      expect(listing.eventTitle, 'Test Movie');
      expect(listing.showtimeAttributes, {'language': 'OV'});
      expect(listing.eventMetadata, {'runtimeMinutes': 120});
    });
  });
}
