import 'package:core_models/core_models.dart';

import '../../../core/mocks/mock_listing_factory.dart';

/// Stands in for the Phase 3+ Supabase query that will return tonight's
/// real Berlin listings — a handful of mock [Listing]s spanning categories,
/// so the Discovery homepage's category grid and carousels have something
/// real to filter and scroll before real data lands. Poster art is seeded
/// picsum.photos placeholders, not real movie posters.
class MockDiscoveryDataSource {
  const MockDiscoveryDataSource();

  /// Top picks for the "In the spotlight" peek-carousel, highest-rated first.
  List<Listing> getSpotlight() {
    final all = _all()..sort((a, b) {
      final ratingA = a.showtimeAttributes['imdb_rating'] as double? ?? 0;
      final ratingB = b.showtimeAttributes['imdb_rating'] as double? ?? 0;
      return ratingB.compareTo(ratingA);
    });
    return all.take(3).toList();
  }

  /// The full "Now Showing" list.
  List<Listing> getNowShowing() => _all();

  List<Listing> _all() => [
        buildMockListing(
          showtimeId: 'demo-showtime-1',
          startTime: DateTime.now().add(const Duration(hours: 6)),
          price: 11.0,
          showtimeAttributes: const {
            'language': 'OV',
            'format': 'IMAX',
            'genre': 'Drama',
            'imdb_rating': 8.4,
            'tagline': 'The world forever changes.',
          },
          bookingUrl: 'https://www.imdb.com/title/tt15398776/',
          eventId: 'demo-event-1',
          category: EventCategory.movie,
          eventTitle: 'Oppenheimer',
          eventDescription:
              'A dramatization of the life story of J. Robert Oppenheimer, '
              'the physicist who had a large hand in the development of the atomic bombs.',
          durationMinutes: 180,
          venueId: 'demo-venue-1',
          venueName: 'Kino International',
          venueAddress: 'Karl-Marx-Allee 33, Berlin',
          longitude: 13.4235,
          latitude: 52.5155,
          imageUrl: 'https://picsum.photos/seed/oppenheimer-poster/800/1200',
        ),
        buildMockListing(
          showtimeId: 'demo-showtime-2',
          startTime: DateTime.now().add(const Duration(hours: 3)),
          price: 13.5,
          showtimeAttributes: const {
            'language': 'EN',
            'format': '2D',
            'genre': 'Sci-Fi',
            'imdb_rating': 7.9,
            'tagline': 'Some signals should never be answered.',
          },
          bookingUrl: 'https://example.com/book/departed-skies',
          eventId: 'demo-event-2',
          category: EventCategory.movie,
          eventTitle: 'The Departed Skies',
          eventDescription:
              'A deep-space listening station picks up a signal that shouldn\'t exist, '
              'and the crew has to decide whether to answer it.',
          durationMinutes: 124,
          venueId: 'demo-venue-2',
          venueName: 'Cineplex Alexanderplatz',
          venueAddress: 'Alexanderplatz 1, Berlin',
          longitude: 13.4132,
          latitude: 52.5219,
          imageUrl: 'https://picsum.photos/seed/departed-skies-poster/800/1200',
        ),
        buildMockListing(
          showtimeId: 'demo-showtime-3',
          startTime: DateTime.now().add(const Duration(hours: 5)),
          price: 9.0,
          showtimeAttributes: const {
            'language': 'EN',
            'format': 'Live',
            'genre': 'Stand-up',
            'imdb_rating': 8.1,
            'tagline': 'One mic, no filter.',
          },
          bookingUrl: 'https://example.com/book/late-night-circuit',
          eventId: 'demo-event-3',
          category: EventCategory.comedy,
          eventTitle: 'Late Night Circuit',
          eventDescription:
              'A rotating lineup of Berlin\'s sharpest stand-up comics, one mic, one night.',
          durationMinutes: 90,
          venueId: 'demo-venue-3',
          venueName: 'Quatsch Comedy Club',
          venueAddress: 'Friedrichstraße 107, Berlin',
          longitude: 13.3879,
          latitude: 52.5219,
          imageUrl: 'https://picsum.photos/seed/late-night-circuit-poster/800/1200',
        ),
        buildMockListing(
          showtimeId: 'demo-showtime-4',
          startTime: DateTime.now().add(const Duration(hours: 4)),
          price: 15.0,
          showtimeAttributes: const {
            'language': 'EN',
            'format': '2D',
            'genre': 'Action',
            'imdb_rating': 7.2,
            'tagline': 'The tide doesn\'t wait for anyone.',
          },
          bookingUrl: 'https://example.com/book/iron-tide',
          eventId: 'demo-event-4',
          category: EventCategory.movie,
          eventTitle: 'Iron Tide',
          eventDescription:
              'A salvage crew races a rival syndicate to a sunken cargo that could '
              'bankrupt half the port cities on the coast.',
          durationMinutes: 118,
          venueId: 'demo-venue-4',
          venueName: 'Il Kino',
          venueAddress: 'Kastanienallee 20, Berlin',
          longitude: 13.4075,
          latitude: 52.5372,
          imageUrl: 'https://picsum.photos/seed/iron-tide-poster/800/1200',
        ),
        buildMockListing(
          showtimeId: 'demo-showtime-5',
          startTime: DateTime.now().add(const Duration(hours: 7)),
          price: 24.0,
          showtimeAttributes: const {
            'format': 'Live',
            'genre': 'Electronic',
            'imdb_rating': 8.6,
            'tagline': 'Loud enough to forget the week.',
          },
          bookingUrl: 'https://example.com/book/nocturne-funkhaus',
          eventId: 'demo-event-5',
          category: EventCategory.music,
          eventTitle: 'Nocturne: Live at Funkhaus',
          eventDescription:
              'A late-set electronic showcase in Funkhaus\'s old broadcast hall, '
              'built for a room that loves bass.',
          durationMinutes: 150,
          venueId: 'demo-venue-5',
          venueName: 'Funkhaus Berlin',
          venueAddress: 'Nalepastraße 18, Berlin',
          longitude: 13.5027,
          latitude: 52.4589,
          imageUrl: 'https://picsum.photos/seed/nocturne-funkhaus-poster/800/1200',
        ),
        buildMockListing(
          showtimeId: 'demo-showtime-6',
          startTime: DateTime.now().add(const Duration(hours: 2)),
          price: 18.0,
          showtimeAttributes: const {
            'language': 'DE',
            'format': 'Live',
            'genre': 'Drama',
            'imdb_rating': 7.5,
            'tagline': 'A family, a memory, one room.',
          },
          bookingUrl: 'https://example.com/book/glass-menagerie-revisited',
          eventId: 'demo-event-6',
          category: EventCategory.theatre,
          eventTitle: 'The Glass Menagerie, Revisited',
          eventDescription:
              'A stripped-down staging of Williams\' memory play, set in a single '
              'room with a cast of three.',
          durationMinutes: 105,
          venueId: 'demo-venue-6',
          venueName: 'Volksbühne',
          venueAddress: 'Linienstraße 227, Berlin',
          longitude: 13.4022,
          latitude: 52.5288,
          imageUrl: 'https://picsum.photos/seed/glass-menagerie-poster/800/1200',
        ),
        buildMockListing(
          showtimeId: 'demo-showtime-7',
          startTime: DateTime.now().add(const Duration(hours: 8)),
          price: 12.0,
          showtimeAttributes: const {
            'language': 'OmU',
            'format': '2D',
            'genre': 'Indie',
            'imdb_rating': 8.0,
            'tagline': 'What\'s left after everyone leaves.',
          },
          bookingUrl: 'https://example.com/book/salt-and-ash',
          eventId: 'demo-event-7',
          category: EventCategory.movie,
          eventTitle: 'Salt & Ash',
          eventDescription:
              'A fisherman\'s daughter returns to her hometown after a decade away, '
              'and finds it smaller and stranger than she remembered.',
          durationMinutes: 96,
          venueId: 'demo-venue-7',
          venueName: 'Kino Debug Berlin',
          venueAddress: 'Karl-Marx-Allee 1, Berlin',
          longitude: 13.4050,
          latitude: 52.5200,
          imageUrl: 'https://picsum.photos/seed/salt-and-ash-poster/800/1200',
        ),
      ];
}
