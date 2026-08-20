import 'package:dio/dio.dart';
import 'package:shared/api_keys.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio();

  Future<dynamic> fetchMovies() async {
    try {
      final response = await _dio.get(
        'https://api.themoviedb.org/3/movie/popular',
        queryParameters: {
          'api_key': ApiKeys.tmdb,
        },
      );
      return response.data;
    } on DioException catch (e) {
      // Handle error
      throw Exception('Failed to load movies: ${e.message}');
    }
  }

// Other methods for interacting with the API
}
