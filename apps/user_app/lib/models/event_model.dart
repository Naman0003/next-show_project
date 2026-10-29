import 'package:core_models/core_models.dart' as core;
import 'package:flutter/material.dart';

enum EventCategory {
  all('All', Icons.grid_view_rounded),
  concerts('Concerts', Icons.music_note_rounded),
  festivals('Festivals', Icons.festival_rounded),
  exhibitions('Exhibitions', Icons.palette_rounded),
  sports('Sports', Icons.sports_basketball_rounded),
  film('Film', Icons.movie_rounded),
  food('Food', Icons.restaurant_rounded),
  nightlife('Nightlife', Icons.nightlife_rounded),
  community('Community', Icons.groups_rounded);

  final String label;
  final IconData icon;

  const EventCategory(this.label, this.icon);

  Color get accentColor => const Color(0xFF121212);

  // Legacy compatibility getters
  static EventCategory get music => concerts;
  static EventCategory get art => exhibitions;
  static EventCategory get movies => film;
  static EventCategory get comedy => nightlife;
  static EventCategory get theatre => exhibitions;
}

class Event {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final String imageUrl;
  final DateTime startDate;
  final String venueName;
  final String city;
  final bool isFree;
  final String organizer;

  /// The real `v_listings` row this event was built from, if any. Kept so
  /// [toListing] hands the detail screen the true booking URL, venue and
  /// coordinates instead of reconstructing approximations.
  final core.Listing? listing;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.startDate,
    required this.venueName,
    required this.city,
    this.isFree = true,
    required this.organizer,
    this.listing,
  });

  /// Adapts a real listing to the Home cards' model. Ingested events keep
  /// extras with no schema column (city, free flag, organizer, the source's
  /// own category label) in `eventMetadata`.
  factory Event.fromListing(core.Listing l) {
    final meta = l.eventMetadata;
    return Event(
      id: l.showtimeId,
      title: l.eventTitle,
      description: l.eventDescription ?? (meta['breaking_headline'] as String?) ?? '',
      category: _categoryFor(l),
      imageUrl: l.imageUrl ?? l.showtimeImageUrl ?? '',
      startDate: l.startTime.toLocal(),
      venueName: l.venueName,
      city: (meta['city'] as String?) ?? 'Berlin',
      isFree: meta['is_free'] == true || l.price == 0,
      organizer: (meta['organizer'] as String?) ?? l.venueName,
      listing: l,
    );
  }

  /// Home filters on nine categories but `core_models` has only four, so
  /// prefer the source's own label (e.g. "Workshop", "Stand-up") when present.
  static EventCategory _categoryFor(core.Listing l) {
    final label = ((l.eventMetadata['original_category'] as String?) ?? '').toLowerCase();
    // Match at word starts so e.g. "art" doesn't fire inside "Startup".
    bool has(List<String> words) => words.any((w) => RegExp('\\b${RegExp.escape(w)}').hasMatch(label));
    if (has(['festival'])) return EventCategory.festivals;
    if (has(['comedy', 'stand-up', 'standup', 'party', 'parties', 'club', 'nightlife'])) return EventCategory.nightlife;
    if (has(['film', 'movie', 'kino', 'cinema', 'screening'])) return EventCategory.film;
    if (has(['concert', 'konzert', 'music', 'musik'])) return EventCategory.concerts;
    if (has(['exhibition', 'ausstellung', 'art', 'kunst', 'museum', 'gallery', 'theat', 'perform'])) return EventCategory.exhibitions;
    if (has(['sport', 'yoga', 'fitness'])) return EventCategory.sports;
    if (has(['food', 'market', 'markt', 'dinner', 'wine', 'beer'])) return EventCategory.food;
    if (label.isNotEmpty) return EventCategory.community;
    return switch (l.category) {
      core.EventCategory.movie => EventCategory.film,
      core.EventCategory.music => EventCategory.concerts,
      core.EventCategory.comedy => EventCategory.nightlife,
      core.EventCategory.theatre => EventCategory.exhibitions,
    };
  }

  // Legacy getters
  String get subtitle => description;
  String get genre => category.name.toUpperCase();
  String get date => 'Showing Today';
  String get venue => venueName;
  double get price => 0.0;
  double get rating => 8.5;
  String get imdbRating => 'Free Event';
  bool get isSaved => false;
  bool get isTrending => true;
  List<String> get cast => const [];
  List<dynamic> get cinemas => const [];

  core.Listing toListing() {
    if (listing != null) return listing!;
    final (lat, lng) = _getCityCoordinates(city);
    return core.Listing(
      showtimeId: 'showtime_$id',
      startTime: startDate,
      endTime: startDate.add(const Duration(hours: 3)),
      price: isFree ? 0.0 : price,
      showtimeAttributes: {
        if (subtitle.isNotEmpty) 'tagline': subtitle,
        'genre': category.label,
        'city': city,
        if (isFree) 'entry': 'Free Admission',
      },
      bookingUrl: 'https://nextshow.de/events/$id',
      eventId: id,
      category: _mapToCoreCategory(category),
      eventTitle: title,
      eventDescription: description,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      durationMinutes: 180,
      eventMetadata: {
        'organizer': organizer,
        'city': city,
        'age_rating': 'All Ages',
      },
      venueId: 'venue_${venueName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
      venueName: venueName,
      venueType: _mapToCoreVenueType(category),
      venueAddress: venueName.isNotEmpty ? '$venueName, $city' : city,
      latitude: lat,
      longitude: lng,
    );
  }

  static core.EventCategory _mapToCoreCategory(EventCategory cat) {
    switch (cat) {
      case EventCategory.concerts:
      case EventCategory.festivals:
        return core.EventCategory.music;
      case EventCategory.film:
        return core.EventCategory.movie;
      case EventCategory.exhibitions:
        return core.EventCategory.theatre;
      case EventCategory.nightlife:
        return core.EventCategory.comedy;
      case EventCategory.sports:
      case EventCategory.food:
      case EventCategory.community:
      case EventCategory.all:
        return core.EventCategory.music;
    }
  }

  static core.VenueType _mapToCoreVenueType(EventCategory cat) {
    switch (cat) {
      case EventCategory.film:
        return core.VenueType.cinema;
      case EventCategory.exhibitions:
        return core.VenueType.theatre;
      default:
        return core.VenueType.club;
    }
  }

  static (double, double) _getCityCoordinates(String cityName) {
    switch (cityName.trim().toLowerCase()) {
      case 'munich':
      case 'münchen':
        return (48.1351, 11.5820);
      case 'hamburg':
        return (53.5511, 9.9937);
      case 'cologne':
      case 'köln':
        return (50.9375, 6.9603);
      case 'frankfurt':
        return (50.1109, 8.6821);
      case 'leipzig':
        return (51.3397, 12.3731);
      case 'berlin':
      default:
        return (52.5200, 13.4050);
    }
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    String? imageUrl,
    DateTime? startDate,
    String? venueName,
    String? city,
    bool? isFree,
    String? organizer,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      venueName: venueName ?? this.venueName,
      city: city ?? this.city,
      isFree: isFree ?? this.isFree,
      organizer: organizer ?? this.organizer,
      listing: listing,
    );
  }
}


class CastMember {
  final String name;
  final String role;
  final String imageUrl;

  CastMember({required this.name, required this.role, required this.imageUrl});
}

class ShowFormatOption {
  final String language;
  final List<String> formats;

  ShowFormatOption({required this.language, required this.formats});
}

class ShowTime {
  final String id;
  final String time;
  final String format;
  final double price;
  final String bookingUrl;

  ShowTime({
    required this.id,
    required this.time,
    required this.format,
    required this.price,
    required this.bookingUrl,
  });
}

class CinemaHall {
  final String cinemaName;
  final String distance;
  final List<ShowTime> showtimes;

  CinemaHall({
    required this.cinemaName,
    required this.distance,
    required this.showtimes,
  });
}
