import 'package:flutter/material.dart';
import 'package:user_app/services/api_service.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  _MoviesScreenState createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late ApiService _apiService;
  var movies;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _fetchMovies();
  }

  void _fetchMovies() async {
    movies = await _apiService.fetchMovies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Build the UI for displaying movies
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
      ),
      body: movies == null
          ? const CircularProgressIndicator()
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(movies[index]['title']),
                );
              },
            ),
    );
  }
}
