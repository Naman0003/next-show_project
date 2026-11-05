// lib/services/tmdb_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TmdbMovieSearchResult {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;
  final int? runtime;

  const TmdbMovieSearchResult({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.releaseDate,
    required this.voteAverage,
    this.runtime,
  });

  String? get fullPosterUrl => posterPath != null && posterPath!.isNotEmpty
      ? (posterPath!.startsWith('http') ? posterPath : 'https://image.tmdb.org/t/p/w500$posterPath')
      : null;

  String get releaseYear {
    if (releaseDate != null && releaseDate!.length >= 4) {
      return releaseDate!.substring(0, 4);
    }
    return '';
  }

  factory TmdbMovieSearchResult.fromJson(Map<String, dynamic> json) {
    return TmdbMovieSearchResult(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      runtime: json['runtime'] as int?,
    );
  }
}

class TmdbMovieDetails {
  final int id;
  final String title;
  final String? overview;
  final String? posterUrl;
  final int? runtime;
  final String? director;
  final List<String> genres;
  final String? releaseYear;

  const TmdbMovieDetails({
    required this.id,
    required this.title,
    this.overview,
    this.posterUrl,
    this.runtime,
    this.director,
    this.genres = const [],
    this.releaseYear,
  });
}

/// TMDB through the `tmdb` edge function: the API key stays on the server (S5), and only
/// the server can mark an event verified (S3). Verified partners and admins only.
class TmdbService {
  static Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final res = await Supabase.instance.client.functions.invoke('tmdb', body: body);
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Search TMDB for movies matching a query string.
  static Future<List<TmdbMovieSearchResult>> searchMovies(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];
    try {
      final data = await _call({'action': 'search', 'query': cleanQuery});
      return (data['results'] as List? ?? [])
          .map((json) => TmdbMovieSearchResult.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      debugPrint('>>> [TMDB] search failed: $e');
      return [];
    }
  }

  /// Full movie details including runtime, director and genres.
  static Future<TmdbMovieDetails?> fetchMovieDetails(int tmdbId) async {
    try {
      final data = await _call({'action': 'details', 'id': tmdbId});
      final d = Map<String, dynamic>.from(data['details'] as Map);
      return TmdbMovieDetails(
        id: d['id'] as int,
        title: d['title'] as String? ?? 'Untitled',
        overview: d['overview'] as String?,
        posterUrl: d['poster_url'] as String?,
        runtime: d['runtime'] as int?,
        director: d['director'] as String?,
        genres: (d['genres'] as List? ?? []).cast<String>(),
        releaseYear: d['release_year'] as String?,
      );
    } catch (e) {
      debugPrint('>>> [TMDB] details failed ($tmdbId): $e');
      return null;
    }
  }

  /// Asks the server to check the event's tmdb_id against TMDB and mark it verified.
  /// The server also overwrites title, synopsis, poster and runtime with TMDB's values.
  /// Throws when verification fails, so the caller can tell the partner.
  static Future<void> verifyEvent(String eventId) async {
    await _call({'action': 'verify', 'event_id': eventId});
  }
}
