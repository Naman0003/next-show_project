library supabase_client;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:core_models/core_models.dart';

/// Initializes Supabase and provides typed query helpers
class NextShowSupabaseClient {
  static SupabaseClient? _client;

  /// Initialize Supabase (call from main.dart before runApp)
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
  }

  /// Get the initialized client
  static SupabaseClient get client {
    if (_client == null) {
      throw StateError('Supabase not initialized. Call NextShowSupabaseClient.initialize() first.');
    }
    return _client!;
  }

  /// Auth helpers
  static User? get currentUser => client.auth.currentUser;
  static bool get isSignedIn => currentUser != null;
  static Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange;

  static Future<void> signInWithOtp({required String email}) {
    return client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  static Future<void> verifyOtp({required String email, required String code}) {
    return client.auth.verifyOTP(email: email, token: code, type: OtpType.email);
  }

  static Future<void> signInWithGoogle({String? redirectTo}) {
    return client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectTo,
    );
  }

  static Future<void> signOut() {
    return client.auth.signOut();
  }

  // ============================================================
  // VENUES
  // ============================================================

  /// Fetch all active venues
  static Future<List<Venue>> fetchVenues({
    VenueType? type,
    bool? isActive,
    String? ownerId,
  }) async {
    var query = client.from('venues').select();

    if (type != null) {
      query = query.eq('venue_type', type.name);
    }
    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }
    if (ownerId != null) {
      query = query.eq('owner_id', ownerId);
    }

    final response = await query.order('name', ascending: true);
    return (response as List).map((json) => _venueFromJson(json)).toList();
  }

  /// Fetch a single venue by ID
  static Future<Venue?> fetchVenue(String id) async {
    final response = await client
        .from('venues')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _venueFromJson(response);
  }

  /// Create a new venue (partner only)
  static Future<Venue> createVenue({
    required String name,
    required VenueType venueType,
    String? address,
    double? latitude,
    double? longitude,
    String? websiteUrl,
    String? imageUrl,
    String? partnerNotes,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw StateError('User not authenticated');

    final data = <String, dynamic>{
      'name': name,
      'venue_type': venueType.name,
      'address': address,
      'website_url': websiteUrl,
      'image_url': imageUrl,
      'partner_notes': partnerNotes,
      'owner_id': userId,
      'is_active': true,
    };

    if (latitude != null && longitude != null) {
      data['location'] = 'POINT($longitude $latitude)';
    }

    final response = await client.from('venues').insert(data).select().single();
    return _venueFromJson(response);
  }

  /// Update a venue (partner/admin only)
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
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (address != null) updates['address'] = address;
    if (latitude != null && longitude != null) {
      updates['location'] = 'POINT($longitude $latitude)';
    }
    if (websiteUrl != null) updates['website_url'] = websiteUrl;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (partnerNotes != null) updates['partner_notes'] = partnerNotes;
    if (isActive != null) updates['is_active'] = isActive;

    final response = await client
        .from('venues')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return _venueFromJson(response);
  }

  // ============================================================
  // EVENTS
  // ============================================================

  /// Fetch events with optional category filter
  static Future<List<Event>> fetchEvents({
    EventCategory? category,
    EventStatus? status,
    String? searchQuery,
    int? limit,
    String? ownerId, // Not directly on events, but could filter via venues
  }) async {
    dynamic query = client.from('events').select();

    if (category != null) {
      query = query.eq('category', category.name);
    }
    if (status != null) {
      query = query.eq('status', status.name);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final response = await query.order('title', ascending: true);
    return (response as List).map((json) => _eventFromJson(json)).toList();
  }

  /// Fetch a single event by ID
  static Future<Event?> fetchEvent(String id) async {
    final response = await client
        .from('events')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return _eventFromJson(response);
  }

  /// Create a new event (partner only)
  static Future<Event> createEvent({
    required EventCategory category,
    required String title,
    String? description,
    String? imageUrl,
    int? durationMinutes,
    Map<String, dynamic>? externalIds,
    Map<String, dynamic>? metadata,
    EventStatus? status,
  }) async {
    final response = await client.from('events').insert({
      'category': category.name,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'duration_minutes': durationMinutes,
      'external_ids': externalIds ?? {},
      'metadata': metadata ?? {},
      'status': status?.name ?? 'published',
    }).select().single();

    return _eventFromJson(response);
  }

  /// Update an event
  static Future<Event> updateEvent({
    required String id,
    String? title,
    String? description,
    String? imageUrl,
    int? durationMinutes,
    Map<String, dynamic>? externalIds,
    Map<String, dynamic>? metadata,
    EventStatus? status,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (durationMinutes != null) updates['duration_minutes'] = durationMinutes;
    if (externalIds != null) updates['external_ids'] = externalIds;
    if (metadata != null) updates['metadata'] = metadata;
    if (status != null) updates['status'] = status.name;

    final response = await client
        .from('events')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return _eventFromJson(response);
  }

  // ============================================================
  // SHOWTIMES
  // ============================================================

  /// Fetch showtimes for a venue
  static Future<List<Showtime>> fetchShowtimesByVenue(String venueId, {
    DateTime? from,
    DateTime? to,
    EventStatus? status,
  }) async {
    var query = client.from('showtimes').select().eq('venue_id', venueId);

    if (from != null) {
      query = query.gte('start_time', from.toIso8601String());
    }
    if (to != null) {
      query = query.lte('start_time', to.toIso8601String());
    }
    if (status != null) {
      query = query.eq('status', status.name);
    }

    final response = await query.order('start_time', ascending: true);
    return (response as List).map((json) => _showtimeFromJson(json)).toList();
  }

  /// Fetch showtimes for an event
  static Future<List<Showtime>> fetchShowtimesByEvent(String eventId, {
    EventStatus? status,
  }) async {
    var query = client.from('showtimes').select().eq('event_id', eventId);

    if (status != null) {
      query = query.eq('status', status.name);
    }

    final response = await query.order('start_time', ascending: true);
    return (response as List).map((json) => _showtimeFromJson(json)).toList();
  }

  /// Fetch active listings (joined view) - main query for user app
  static Future<List<Listing>> fetchActiveListings({
    DateTime? from,
    DateTime? to,
    EventCategory? category,
    VenueType? venueType,
    double? userLat,
    double? userLng,
    double? radiusKm,
    int? limit,
  }) async {
    dynamic query = client.from('v_listings').select();

    // Only future showtimes
    final now = DateTime.now().toIso8601String();
    query = query.gte('start_time', now);

    if (from != null) {
      query = query.gte('start_time', from.toIso8601String());
    }
    if (to != null) {
      query = query.lte('start_time', to.toIso8601String());
    }
    if (category != null) {
      query = query.eq('category', category.name);
    }
    if (venueType != null) {
      query = query.eq('venue_type', venueType.name);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    // PostGIS radius filter (if user location provided)
    if (userLat != null && userLng != null && radiusKm != null) {
      // Use raw RPC for PostGIS distance query
      final response = await client.rpc('fetch_listings_nearby', params: {
        'user_lat': userLat,
        'user_lng': userLng,
        'radius_km': radiusKm,
        'from_time': from?.toIso8601String() ?? now,
        'to_time': to?.toIso8601String(),
        'category_filter': category?.name,
        'venue_type_filter': venueType?.name,
        'limit_count': limit ?? 100,
      });
      return (response as List).map((json) => _listingFromJson(json)).toList();
    }

    final response = await query.order('start_time', ascending: true);
    return (response as List).map((json) => _listingFromJson(json)).toList();
  }

  /// Create a showtime (partner only)
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
  }) async {
    final data = <String, dynamic>{
      'venue_id': venueId,
      'event_id': eventId,
      'start_time': startTime.toIso8601String(),
      'price': price,
      'attributes': attributes ?? {},
      'booking_url': bookingUrl,
      'status': status?.name ?? 'published',
    };

    if (endTime != null) data['end_time'] = endTime.toIso8601String();
    if (capacity != null) data['capacity'] = capacity;
    if (imageUrl != null) data['image_url'] = imageUrl;

    final response = await client.from('showtimes').insert(data).select().single();
    return _showtimeFromJson(response);
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
  }) async {
    final updates = <String, dynamic>{};
    if (startTime != null) updates['start_time'] = startTime.toIso8601String();
    if (endTime != null) updates['end_time'] = endTime.toIso8601String();
    if (price != null) updates['price'] = price;
    if (capacity != null) updates['capacity'] = capacity;
    if (attributes != null) updates['attributes'] = attributes;
    if (bookingUrl != null) updates['booking_url'] = bookingUrl;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (status != null) updates['status'] = status.name;

    final response = await client
        .from('showtimes')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

    return _showtimeFromJson(response);
  }

  // ============================================================
  // ORGANIZER INVITES
  // ============================================================

  /// Create an invite for a venue
  static Future<OrganizerInvite> createInvite({
    required String venueId,
    required String email,
    String role = 'editor',
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw StateError('User not authenticated');

    final token = _generateToken();

    final response = await client.from('organizer_invites').insert({
      'venue_id': venueId,
      'invited_by': userId,
      'email': email,
      'role': role,
      'token': token,
    }).select().single();

    return _inviteFromJson(response);
  }

  /// Fetch invites for a venue
  static Future<List<OrganizerInvite>> fetchInvitesForVenue(String venueId) async {
    final response = await client
        .from('organizer_invites')
        .select()
        .eq('venue_id', venueId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => _inviteFromJson(json)).toList();
  }

  /// Accept an invite
  static Future<void> acceptInvite(String token) async {
    await client.rpc('accept_organizer_invite', params: {'invite_token': token});
  }

  // ============================================================
  // ANALYTICS
  // ============================================================

  /// Record an outbound click (non-blocking)
  static Future<void> recordClick({
    required String showtimeId,
    String? userId,
  }) async {
    await client.from('outbound_clicks').insert({
      'showtime_id': showtimeId,
      'user_id': userId ?? currentUser?.id,
    });
  }

  /// Fetch click analytics for a venue (partner/admin)
  static Future<List<OutboundClick>> fetchClicksForVenue(String venueId, {
    DateTime? from,
    DateTime? to,
  }) async {
    var query = client
        .from('outbound_clicks')
        .select('*, showtimes!inner(venue_id)')
        .eq('showtimes.venue_id', venueId);

    if (from != null) {
      query = query.gte('clicked_at', from.toIso8601String());
    }
    if (to != null) {
      query = query.lte('clicked_at', to.toIso8601String());
    }

    final response = await query.order('clicked_at', ascending: false);
    return (response as List).map((json) => _clickFromJson(json)).toList();
  }

  // ============================================================
  // REALTIME
  // ============================================================

  /// Subscribe to showtime changes for a venue
  static RealtimeChannel subscribeToShowtimes(String venueId, {
    required void Function(Showtime) onInsert,
    required void Function(Showtime) onUpdate,
    required void Function(String) onDelete,
  }) {
    return client
        .channel('showtimes_$venueId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'showtimes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'venue_id',
            value: venueId,
          ),
          callback: (payload) => onInsert(_showtimeFromJson(payload.newRecord)),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'showtimes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'venue_id',
            value: venueId,
          ),
          callback: (payload) => onUpdate(_showtimeFromJson(payload.newRecord)),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'showtimes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'venue_id',
            value: venueId,
          ),
          callback: (payload) => onDelete(payload.oldRecord['id'] as String),
        )
        .subscribe();
  }

  // ============================================================
  // JSON PARSING HELPERS
  // ============================================================

  static Venue _venueFromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      ownerId: json['owner_id'] as String?,
      name: json['name'] as String,
      venueType: VenueType.values.firstWhere(
        (e) => e.name == json['venue_type'],
        orElse: () => VenueType.cinema,
      ),
      address: json['address'] as String?,
      latitude: _extractLat(json['location']),
      longitude: _extractLng(json['location']),
      websiteUrl: json['website_url'] as String?,
      imageUrl: json['image_url'] as String?,
      partnerNotes: json['partner_notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static Event _eventFromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.movie,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      externalIds: Map<String, dynamic>.from(json['external_ids'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.published,
      ),
    );
  }

  static Showtime _showtimeFromJson(Map<String, dynamic> json) {
    return Showtime(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      venueId: json['venue_id'] as String,
      eventId: json['event_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
      price: (json['price'] as num?)?.toDouble(),
      capacity: json['capacity'] as int?,
      ticketsSold: (json['tickets_sold'] as num?)?.toInt() ?? 0,
      attributes: Map<String, dynamic>.from(json['attributes'] ?? {}),
      bookingUrl: json['booking_url'] as String,
      imageUrl: json['image_url'] as String?,
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.published,
      ),
    );
  }

  static Listing _listingFromJson(Map<String, dynamic> json) {
    return Listing(
      showtimeId: json['showtime_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
      price: (json['price'] as num?)?.toDouble(),
      showtimeAttributes: Map<String, dynamic>.from(json['showtime_attributes'] ?? json['attributes'] ?? {}),
      bookingUrl: json['booking_url'] as String,
      showtimeImageUrl: json['image_url'] as String?,
      eventId: json['event_id'] as String,
      category: EventCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EventCategory.movie,
      ),
      eventTitle: json['event_title'] as String,
      eventDescription: json['event_description'] as String?,
      imageUrl: json['image_url'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      eventMetadata: Map<String, dynamic>.from(json['event_metadata'] ?? json['metadata'] ?? {}),
      eventStatus: json['status'] != null
          ? EventStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => EventStatus.published,
            )
          : null,
      venueId: json['venue_id'] as String,
      venueName: json['venue_name'] as String,
      venueType: VenueType.values.firstWhere(
        (e) => e.name == json['venue_type'],
        orElse: () => VenueType.cinema,
      ),
      venueAddress: json['venue_address'] as String?,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      venueImageUrl: json['image_url'] as String?,
    );
  }

  static OutboundClick _clickFromJson(Map<String, dynamic> json) {
    return OutboundClick(
      id: json['id'] as String,
      clickedAt: DateTime.parse(json['clicked_at'] as String),
      userId: json['user_id'] as String?,
      showtimeId: json['showtime_id'] as String?,
    );
  }

  static OrganizerInvite _inviteFromJson(Map<String, dynamic> json) {
    return OrganizerInvite(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      venueId: json['venue_id'] as String,
      invitedBy: json['invited_by'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'editor',
      token: json['token'] as String,
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at'] as String) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
    );
  }

  static double? _extractLat(dynamic location) {
    if (location == null) return null;
    // PostGIS point format: "POINT(lng lat)"
    final match = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)').firstMatch(location as String);
    return match != null ? double.tryParse(match.group(2)!) : null;
  }

  static double? _extractLng(dynamic location) {
    if (location == null) return null;
    final match = RegExp(r'POINT\(([^ ]+) ([^ ]+)\)').firstMatch(location as String);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }

  static String _generateToken() {
    final random = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final suffix = (DateTime.now().microsecond % 10000).toRadixString(36).padLeft(4, '0');
    return 'inv_$random$suffix';
  }
}