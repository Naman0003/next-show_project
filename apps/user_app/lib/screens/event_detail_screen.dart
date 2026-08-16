// lib/screens/event_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../services/booking_service.dart';
import '../api_keys.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool isLoading = true;
  String liveRating = "Live Listing";
  String liveOverview = "";
  String liveDirector = "Independent Director";
  late String livePoster;
  List<Map<String, String>> castList = [];

  static const String apiKey = ApiKeys.tmdb;

  @override
  void initState() {
    super.initState();
    livePoster = (widget.event.imageUrl.trim().isNotEmpty)
        ? widget.event.imageUrl
        : 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500';
    _fetchTMDBData();
  }

  Future<void> _fetchTMDBData() async {
    try {
      String searchTitle = widget.event.title;
      if (searchTitle.contains(":")) {
        searchTitle = searchTitle.split(":")[0];
      }

      final searchUrl = Uri.parse(
          "https://api.themoviedb.org/3/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(searchTitle)}");

      final searchResponse = await http.get(searchUrl);
      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final results = searchData['results'] as List?;

        if (results != null && results.isNotEmpty) {
          final movieId = results.first['id'];

          final detailUrl = Uri.parse(
              "https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&append_to_response=credits");
          final detailResponse = await http.get(detailUrl);

          if (detailResponse.statusCode == 200) {
            final movieData = json.decode(detailResponse.body);

            final posterPath = movieData['poster_path'];
            final posterUrl = posterPath != null
                ? "https://image.tmdb.org/t/p/w500$posterPath"
                : widget.event.imageUrl;

            final voteAvg = movieData['vote_average'];
            final voteCount = movieData['vote_count'];
            final ratingStr = "$voteAvg/10 ($voteCount+ Votes)";

            final overview = movieData['overview'] ?? "Aggregated live across independent Berlin cinemas.";

            final credits = movieData['credits'];
            List<Map<String, String>> fetchedCast = [];
            String directorName = "Independent Director";

            if (credits != null) {
              final rawCast = credits['cast'] as List?;
              if (rawCast != null) {
                for (var c in rawCast.take(6)) {
                  final profilePath = c['profile_path'];
                  final headshotUrl = profilePath != null
                      ? "https://image.tmdb.org/t/p/w185$profilePath"
                      : "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150";

                  fetchedCast.add({
                    "name": c['name']?.toString() ?? "Cast Member",
                    "character": c['character']?.toString() ?? "Role",
                    "imageUrl": headshotUrl,
                  });
                }
              }

              final rawCrew = credits['crew'] as List?;
              if (rawCrew != null) {
                for (var member in rawCrew) {
                  if (member['job'] == 'Director') {
                    directorName = member['name']?.toString() ?? "Independent Director";
                    break;
                  }
                }
              }
            }

            if (mounted) {
              setState(() {
                livePoster = posterUrl;
                liveRating = ratingStr;
                liveOverview = overview;
                liveDirector = directorName;
                castList = fetchedCast;
                isLoading = false;
              });
              return;
            }
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        liveRating = widget.event.imdbRating;
        liveOverview = "Join us for an incredible live experience featuring top performers and vibrant atmosphere.";
        liveDirector = "Event Director";
        castList = widget.event.cast
            ?.map((c) => {
          "name": c.name,
          "character": c.role,
          "imageUrl": c.imageUrl,
        })
            .toList() ??
            [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event.title)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 260,
              width: double.infinity,
              child: Image.network(
                livePoster,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE2E8F0),
                  child: const Icon(Icons.movie, size: 60, color: Color(0xFF6366F1)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(widget.event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                        child: Text(liveRating, style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(widget.event.genre, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                  const Divider(height: 32, color: Color(0xFFE2E8F0)),

                  if (castList.isNotEmpty) ...[
                    const Text("Cast & Director", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text("Director: $liveDirector", style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 14),

                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: castList.length,
                        itemBuilder: (context, index) {
                          final actor = castList[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFF6366F1),
                                  child: ClipOval(
                                    child: Image.network(
                                      actor["imageUrl"] ?? "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  actor["name"] ?? "",
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Text(
                                  actor["character"] ?? "",
                                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 32, color: Color(0xFFE2E8F0)),
                  ],

                  const Text("Synopsis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(
                    liveOverview,
                    style: const TextStyle(color: Colors.black87, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Lowest Price", style: TextStyle(color: Colors.black54, fontSize: 12)),
                Text("€${widget.event.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFFF6B9D)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CinemaAggregatorScreen(event: widget.event)),
                  );
                },
                child: const Text("View Showtimes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CinemaAggregatorScreen extends StatelessWidget {
  final Event event;

  const CinemaAggregatorScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${event.title} • Showtimes")),
      body: (event.cinemas == null || event.cinemas!.isEmpty)
          ? const Center(
        child: Text(
          "No showtimes available for this event.",
          style: TextStyle(color: Colors.black54),
        ),
      )
          : ListView.builder(
        itemCount: event.cinemas!.length,
        itemBuilder: (context, index) {
          final cinema = event.cinemas![index];
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cinema.cinemaName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(cinema.distance, style: const TextStyle(fontSize: 12, color: Color(0xFF059669))),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: cinema.showtimes.map((st) {
                    return GestureDetector(
                      onTap: () {
                        BookingService.launchBookingUrl(
                          context,
                          st.bookingUrl,
                          showtimeId: st.id,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF6366F1)),
                          color: const Color(0xFFF8F9FA),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(st.time, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                            Text(st.format, style: const TextStyle(color: Color(0xFFFF6B9D), fontSize: 10)),
                            Text("€${st.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.black54, fontSize: 10)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}