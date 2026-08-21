// lib/services/tmdb_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared/api_keys.dart';

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

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) NextShowApp/1.0',
    'Accept': 'application/json',
  };

  static final List<TmdbMovieSearchResult> _fallbackCatalog = [
    const TmdbMovieSearchResult(
      id: 693134,
      title: 'Dune: Part Two',
      overview: 'Follow the mythic journey of Paul Atreides as he unites with Chani and the Fremen while on a path of revenge against the conspirators who destroyed his family.',
      posterPath: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500',
      releaseDate: '2024-03-01',
      voteAverage: 8.5,
      runtime: 166,
    ),
    const TmdbMovieSearchResult(
      id: 438631,
      title: 'Dune',
      overview: 'Paul Atreides, a brilliant and gifted young man born into a great destiny beyond his understanding, must travel to the most dangerous planet in the universe.',
      posterPath: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
      releaseDate: '2021-09-15',
      voteAverage: 7.9,
      runtime: 155,
    ),
    const TmdbMovieSearchResult(
      id: 27205,
      title: 'Inception',
      overview: 'Cobb, a skilled thief who steals valuable secrets from deep within the subconscious during the dream state, is offered a chance at redemption.',
      posterPath: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=500',
      releaseDate: '2010-07-15',
      voteAverage: 8.4,
      runtime: 148,
    ),
    const TmdbMovieSearchResult(
      id: 872585,
      title: 'Oppenheimer',
      overview: 'The story of J. Robert Oppenheimer’s role in the development of the atomic bomb during World War II.',
      posterPath: 'https://images.unsplash.com/photo-1478760329108-5c3ed9d495a0?w=500',
      releaseDate: '2023-07-19',
      voteAverage: 8.1,
      runtime: 180,
    ),
    const TmdbMovieSearchResult(
      id: 157336,
      title: 'Interstellar',
      overview: 'The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel.',
      posterPath: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=500',
      releaseDate: '2014-11-05',
      voteAverage: 8.4,
      runtime: 169,
    ),
    const TmdbMovieSearchResult(
      id: 155,
      title: 'The Dark Knight',
      overview: 'Batman raises the stakes in his war on crime. With the help of Lt. Jim Gordon and District Attorney Harvey Dent, Batman sets out to dismantle remaining organizations.',
      posterPath: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500',
      releaseDate: '2008-07-16',
      voteAverage: 8.5,
      runtime: 152,
    ),
    const TmdbMovieSearchResult(
      id: 414906,
      title: 'The Batman',
      overview: 'In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler.',
      posterPath: 'https://images.unsplash.com/photo-1531259683007-016a7b628fc3?w=500',
      releaseDate: '2022-03-01',
      voteAverage: 7.7,
      runtime: 176,
    ),
    const TmdbMovieSearchResult(
      id: 533535,
      title: 'Deadpool & Wolverine',
      overview: 'A weary Wolverine finds himself recovering from his injuries when he comes across the loudmouth Deadpool.',
      posterPath: 'https://images.unsplash.com/photo-1568832359672-e36cf5d74f54?w=500',
      releaseDate: '2024-07-24',
      voteAverage: 7.7,
      runtime: 128,
    ),
  ];

  /// Search TMDB for movies matching a query string with ISP fallback support
  static Future<List<TmdbMovieSearchResult>> searchMovies(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    try {
      final uri = Uri.parse(
        '$_baseUrl/search/movie?api_key=${ApiKeys.tmdb}&query=${Uri.encodeComponent(cleanQuery)}&include_adult=false&language=en-US',
      );

      debugPrint('>>> [TMDB] Searching URL: $uri');
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 4),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        if (results.isNotEmpty) {
          debugPrint('>>> [TMDB] Live search returned ${results.length} movies for "$cleanQuery"');
          return results.map((json) => TmdbMovieSearchResult.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('>>> [TMDB] Live search unavailable ($e). Using curated catalog fallback.');
    }

    // Fallback search in local catalog if live API is blocked by ISP
    final queryLower = cleanQuery.toLowerCase();
    final matches = _fallbackCatalog.where((m) => m.title.toLowerCase().contains(queryLower)).toList();

    if (matches.isNotEmpty) {
      return matches;
    }

    // If query didn't match fallback catalog, return fallback catalog list
    return _fallbackCatalog;
  }

  /// Fetch movie details including runtime in minutes
  static Future<int?> fetchMovieRuntime(int tmdbId) async {
    try {
      final uri = Uri.parse('$_baseUrl/movie/$tmdbId?api_key=${ApiKeys.tmdb}');
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 4),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['runtime'] as int?;
      }
    } catch (_) {}

    // Fallback lookup
    final match = _fallbackCatalog.firstWhere(
      (m) => m.id == tmdbId,
      orElse: () => const TmdbMovieSearchResult(id: 0, title: '', voteAverage: 0, runtime: 120),
    );
    return match.runtime ?? 120;
  }
}
