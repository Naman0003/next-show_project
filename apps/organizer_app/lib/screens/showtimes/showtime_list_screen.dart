// lib/screens/showtimes/showtime_list_screen.dart
import 'package:flutter/material.dart';
import 'package:core_models/core_models.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../services/organizer_repository.dart';
import 'showtime_form_screen.dart';

class ShowtimeListScreen extends StatefulWidget {
  const ShowtimeListScreen({super.key});

  @override
  State<ShowtimeListScreen> createState() => _ShowtimeListScreenState();
}

class _ShowtimeListScreenState extends State<ShowtimeListScreen> {
  List<Venue> _venues = [];
  Map<String, Event> _eventsMap = {};
  String? _selectedVenueId;
  bool _isLoadingVenues = true;

  late Future<List<Showtime>> _showtimesFuture;

  @override
  void initState() {
    super.initState();
    _loadVenuesAndEvents();
  }

  Future<void> _loadVenuesAndEvents() async {
    try {
      final venues = await OrganizerRepository.fetchMyVenues();
      final events = await OrganizerRepository.fetchEvents();
      final eventsMap = <String, Event>{
        for (final e in events) e.id: e,
      };

      if (mounted) {
        setState(() {
          _venues = venues;
          _eventsMap = eventsMap;
          _selectedVenueId = venues.isNotEmpty ? venues.first.id : null;
          _isLoadingVenues = false;
        });
        _loadShowtimes();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingVenues = false);
    }
  }

  void _loadShowtimes() {
    setState(() {
      if (_selectedVenueId != null) {
        _showtimesFuture = OrganizerRepository.fetchShowtimesByVenue(_selectedVenueId!);
      } else {
        _showtimesFuture = Future.value([]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Showtime Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Showtime',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShowtimeFormScreen(initialVenueId: _selectedVenueId),
                ),
              );
              _loadVenuesAndEvents();
            },
          ),
        ],
      ),
      body: _isLoadingVenues
          ? const NSLoading(message: 'Loading venues...')
          : _venues.isEmpty
              ? NSEmptyState(
                  icon: Icons.schedule,
                  title: 'No Venues Registered',
                  subtitle: 'Please create a venue first before scheduling showtimes.',
                  action: NSPrimaryButton(
                    label: 'Add Venue',
                    icon: Icons.add,
                    onPressed: () => Navigator.pop(context),
                  ),
                )
              : Column(
                  children: [
                    // Venue Selector Dropdown
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        value: _selectedVenueId,
                        decoration: const InputDecoration(
                          labelText: 'Select Venue',
                          prefixIcon: Icon(Icons.location_on),
                          isDense: true,
                        ),
                        items: _venues.map((v) {
                          return DropdownMenuItem(
                            value: v.id,
                            child: Text(v.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedVenueId = val);
                            _loadShowtimes();
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    // Showtimes List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => _loadVenuesAndEvents(),
                        color: NSColors.royalBlue,
                        child: FutureBuilder<List<Showtime>>(
                          future: _showtimesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const NSLoading(message: 'Loading showtimes...');
                            }

                            if (snapshot.hasError) {
                              return NSErrorState(
                                message: 'Failed to load showtimes: ${snapshot.error}',
                                onRetry: _loadVenuesAndEvents,
                              );
                            }

                            final showtimes = snapshot.data ?? [];
                            if (showtimes.isEmpty) {
                              return NSEmptyState(
                                icon: Icons.access_time_outlined,
                                title: 'No Showtimes Found',
                                subtitle: 'No upcoming showtimes scheduled for this venue.',
                                action: NSPrimaryButton(
                                  label: 'Schedule Showtime',
                                  icon: Icons.add,
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ShowtimeFormScreen(initialVenueId: _selectedVenueId),
                                      ),
                                    );
                                    _loadVenuesAndEvents();
                                  },
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: showtimes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final st = showtimes[index];
                                final event = _eventsMap[st.eventId];
                                final timeStr = '${st.startTime.day}/${st.startTime.month}/${st.startTime.year} at ${st.startTime.hour.toString().padLeft(2, '0')}:${st.startTime.minute.toString().padLeft(2, '0')}';

                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(color: NSColors.border),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ShowtimeFormScreen(showtime: st)),
                                      );
                                      _loadVenuesAndEvents();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          // Movie Poster Thumbnail
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              event?.imageUrl ?? 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=200',
                                              width: 54,
                                              height: 76,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                width: 54,
                                                height: 76,
                                                color: NSColors.royalBlue.withOpacity(0.1),
                                                child: const Icon(Icons.movie, color: NSColors.royalBlue, size: 28),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Movie & Showtime Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event?.title ?? 'Movie Event',
                                                  style: NSTextStyles.titleMedium.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.access_time, size: 14, color: NSColors.textSecondary),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        timeStr,
                                                        style: NSTextStyles.bodySmall,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '€${st.price?.toStringAsFixed(2) ?? 'TBD'}',
                                                      style: NSTextStyles.labelMedium.copyWith(
                                                        color: NSColors.success,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (st.attributes['format'] != null && st.attributes['format'].toString().isNotEmpty) ...[
                                                      Text(' • ', style: NSTextStyles.bodySmall),
                                                      Expanded(
                                                        child: Text(
                                                          '${st.attributes['format']}',
                                                          style: NSTextStyles.bodySmall.copyWith(color: NSColors.skyBlue),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          NSStatusBadge(status: st.status),
                                        ],
                                      ),
                                    ),
                                  ),
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
            MaterialPageRoute(
              builder: (_) => ShowtimeFormScreen(initialVenueId: _selectedVenueId),
            ),
          );
          _loadVenuesAndEvents();
        },
      ),
    );
  }
}
