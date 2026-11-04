import 'dart:io';

import 'package:core_models/core_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:user_app/core/mocks/mock_listing_factory.dart';
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

  group('readListingsFromBox', () {
    late Directory dir;
    setUp(() async {
      dir = await Directory.systemTemp.createTemp('hive_json_test');
      Hive.init(dir.path);
    });
    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('skips and removes an entry that no longer parses, keeps the rest', () async {
      final box = await Hive.openBox<Map>('listings');
      final good = buildMockListing(
        showtimeId: 's1',
        eventTitle: 'Good one',
        eventDescription: '',
        venueName: 'Venue',
        venueAddress: 'Berlin',
        longitude: 13.4,
        latitude: 52.5,
      );
      await box.put('s1', good.toJson());
      // Shaped like an entry from an older app version: required fields missing.
      await box.put('old', {'showtimeId': 'old', 'category': 'opera'});

      final listings = readListingsFromBox(box);

      expect(listings.map((l) => l.eventTitle), ['Good one']);
      await Future<void>.delayed(Duration.zero);
      expect(box.containsKey('old'), isFalse);
      expect(box.containsKey('s1'), isTrue);
    });
  });
}
