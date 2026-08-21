// lib/screens/events/event_list_screen.dart
import 'package:flutter/material.dart';
import 'package:core_models/core_models.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../services/organizer_repository.dart';
import 'event_form_screen.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Future<List<Event>> _eventsFuture;
  EventCategory? _selectedCategory;
  EventStatus? _selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _eventsFuture = OrganizerRepository.fetchEvents(
        category: _selectedCategory,
        status: _selectedStatus,
        searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events Catalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Event',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventFormScreen()),
              );
              _loadEvents();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events by title...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadEvents();
                            },
                          )
                        : null,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _loadEvents(),
                ),
                const SizedBox(height: 10),

                // Category filter chips
                NSCategoryFilter(
                  selectedCategory: _selectedCategory,
                  onChanged: (cat) {
                    setState(() => _selectedCategory = cat);
                    _loadEvents();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Events list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadEvents(),
              color: NSColors.royalBlue,
              child: FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const NSLoading(message: 'Loading events...');
                  }

                  if (snapshot.hasError) {
                    return NSErrorState(
                      message: 'Failed to load events: ${snapshot.error}',
                      onRetry: _loadEvents,
                    );
                  }

                  final events = snapshot.data ?? [];
                  if (events.isEmpty) {
                    return NSEmptyState(
                      icon: Icons.movie_outlined,
                      title: 'No Events Found',
                      subtitle: 'Create a movie, show, or concert to schedule showtimes.',
                      action: NSPrimaryButton(
                        label: 'Create Event',
                        icon: Icons.add,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EventFormScreen()),
                          );
                          _loadEvents();
                        },
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return _EventCard(
                        event: event,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(eventId: event.id),
                            ),
                          );
                          _loadEvents();
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NSColors.royalBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventFormScreen()),
          );
          _loadEvents();
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catLabel = event.category.name[0].toUpperCase() + event.category.name.substring(1);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: NSColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  event.imageUrl ?? 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400',
                  width: 64,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 90,
                    color: NSColors.royalBlue.withOpacity(0.1),
                    child: const Icon(Icons.movie, color: NSColors.royalBlue),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: NSTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        NSStatusBadge(status: event.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$catLabel ${event.durationMinutes != null ? '• ${event.durationMinutes} min' : ''}',
                      style: NSTextStyles.bodySmall.copyWith(color: NSColors.skyBlue, fontWeight: FontWeight.bold),
                    ),
                    if (event.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        event.description!,
                        style: NSTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
