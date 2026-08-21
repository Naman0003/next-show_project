// lib/screens/events/event_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:core_models/core_models.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../services/organizer_repository.dart';
import 'event_form_screen.dart';
import '../showtimes/showtime_form_screen.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<Event?> _eventFuture;
  late Future<List<Showtime>> _showtimesFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _eventFuture = OrganizerRepository.fetchEvent(widget.eventId);
      _showtimesFuture = OrganizerRepository.fetchShowtimesByEvent(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Event',
            onPressed: () async {
              final event = await _eventFuture;
              if (event != null && mounted) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventFormScreen(event: event)),
                );
                _loadData();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Event?>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const NSLoading(message: 'Loading event...');
          }

          final event = snapshot.data;
          if (event == null) {
            return const NSErrorState(message: 'Event not found');
          }

          final catLabel = event.category.name[0].toUpperCase() + event.category.name.substring(1);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        event.imageUrl ?? 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400',
                        width: 110,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 110,
                          height: 160,
                          color: NSColors.royalBlue.withOpacity(0.1),
                          child: const Icon(Icons.movie, size: 48, color: NSColors.royalBlue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: NSTextStyles.headlineSmall),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(catLabel, style: NSTextStyles.labelMedium.copyWith(color: NSColors.royalBlue)),
                              if (event.durationMinutes != null)
                                Text(' • ${event.durationMinutes} min', style: NSTextStyles.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 8),
                          NSStatusBadge(status: event.status),
                        ],
                      ),
                    ),
                  ],
                ),
                if (event.description != null && event.description!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Synopsis', style: NSTextStyles.titleLarge),
                  const SizedBox(height: 6),
                  Text(event.description!, style: NSTextStyles.bodyMedium),
                ],
                const SizedBox(height: 28),

                // Showtimes section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Scheduled Showtimes', style: NSTextStyles.titleLarge),
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShowtimeFormScreen(initialEventId: event.id),
                          ),
                        );
                        _loadData();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Showtime'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                FutureBuilder<List<Showtime>>(
                  future: _showtimesFuture,
                  builder: (context, showtimeSnapshot) {
                    if (showtimeSnapshot.connectionState == ConnectionState.waiting) {
                      return const NSLoading(message: 'Loading showtimes...');
                    }

                    final showtimes = showtimeSnapshot.data ?? [];
                    if (showtimes.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: NSColors.border.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('No showtimes scheduled for this event yet.', style: TextStyle(color: NSColors.textSecondary)),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: showtimes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final st = showtimes[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: NSColors.border),
                          ),
                          child: ListTile(
                            title: Text(
                              '${st.startTime.day}/${st.startTime.month}/${st.startTime.year} at ${st.startTime.hour.toString().padLeft(2, '0')}:${st.startTime.minute.toString().padLeft(2, '0')}',
                              style: NSTextStyles.titleSmall,
                            ),
                            subtitle: Text('Price: €${st.price?.toStringAsFixed(2) ?? 'TBD'}'),
                            trailing: NSStatusBadge(status: st.status),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShowtimeFormScreen(showtime: st),
                                ),
                              );
                              _loadData();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
