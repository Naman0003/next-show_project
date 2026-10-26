import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum EventCategory {
  all('All', Icons.grid_view_rounded, AppColors.royalBlue),
  music('Music', Icons.music_note_rounded, AppColors.accentPink),
  sports('Sports', Icons.sports_basketball_rounded, AppColors.accentOrange),
  film('Film', Icons.movie_rounded, AppColors.accentCyan),
  education('Education', Icons.school_rounded, AppColors.accentTeal),
  art('Art', Icons.palette_rounded, AppColors.accentPurple),
  food('Food', Icons.restaurant_rounded, AppColors.accentYellow),
  nightlife('Nightlife', Icons.nightlife_rounded, AppColors.accentIndigo),
  community('Community', Icons.groups_rounded, AppColors.accentTeal);

  final String label;
  final IconData icon;
  final Color accentColor;

  const EventCategory(this.label, this.icon, this.accentColor);

  // Legacy compatibility enum constants
  static EventCategory get movies => film;
  static EventCategory get comedy => nightlife;
  static EventCategory get theatre => art;
}

class Event {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final EventCategory category;
  final String imageUrl;
  final DateTime startDate;
  final String venueName;
  final String city;
  final bool isFree;
  final String organizer;
  final bool isSaved;
  final bool isTrending;

  const Event({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.startDate,
    required this.venueName,
    required this.city,
    this.isFree = true,
    required this.organizer,
    this.isSaved = false,
    this.isTrending = false,
  });

  // Legacy compatibility getters
  String get genre => category.name.toUpperCase();
  String get date => 'Showing Today';
  String get venue => venueName;
  double get price => 0.0;
  double get rating => 8.5;
  String get imdbRating => 'Free Event';
  List<String> get cast => const [];
  List<dynamic> get cinemas => const [];

  Event copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    EventCategory? category,
    String? imageUrl,
    DateTime? startDate,
    String? venueName,
    String? city,
    bool? isFree,
    String? organizer,
    bool? isSaved,
    bool? isTrending,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      venueName: venueName ?? this.venueName,
      city: city ?? this.city,
      isFree: isFree ?? this.isFree,
      organizer: organizer ?? this.organizer,
      isSaved: isSaved ?? this.isSaved,
      isTrending: isTrending ?? this.isTrending,
    );
  }
}
