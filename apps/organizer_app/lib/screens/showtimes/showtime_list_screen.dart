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
  String? _selectedVenueId;
  bool _isLoadingVenues = true;

  late Future<List<Showtime>> _showtimesFuture;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    try {
      final venues = await OrganizerRepository.fetchMyVenues();
      setState(() {
        _venues = venues;
        _selectedVenueId = venues.isNotEmpty ? venues.first.id : null;
        _isLoadingVenues = false;
      });
      _loadShowtimes();
    } catch (_) {
      setState(() => _isLoadingVenues = false);
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
              _loadShowtimes();
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
                        onRefresh: () async => _loadShowtimes(),
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
                                onRetry: _loadShowtimes,
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
                                    _loadShowtimes();
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
                                final timeStr = '${st.startTime.day}/${st.startTime.month}/${st.startTime.year} at ${st.startTime.hour.toString().padLeft(2, '0')}:${st.startTime.minute.toString().padLeft(2, '0')}';

                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: NSColors.border),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(timeStr, style: NSTextStyles.titleMedium),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Price: €${st.price?.toStringAsFixed(2) ?? 'TBD'}'),
                                          if (st.attributes['format'] != null)
                                            Text(
                                              'Format: ${st.attributes['format']}',
                                              style: NSTextStyles.bodySmall.copyWith(color: NSColors.skyBlue),
                                            ),
                                        ],
                                      ),
                                    ),
                                    trailing: NSStatusBadge(status: st.status),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ShowtimeFormScreen(showtime: st)),
                                      );
                                      _loadShowtimes();
                                    },
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
          _loadShowtimes();
        },
      ),
    );
  }
}
