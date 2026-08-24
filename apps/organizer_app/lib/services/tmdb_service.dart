// lib/services/tmdb_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  static const List<String> _baseUrls = [
    'https://api.themoviedb.org/3',
    'https://api.tmdb.org/3',
  ];

  static Dio _createDio(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Search TMDB for movies matching a query string using Dio with host failover
  static Future<List<TmdbMovieSearchResult>> searchMovies(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    for (final baseUrl in _baseUrls) {
      try {
        debugPrint('>>> [TMDB] Trying TMDB host: $baseUrl for "$cleanQuery"');
        final dio = _createDio(baseUrl);

        final response = await dio.get(
          '/search/movie',
          queryParameters: {
            'api_key': ApiKeys.tmdb,
            'query': cleanQuery,
            'include_adult': false,
            'language': 'en-US',
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data is String ? jsonDecode(response.data as String) : response.data;
          final results = data['results'] as List? ?? [];
          if (results.isNotEmpty) {
            debugPrint('>>> [TMDB] Live search returned ${results.length} movies');
            return results.map((json) => TmdbMovieSearchResult.fromJson(json as Map<String, dynamic>)).toList();
          }
        }
      } catch (e) {
        debugPrint('>>> [TMDB] Host $baseUrl exception: $e');
      }
    }

    return [];
  }

  /// Fetch movie details including runtime in minutes using Dio with host failover
  static Future<int?> fetchMovieRuntime(int tmdbId) async {
    for (final baseUrl in _baseUrls) {
      try {
        final dio = _createDio(baseUrl);
        final response = await dio.get(
          '/movie/$tmdbId',
          queryParameters: {
            'api_key': ApiKeys.tmdb,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data is String ? jsonDecode(response.data as String) : response.data;
          return data['runtime'] as int?;
        }
      } catch (_) {}
    }

    return null;
  }
}
