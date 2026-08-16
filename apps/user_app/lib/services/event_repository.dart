// lib/services/event_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';

class EventRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _defaultImage =
      'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500';

  Future<List<Event>> fetchLiveEvents() async {
    try {
      final List<dynamic> response = await _supabase
          .from('v_listings')
          .select()
          .order('start_time', ascending: true);

      if (response.isEmpty) return [];

      final Map<String, EventBuilder> eventBuilders = {};

      for (final row in response) {
        final String eventId = row['event_id']?.toString() ?? row['showtime_id']?.toString() ?? 'unknown';
        final String venueName = row['venue_name']?.toString() ?? 'Berlin Venue';
        final String address = row['venue_address']?.toString() ?? '';

        final EventCategory category = _parseCategory(row['category']?.toString());

        DateTime startTime = DateTime.now();
        if (row['start_time'] != null) {
          startTime = DateTime.tryParse(row['start_time'].toString())?.toLocal() ?? DateTime.now();
        }

        final String formattedTime =
            "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";

        final double price = (row['price'] as num?)?.toDouble() ?? 0.0;

        final showtime = ShowTime(
          id: row['showtime_id']?.toString() ?? '',
          time: formattedTime,
          format: row['language_format']?.toString() ?? 'Standard',
          price: price,
          bookingUrl: row['booking_url']?.toString() ?? '',
        );

        final String imageUrl = (row['image_url'] != null && row['image_url'].toString().trim().isNotEmpty)
            ? row['image_url'].toString()
            : _defaultImage;

        if (!eventBuilders.containsKey(eventId)) {
          eventBuilders[eventId] = EventBuilder(
            id: eventId,
            title: row['event_title']?.toString() ?? 'Untitled Event',
            category: category,
            genre: category.name.toUpperCase(),
            imageUrl: imageUrl,
            rating: 8.5,
            imdbRating: 'Live Listing',
            date: 'Showing Today',
            venue: venueName,
            basePrice: price,
          );
        }

        eventBuilders[eventId]!.addShowtime(venueName, address, showtime);
      }

      return eventBuilders.values.map((b) => b.build()).toList();
    } catch (e) {
      return [];
    }
  }

  EventCategory _parseCategory(String? catStr) {
    switch (catStr?.toLowerCase()) {
      case 'comedy':
        return EventCategory.comedy;
      case 'music':
        return EventCategory.music;
      case 'theatre':
        return EventCategory.theatre;
      case 'movie':
      case 'movies':
      default:
        return EventCategory.movies;
    }
  }
}

class EventBuilder {
  final String id;
  final String title;
  final EventCategory category;
  final String genre;
  final String imageUrl;
  final double rating;
  final String imdbRating;
  final String date;
  final String venue;
  final double basePrice;

  final Map<String, List<ShowTime>> cinemaMap = {};
  final Map<String, String> venueDistances = {};

  EventBuilder({
    required this.id,
    required this.title,
    required this.category,
    required this.genre,
    required this.imageUrl,
    required this.rating,
    required this.imdbRating,
    required this.date,
    required this.venue,
    required this.basePrice,
  });

  void addShowtime(String venueName, String address, ShowTime showtime) {
    if (!cinemaMap.containsKey(venueName)) {
      cinemaMap[venueName] = [];
      venueDistances[venueName] = address.isNotEmpty ? address : 'Berlin';
    }
    cinemaMap[venueName]!.add(showtime);
  }

  Event build() {
    final List<CinemaHall> cinemas = cinemaMap.entries.map((entry) {
      return CinemaHall(
        cinemaName: entry.key,
        distance: venueDistances[entry.key]!,
        showtimes: entry.value,
      );
    }).toList();

    return Event(
      id: id,
      title: title,
      category: category,
      genre: genre,
      imageUrl: imageUrl,
      rating: rating,
      imdbRating: imdbRating,
      date: date,
      venue: venue,
      price: basePrice,
      cinemas: cinemas,
    );
  }
}