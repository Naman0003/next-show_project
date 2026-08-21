// lib/screens/venues/venue_list_screen.dart
import 'package:flutter/material.dart';
import 'package:core_models/core_models.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../services/organizer_repository.dart';
import 'venue_form_screen.dart';
import 'venue_detail_screen.dart';

class VenueListScreen extends StatefulWidget {
  const VenueListScreen({super.key});

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  late Future<List<Venue>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  void _loadVenues() {
    setState(() {
      _venuesFuture = OrganizerRepository.fetchMyVenues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Venues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Venue',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VenueFormScreen()),
              );
              _loadVenues();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadVenues(),
        color: NSColors.royalBlue,
        child: FutureBuilder<List<Venue>>(
          future: _venuesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const NSLoading(message: 'Loading venues...');
            }

            if (snapshot.hasError) {
              return NSErrorState(
                message: 'Failed to load venues: ${snapshot.error}',
                onRetry: _loadVenues,
              );
            }

            final venues = snapshot.data ?? [];

            if (venues.isEmpty) {
              return NSEmptyState(
                icon: Icons.location_off_outlined,
                title: 'No Venues Found',
                subtitle: 'Add your first cinema or event venue to start creating showtimes.',
                action: NSPrimaryButton(
                  label: 'Add Venue',
                  icon: Icons.add,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VenueFormScreen()),
                    );
                    _loadVenues();
                  },
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: venues.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final venue = venues[index];
                return _VenueCard(
                  venue: venue,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VenueDetailScreen(venueId: venue.id),
                      ),
                    );
                    _loadVenues();
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NSColors.royalBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VenueFormScreen()),
          );
          _loadVenues();
        },
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onTap;

  const _VenueCard({
    required this.venue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  venue.imageUrl ?? 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=400',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70,
                    height: 70,
                    color: NSColors.royalBlue.withOpacity(0.1),
                    child: const Icon(Icons.movie_outlined, color: NSColors.royalBlue, size: 32),
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
                            venue.name,
                            style: NSTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        NSVenueTypeBadge(type: venue.venueType),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      venue.address ?? 'No address set',
                      style: NSTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          venue.isActive ? Icons.check_circle : Icons.pause_circle,
                          size: 14,
                          color: venue.isActive ? NSColors.success : NSColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          venue.isActive ? 'Active' : 'Inactive',
                          style: NSTextStyles.labelSmall.copyWith(
                            color: venue.isActive ? NSColors.success : NSColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: NSColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
