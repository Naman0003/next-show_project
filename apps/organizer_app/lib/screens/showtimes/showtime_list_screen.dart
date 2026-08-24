// lib/screens/showtimes/showtime_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:core_models/core_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // Realtime showtimes list — updated via stream
  List<Showtime> _showtimes = [];
  bool _isLoadingShowtimes = false;
  String? _showtimesError;

  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSub;

  @override
  void initState() {
    super.initState();
    _loadVenuesAndEvents();
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
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
          _selectedVenueId = _selectedVenueId ?? (venues.isNotEmpty ? venues.first.id : null);
          _isLoadingVenues = false;
        });
        _subscribeShowtimes();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingVenues = false);
    }
  }

  /// Subscribe to Supabase Realtime on the showtimes table,
  /// filtered to the currently selected venue.
  void _subscribeShowtimes() {
    _realtimeSub?.cancel();
    _realtimeSub = null;

    if (_selectedVenueId == null) {
      setState(() {
        _showtimes = [];
        _isLoadingShowtimes = false;
      });
      return;
    }

    setState(() {
      _isLoadingShowtimes = true;
      _showtimesError = null;
    });

    final client = Supabase.instance.client;
    final venueId = _selectedVenueId!;

    // Initial fetch
    _fetchShowtimesForVenue(venueId);

    // Realtime subscription — fires on INSERT / UPDATE / DELETE
    _realtimeSub = client
        .from('showtimes')
        .stream(primaryKey: ['id'])
        .eq('venue_id', venueId)
        .listen(
          (rows) {
            if (!mounted) return;
            // Refresh events map too (a newly created event might not be in cache)
            _refreshEventsIfNeeded(rows).then((_) {
              if (!mounted) return;
              final showtimes = rows.map((r) => _showtimeFromJson(r)).toList()
                ..sort((a, b) => a.startTime.compareTo(b.startTime));
              setState(() {
                _showtimes = showtimes;
                _isLoadingShowtimes = false;
              });
            });
          },
          onError: (err) {
            if (mounted) {
              setState(() {
                _showtimesError = 'Realtime error: $err';
                _isLoadingShowtimes = false;
              });
            }
          },
        );
  }

  Future<void> _fetchShowtimesForVenue(String venueId) async {
    try {
      final showtimes = await OrganizerRepository.fetchShowtimesByVenue(venueId);
      if (mounted) {
        setState(() {
          _showtimes = showtimes;
          _isLoadingShowtimes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showtimesError = 'Failed to load showtimes: $e';
          _isLoadingShowtimes = false;
        });
      }
    }
  }

  /// If any showtime references an event we don't have cached, re-fetch events.
  Future<void> _refreshEventsIfNeeded(List<Map<String, dynamic>> rows) async {
    final unknownEventIds = rows
        .map((r) => r['event_id'] as String?)
        .whereType<String>()
        .where((id) => !_eventsMap.containsKey(id))
        .toSet();

    if (unknownEventIds.isEmpty) return;

    try {
      final events = await OrganizerRepository.fetchEvents();
      if (mounted) {
        setState(() {
          for (final e in events) {
            _eventsMap[e.id] = e;
          }
        });
      }
    } catch (_) {}
  }

  Showtime _showtimeFromJson(Map<String, dynamic> r) {
    return Showtime(
      id: r['id'] as String,
      eventId: r['event_id'] as String,
      venueId: r['venue_id'] as String,
      startTime: DateTime.parse(r['start_time'] as String),
      endTime: r['end_time'] != null ? DateTime.parse(r['end_time'] as String) : null,
      price: (r['price'] as num?)?.toDouble(),
      createdAt: r['created_at'] != null
          ? DateTime.parse(r['created_at'] as String)
          : DateTime.now(),
      updatedAt: r['updated_at'] != null
          ? DateTime.parse(r['updated_at'] as String)
          : DateTime.now(),
      bookingUrl: r['booking_url'] as String? ?? '',
      status: EventStatus.values.firstWhere(
        (s) => s.name == (r['status'] as String? ?? 'published'),
        orElse: () => EventStatus.published,
      ),
      attributes: Map<String, dynamic>.from(r['attributes'] as Map? ?? {}),
    );
  }

  void _changeVenue(String venueId) {
    setState(() => _selectedVenueId = venueId);
    _subscribeShowtimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Showtime Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadVenuesAndEvents,
          ),
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
              // Realtime will auto-update — just refresh events cache
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
                          if (val != null) _changeVenue(val);
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    // Showtimes List
                    Expanded(
                      child: _isLoadingShowtimes
                          ? const NSLoading(message: 'Loading showtimes...')
                          : _showtimesError != null
                              ? NSErrorState(
                                  message: _showtimesError!,
                                  onRetry: _loadVenuesAndEvents,
                                )
                              : _showtimes.isEmpty
                                  ? NSEmptyState(
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
                                        },
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _showtimes.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final st = _showtimes[index];
                                        final event = _eventsMap[st.eventId];
                                        final timeStr =
                                            '${st.startTime.day}/${st.startTime.month}/${st.startTime.year} at ${st.startTime.hour.toString().padLeft(2, '0')}:${st.startTime.minute.toString().padLeft(2, '0')}';

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
                                              // Realtime auto-refreshes; just sync event cache
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
                                                            if (st.attributes['format'] != null &&
                                                                st.attributes['format'].toString().isNotEmpty) ...[
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
                                    ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_new_showtime',
        backgroundColor: NSColors.royalBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShowtimeFormScreen(initialVenueId: _selectedVenueId),
            ),
          );
        },
      ),
    );
  }
}
