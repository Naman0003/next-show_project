// lib/services/organizer_repository.dart
import 'package:supabase_client/supabase_client.dart';
import 'package:core_models/core_models.dart';

class PartnerStats {
  final int venueCount;
  final int eventCount;
  final int upcomingShowtimesCount;
  final int clickCountThisWeek;

  const PartnerStats({
    required this.venueCount,
    required this.eventCount,
    required this.upcomingShowtimesCount,
    required this.clickCountThisWeek,
  });
}

class OrganizerRepository {
  /// Fetch aggregate stats for the signed-in partner
  static Future<PartnerStats> fetchPartnerStats() async {
    final userId = NextShowSupabaseClient.currentUser?.id;
    if (userId == null) {
      return const PartnerStats(
        venueCount: 0,
        eventCount: 0,
        upcomingShowtimesCount: 0,
        clickCountThisWeek: 0,
      );
    }

    // 1. Owned venues count
    final venues = await NextShowSupabaseClient.fetchVenues(ownerId: userId);
    final venueCount = venues.length;

    // 2. Total events
    final events = await NextShowSupabaseClient.fetchEvents();
    final eventCount = events.length;

    // 3. Upcoming showtimes across partner's venues
    int upcomingShowtimesCount = 0;
    int clickCountThisWeek = 0;

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    for (final venue in venues) {
      final showtimes = await NextShowSupabaseClient.fetchShowtimesByVenue(
        venue.id,
        from: now,
      );
      upcomingShowtimesCount += showtimes.length;

      final clicks = await NextShowSupabaseClient.fetchClicksForVenue(
        venue.id,
        from: sevenDaysAgo,
      );
      clickCountThisWeek += clicks.length;
    }

    return PartnerStats(
      venueCount: venueCount,
      eventCount: eventCount,
      upcomingShowtimesCount: upcomingShowtimesCount,
      clickCountThisWeek: clickCountThisWeek,
    );
  }

  /// Venues owned by current partner
  static Future<List<Venue>> fetchMyVenues() async {
    final userId = NextShowSupabaseClient.currentUser?.id;
    if (userId == null) return [];
    return NextShowSupabaseClient.fetchVenues(ownerId: userId);
  }

  /// Single venue details
  static Future<Venue?> fetchVenue(String id) {
    return NextShowSupabaseClient.fetchVenue(id);
  }

  /// Create venue
  static Future<Venue> createVenue({
    required String name,
    required VenueType venueType,
    String? address,
    double? latitude,
    double? longitude,
    String? websiteUrl,
    String? imageUrl,
    String? partnerNotes,
  }) {
    return NextShowSupabaseClient.createVenue(
      name: name,
      venueType: venueType,
      address: address,
      latitude: latitude,
      longitude: longitude,
      websiteUrl: websiteUrl,
      imageUrl: imageUrl,
      partnerNotes: partnerNotes,
    );
  }

  /// Update venue
  static Future<Venue> updateVenue({
    required String id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? websiteUrl,
    String? imageUrl,
    String? partnerNotes,
    bool? isActive,
  }) {
    return NextShowSupabaseClient.updateVenue(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      websiteUrl: websiteUrl,
      imageUrl: imageUrl,
      partnerNotes: partnerNotes,
      isActive: isActive,
    );
  }

  /// Events list
  static Future<List<Event>> fetchEvents({
    EventCategory? category,
    EventStatus? status,
    String? searchQuery,
  }) {
    return NextShowSupabaseClient.fetchEvents(
      category: category,
      status: status,
      searchQuery: searchQuery,
    );
  }

  /// Fetch single event
  static Future<Event?> fetchEvent(String id) {
    return NextShowSupabaseClient.fetchEvent(id);
  }

  /// Create event
  static Future<Event> createEvent({
    required EventCategory category,
    required String title,
    String? description,
    String? imageUrl,
    int? durationMinutes,
    Map<String, dynamic>? externalIds,
    Map<String, dynamic>? metadata,
    EventStatus? status,
  }) {
    return NextShowSupabaseClient.createEvent(
      category: category,
      title: title,
      description: description,
      imageUrl: imageUrl,
      durationMinutes: durationMinutes,
      externalIds: externalIds,
      metadata: metadata,
      status: status,
    );
  }

  /// Update event
  static Future<Event> updateEvent({
    required String id,
    String? title,
    String? description,
    String? imageUrl,
    int? durationMinutes,
    Map<String, dynamic>? externalIds,
    Map<String, dynamic>? metadata,
    EventStatus? status,
  }) {
    return NextShowSupabaseClient.updateEvent(
      id: id,
      title: title,
      description: description,
      imageUrl: imageUrl,
      durationMinutes: durationMinutes,
      externalIds: externalIds,
      metadata: metadata,
      status: status,
    );
  }

  /// Fetch showtimes for a venue
  static Future<List<Showtime>> fetchShowtimesByVenue(
    String venueId, {
    DateTime? from,
    DateTime? to,
    EventStatus? status,
  }) {
    return NextShowSupabaseClient.fetchShowtimesByVenue(
      venueId,
      from: from,
      to: to,
      status: status,
    );
  }

  /// Fetch showtimes for an event
  static Future<List<Showtime>> fetchShowtimesByEvent(
    String eventId, {
    EventStatus? status,
  }) {
    return NextShowSupabaseClient.fetchShowtimesByEvent(
      eventId,
      status: status,
    );
  }

  /// Create showtime
  static Future<Showtime> createShowtime({
    required String venueId,
    required String eventId,
    required DateTime startTime,
    DateTime? endTime,
    double? price,
    int? capacity,
    Map<String, dynamic>? attributes,
    required String bookingUrl,
    String? imageUrl,
    EventStatus? status,
  }) {
    return NextShowSupabaseClient.createShowtime(
      venueId: venueId,
      eventId: eventId,
      startTime: startTime,
      endTime: endTime,
      price: price,
      capacity: capacity,
      attributes: attributes,
      bookingUrl: bookingUrl,
      imageUrl: imageUrl,
      status: status,
    );
  }

  /// Update showtime
  static Future<Showtime> updateShowtime({
    required String id,
    DateTime? startTime,
    DateTime? endTime,
    double? price,
    int? capacity,
    Map<String, dynamic>? attributes,
    String? bookingUrl,
    String? imageUrl,
    EventStatus? status,
  }) {
    return NextShowSupabaseClient.updateShowtime(
      id: id,
      startTime: startTime,
      endTime: endTime,
      price: price,
      capacity: capacity,
      attributes: attributes,
      bookingUrl: bookingUrl,
      imageUrl: imageUrl,
      status: status,
    );
  }

  /// Invites
  static Future<OrganizerInvite> createInvite({
    required String venueId,
    required String email,
    String role = 'editor',
  }) {
    return NextShowSupabaseClient.createInvite(
      venueId: venueId,
      email: email,
      role: role,
    );
  }

  static Future<List<OrganizerInvite>> fetchInvitesForVenue(String venueId) {
    return NextShowSupabaseClient.fetchInvitesForVenue(venueId);
  }
}
