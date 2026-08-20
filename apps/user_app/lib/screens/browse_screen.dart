// lib/screens/browse_screen.dart
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/next_show_logo.dart';
import '../widgets/account_menu_button.dart';
import 'event_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({Key? key}) : super(key: key);

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final EventRepository _eventRepository = EventRepository();
  EventCategory? selectedCategory;
  String searchQuery = "";
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _eventRepository.fetchLiveEvents();
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = _eventRepository.fetchLiveEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NextShowLogo(fontSize: 22),
            const SizedBox(height: 2),
            Text(
              "MOVIES. COMEDY. LIVE. • BERLIN",
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: AppColors.royalBlue,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshEvents,
          ),
          const AccountMenuButton(),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.royalBlue),
            );
          }

          final allEvents = snapshot.data ?? [];
          final filteredEvents = allEvents.where((event) {
            final matchesCategory = selectedCategory == null || event.category == selectedCategory;
            final matchesSearch = event.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                event.genre.toLowerCase().contains(searchQuery.toLowerCase());
            return matchesCategory && matchesSearch;
          }).toList();

          return Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search movies, comedy, music...",
                    hintStyle: const TextStyle(color: Colors.black54),
                    prefixIcon: const Icon(Icons.search, color: AppColors.royalBlue),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.royalBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _buildCategoryChip("All", null),
                    const SizedBox(width: 8),
                    _buildCategoryChip("Movies", EventCategory.movies),
                    const SizedBox(width: 8),
                    _buildCategoryChip("Comedy", EventCategory.comedy),
                    const SizedBox(width: 8),
                    _buildCategoryChip("Music", EventCategory.music),
                    const SizedBox(width: 8),
                    _buildCategoryChip("Theatre", EventCategory.theatre),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredEvents.isEmpty
                    ? const Center(
                  child: Text("No live events available right now",
                      style: TextStyle(color: Colors.black54)),
                )
                    : ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        "Live Experience Listings",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 290,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 14.0),
                            child: EventCard(event: event),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, EventCategory? category) {
    final isSelected = selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.royalBlue,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.royalBlue : AppColors.border,
        ),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (bool selected) {
        setState(() {
          selectedCategory = category;
        });
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String validImageUrl = (event.imageUrl.trim().isNotEmpty)
        ? event.imageUrl
        : 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    validImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.border,
                      child: const Icon(Icons.movie, size: 40, color: AppColors.royalBlue),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.imdbRating,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
          Text(event.genre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 4),
          Text("€${event.price.toStringAsFixed(2)} onwards", style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
