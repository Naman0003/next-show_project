// lib/screens/ai_recommender.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/event_model.dart';
import '../api_keys.dart';
import 'event_detail_screen.dart'; // Clean import instead of ../main.dart

class AiMovieRecommenderScreen extends StatefulWidget {
  const AiMovieRecommenderScreen({Key? key}) : super(key: key);

  @override
  State<AiMovieRecommenderScreen> createState() => _AiMovieRecommenderScreenState();
}

class _AiMovieRecommenderScreenState extends State<AiMovieRecommenderScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _hasError = false;
  bool _isLoading = false;
  bool _hasSearched = false;
  String _aiResponseText = "";
  List<Event> _recommendedMovies = [];

  static const String _geminiApiKey = ApiKeys.gemini;
  static const String _tmdbApiKey = ApiKeys.tmdb;

  Future<void> _getAiRecommendations(String userPrompt) async {
    if (userPrompt.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _hasSearched = true;
      _recommendedMovies.clear();
      _aiResponseText = "";
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _geminiApiKey,
      );

      final prompt = '''
      You are a friendly Berlin cinema movie concierge. 
      The user asks: "$userPrompt".
      
      Provide a short 1-sentence friendly intro message, followed by exactly 3 movie title suggestions.
      Return ONLY valid JSON in this exact structure without markdown block quotes:
      {
        "intro": "Here are 3 thrilling picks for your cozy night in!",
        "movies": ["Interstellar", "Inception", "Arrival"]
      }
    ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final rawText = response.text ?? "";

      final cleanJsonString = rawText.replaceAll("```json", "").replaceAll("```", "").trim();
      final decodedData = json.decode(cleanJsonString);

      final String introText = decodedData['intro'] ?? "Here are top movie recommendations for you:";
      final List<dynamic> movieTitles = decodedData['movies'] ?? [];

      final fetchFutures = movieTitles.map((title) async {
        final searchUrl = Uri.parse(
            "https://api.themoviedb.org/3/search/movie?api_key=$_tmdbApiKey&query=${Uri.encodeComponent(title.toString())}");
        try {
          final res = await http.get(searchUrl);
          if (res.statusCode == 200) {
            final searchData = json.decode(res.body);
            final results = searchData['results'] as List;
            if (results.isNotEmpty) {
              final movie = results.first;
              final posterPath = movie['poster_path'];
              final posterUrl = posterPath != null
                  ? "https://image.tmdb.org/t/p/w500$posterPath"
                  : "https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500";

              return Event(
                id: movie['id'].toString(),
                title: movie['title'] ?? title.toString(),
                category: EventCategory.movies,
                genre: "AI Recommendation",
                imageUrl: posterUrl,
                rating: (movie['vote_average'] as num?)?.toDouble() ?? 8.0,
                imdbRating: "${movie['vote_average']}/10 ★ TMDb",
                date: "Showing in Berlin",
                venue: "Berlin Independent Cinemas",
                price: 10.00,
              );
            }
          }
        } catch (_) {}
        return null;
      });

      final fetchedEvents = (await Future.wait(fetchFutures))
          .whereType<Event>()
          .toList();

      if (fetchedEvents.isEmpty) {
        throw Exception("No matching movies found in TMDb.");
      }

      setState(() {
        _aiResponseText = introText;
        _recommendedMovies = fetchedEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("✨ AI Mood Concierge"),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "What kind of movie are you in the mood for?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "e.g. Action movie with plot twists for date night",
                          hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () => _getAiRecommendations(_promptController.text),
                      child: const Icon(Icons.auto_awesome, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickChip("🤯 Mind-bending Sci-Fi"),
                      _buildQuickChip("😂 Feel-good Comedy"),
                      _buildQuickChip("🍿 Action Date Night"),
                      _buildQuickChip("🌧️ Cozy Rainy Day Classic"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6366F1)),
                  SizedBox(height: 16),
                  Text("Gemini AI is analyzing your mood...", style: TextStyle(color: Colors.black54)),
                ],
              ),
            )
                : _hasError
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      "Couldn't get recommendations right now.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                      onPressed: () => _getAiRecommendations(_promptController.text),
                      child: const Text("Try Again", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
                : _recommendedMovies.isEmpty
                ? Center(
              child: Text(
                _hasSearched
                    ? "No matches found for that mood — try rephrasing your prompt."
                    : "Type a prompt or select a mood chip above!",
                style: const TextStyle(color: Colors.black45),
                textAlign: TextAlign.center,
              ),
            )
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_aiResponseText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(.3)),
                    ),
                    child: Text(
                      "🤖 $_aiResponseText",
                      style: const TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ..._recommendedMovies.map((event) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(event.imageUrl, width: 50, height: 70, fit: BoxFit.cover),
                      ),
                      title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${event.imdbRating} • ${event.genre}"),
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFF6366F1)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1))),
      backgroundColor: const Color(0xFFF1F5F9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        _promptController.text = label;
        _getAiRecommendations(label);
      },
    );
  }
}