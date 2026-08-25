import 'package:core_models/core_models.dart';

/// Builds a placeholder [Listing] for scaffolding UI ahead of real data.
/// [eventTitle], [eventDescription], [venueName], [venueAddress],
/// [longitude], and [latitude] are always the interesting part of a mock —
/// every call site sets these. Everything else defaults to a plausible
/// Berlin cinema showtime, with id fields derived from a shared generated
/// id unless overridden.
Listing buildMockListing({
  required String eventTitle,
  required String eventDescription,
  required String venueName,
  required String venueAddress,
  required double longitude,
  required double latitude,
  String? showtimeId,
  DateTime? startTime,
  double price = 12.5,
  Map<String, dynamic> showtimeAttributes = const {'language': 'OV', 'format': '2D'},
  String? bookingUrl,
  String? eventId,
  EventCategory category = EventCategory.movie,
  int? durationMinutes,
  Map<String, dynamic> eventMetadata = const {},
  String? venueId,
  VenueType venueType = VenueType.cinema,
  String? imageUrl,
}) {
  final id = DateTime.now().microsecondsSinceEpoch.toString();
  return Listing(
    showtimeId: showtimeId ?? 'mock-showtime-$id',
    startTime: startTime ?? DateTime.now().add(const Duration(days: 1, hours: 3)),
    price: price,
    showtimeAttributes: showtimeAttributes,
    bookingUrl: bookingUrl ?? 'https://example.com/book/$id',
    eventId: eventId ?? 'mock-event-$id',
    category: category,
    eventTitle: eventTitle,
    eventDescription: eventDescription,
    durationMinutes: durationMinutes,
    eventMetadata: eventMetadata,
    venueId: venueId ?? 'mock-venue-$id',
    venueName: venueName,
    venueType: venueType,
    venueAddress: venueAddress,
    longitude: longitude,
    latitude: latitude,
    imageUrl: imageUrl,
  );
}
