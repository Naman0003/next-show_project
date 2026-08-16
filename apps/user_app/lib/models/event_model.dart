// lib/models/event_model.dart

enum EventCategory { movies, comedy, music, theatre }

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

class Event {
  final String id;
  final String title;
  final EventCategory category;
  final String genre;
  final String imageUrl;
  final double rating;
  final String imdbRating;
  final String date;
  final String venue;
  final double price;
  bool isFavorite;
  final List<CastMember>? cast;
  final List<ShowFormatOption>? formatOptions;
  final List<CinemaHall>? cinemas;

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.genre,
    required this.imageUrl,
    required this.rating,
    required this.imdbRating,
    required this.date,
    required this.venue,
    required this.price,
    this.isFavorite = false,
    this.cast,
    this.formatOptions,
    this.cinemas,
  });
}