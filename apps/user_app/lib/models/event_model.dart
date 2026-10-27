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
  });

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
    );
  }
}
