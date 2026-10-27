import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/models/event_model.dart';
import 'package:core_models/core_models.dart' as core;

void main() {
  group('Event.toListing conversion', () {
    test('converts Event model to valid core.Listing with correct fields', () {
      final now = DateTime.now();
      final event = Event(
        id: 'evt-test-1',
        title: 'Ariana Grande Live',
        description: 'An unforgettable night with Ariana in Berlin.',
        category: EventCategory.music,
        imageUrl: 'https://example.com/poster.jpg',
        startDate: now,
        venueName: 'Mercedes-Benz Arena',
        city: 'Berlin',
        isFree: false,
        organizer: 'Live Nation',
      );

      final listing = event.toListing();

      expect(listing.eventId, 'evt-test-1');
      expect(listing.eventTitle, 'Ariana Grande Live');
      expect(listing.venueName, 'Mercedes-Benz Arena');
      expect(listing.imageUrl, 'https://example.com/poster.jpg');
      expect(listing.category, core.EventCategory.music);
      expect(listing.venueType, core.VenueType.club);
      expect(listing.latitude, 52.5200);
      expect(listing.longitude, 13.4050);
      expect(listing.showtimeAttributes['tagline'], 'An unforgettable night with Ariana in Berlin.');
      expect(listing.eventMetadata['organizer'], 'Live Nation');
    });

    test('supports different cities and categorizations', () {
      final munichEvent = Event(
        id: 'evt-munich',
        title: 'Munich Film Gala',
        description: 'Screening of top indie films in Bavaria.',
        category: EventCategory.film,
        imageUrl: 'https://example.com/film.jpg',
        startDate: DateTime.now(),
        venueName: 'Kino Munich',
        city: 'Munich',
        isFree: true,
        organizer: 'Munich Indie Film Society',
      );

      final listing = munichEvent.toListing();
      expect(listing.category, core.EventCategory.movie);
      expect(listing.venueType, core.VenueType.cinema);
      expect(listing.latitude, 48.1351);
      expect(listing.longitude, 11.5820);
      expect(listing.showtimeAttributes['entry'], 'Free Admission');
    });
  });
}
