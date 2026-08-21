library core_models;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'core_models.freezed.dart';
part 'core_models.g.dart';

/// User roles in the system
@JsonEnum()
enum UserRole {
  @JsonValue('user')
  user,
  @JsonValue('partner')
  partner,
  @JsonValue('admin')
  admin,
}

/// Event categories
@JsonEnum()
enum EventCategory {
  @JsonValue('movie')
  movie,
  @JsonValue('comedy')
  comedy,
  @JsonValue('music')
  music,
  @JsonValue('theatre')
  theatre,
}

/// Event status
@JsonEnum()
enum EventStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('archived')
  archived,
}

/// Venue types
@JsonEnum()
enum VenueType {
  @JsonValue('cinema')
  cinema,
  @JsonValue('club')
  club,
  @JsonValue('theatre')
  theatre,
}

/// User profile (extends Supabase auth user)
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String email,
    String? fullName,
    @Default(UserRole.user) UserRole role,
    @Default([]) List<String> favoriteVenueIds,
    @Default([]) List<String> preferredCategories,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}

/// Venue/Cinema model
@freezed
class Venue with _$Venue {
  const factory Venue({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? ownerId,
    required String name,
    required VenueType venueType,
    String? address,
    // PostGIS point as lat/lng
    double? latitude,
    double? longitude,
    String? websiteUrl,
    String? imageUrl,
    String? partnerNotes,
    @Default(true) bool isActive,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
}

/// Event model (Movie, Comedy show, Concert, etc.)
@freezed
class Event with _$Event {
  const factory Event({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required EventCategory category,
    required String title,
    String? description,
    String? imageUrl,
    int? durationMinutes,
    // External IDs (TMDB, Spotify, Eventbrite, etc.)
    @Default({}) Map<String, dynamic> externalIds,
    // Static metadata (genres, directors, release year, etc.)
    @Default({}) Map<String, dynamic> metadata,
    @Default(EventStatus.published) EventStatus status,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

/// Showtime model
@freezed
class Showtime with _$Showtime {
  const factory Showtime({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String venueId,
    required String eventId,
    required DateTime startTime,
    DateTime? endTime,
    double? price,
    int? capacity,
    @Default(0) int ticketsSold,
    // Flexible attributes: language, subtitles, format (3D/IMAX), age restrictions
    @Default({}) Map<String, dynamic> attributes,
    required String bookingUrl,
    String? imageUrl,
    @Default(EventStatus.published) EventStatus status,
  }) = _Showtime;

  factory Showtime.fromJson(Map<String, dynamic> json) => _$ShowtimeFromJson(json);
}

/// Outbound click analytics
@freezed
class OutboundClick with _$OutboundClick {
  const factory OutboundClick({
    required String id,
    required DateTime clickedAt,
    String? userId,
    String? showtimeId,
  }) = _OutboundClick;

  factory OutboundClick.fromJson(Map<String, dynamic> json) => _$OutboundClickFromJson(json);
}

/// Organizer invite model
@freezed
class OrganizerInvite with _$OrganizerInvite {
  const factory OrganizerInvite({
    required String id,
    required DateTime createdAt,
    required String venueId,
    required String invitedBy,
    required String email,
    @Default('editor') String role,
    required String token,
    DateTime? acceptedAt,
    DateTime? expiresAt,
  }) = _OrganizerInvite;

  factory OrganizerInvite.fromJson(Map<String, dynamic> json) => _$OrganizerInviteFromJson(json);
}

/// Listing view model (joined venue + event + showtime for UI)
@freezed
class Listing with _$Listing {
  const factory Listing({
    required String showtimeId,
    required DateTime startTime,
    DateTime? endTime,
    double? price,
    required Map<String, dynamic> showtimeAttributes,
    required String bookingUrl,
    String? showtimeImageUrl,
    required String eventId,
    required EventCategory category,
    required String eventTitle,
    String? eventDescription,
    String? imageUrl,
    int? durationMinutes,
    required Map<String, dynamic> eventMetadata,
    EventStatus? eventStatus,
    required String venueId,
    required String venueName,
    required VenueType venueType,
    String? venueAddress,
    required double longitude,
    required double latitude,
    String? venueImageUrl,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);
}