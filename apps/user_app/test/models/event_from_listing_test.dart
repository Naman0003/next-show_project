import 'package:core_models/core_models.dart' as core;
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/models/event_model.dart';

core.Listing _listing({String? label, Map<String, dynamic> extra = const {}, double? price}) => core.Listing(
      showtimeId: 'st-1',
      startTime: DateTime.utc(2026, 11, 5, 9),
      price: price,
      showtimeAttributes: const {},
      bookingUrl: 'https://allevents.in/berlin/graduation/1',
      eventId: 'ev-1',
      category: core.EventCategory.theatre,
      eventTitle: 'Graduation WiSe 2026',
      eventMetadata: {if (label != null) 'original_category': label, ...extra},
      venueId: 'v-1',
      venueName: 'SRH Hochschule (Berlin) New Campus',
      venueType: core.VenueType.theatre,
      latitude: 52.474571,
      longitude: 13.457464,
    );

void main() {
  test('toListing returns the original listing, keeping real booking URL and coordinates', () {
    final listing = _listing(label: 'Education');
    final event = Event.fromListing(listing);

    expect(identical(event.toListing(), listing), isTrue);
    expect(event.toListing().bookingUrl, 'https://allevents.in/berlin/graduation/1');
    expect(event.toListing().latitude, 52.474571);
  });

  test('maps the source labels seen in live AllEvents data onto Home categories', () {
    const expected = {
      'Comedy': EventCategory.nightlife,
      'Parties': EventCategory.nightlife,
      'Meetups': EventCategory.community,
      'Workshops': EventCategory.community,
      'Conferences': EventCategory.community,
      'Education': EventCategory.community,
      'Performances': EventCategory.exhibitions,
      'Exhibitions': EventCategory.exhibitions,
      'Concerts': EventCategory.concerts,
      'Film Screening': EventCategory.film,
      'Startup Pitch Night': EventCategory.community, // "art" must not fire inside "Startup"
    };
    expected.forEach((label, category) {
      expect(Event.fromListing(_listing(label: label)).category, category, reason: label);
    });
  });

  test('falls back to the core category when there is no source label', () {
    expect(Event.fromListing(_listing()).category, EventCategory.exhibitions);
  });

  test('reads city, free flag and organizer from metadata with sensible defaults', () {
    final ingested = Event.fromListing(_listing(extra: {'city': 'Munich', 'is_free': true, 'organizer': 'SRH'}));
    expect((ingested.city, ingested.isFree, ingested.organizer), ('Munich', true, 'SRH'));

    final bare = Event.fromListing(_listing(price: 12));
    expect((bare.city, bare.isFree, bare.organizer, bare.imageUrl), ('Berlin', false, 'SRH Hochschule (Berlin) New Campus', ''));
  });
}
