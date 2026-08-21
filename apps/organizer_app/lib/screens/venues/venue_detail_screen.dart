// lib/screens/venues/venue_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:core_models/core_models.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../services/organizer_repository.dart';
import 'venue_form_screen.dart';
import '../showtimes/showtime_form_screen.dart';

class VenueDetailScreen extends StatefulWidget {
  final String venueId;

  const VenueDetailScreen({super.key, required this.venueId});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  late Future<Venue?> _venueFuture;
  late Future<List<Showtime>> _showtimesFuture;
  late Future<List<OrganizerInvite>> _invitesFuture;

  final TextEditingController _inviteEmailController = TextEditingController();
  bool _isSendingInvite = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _venueFuture = OrganizerRepository.fetchVenue(widget.venueId);
      _showtimesFuture = OrganizerRepository.fetchShowtimesByVenue(widget.venueId);
      _invitesFuture = OrganizerRepository.fetchInvitesForVenue(widget.venueId);
    });
  }

  @override
  void dispose() {
    _inviteEmailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final email = _inviteEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => _isSendingInvite = true);

    try {
      await OrganizerRepository.createInvite(
        venueId: widget.venueId,
        email: email,
      );
      _inviteEmailController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite sent successfully!')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending invite: $e'), backgroundColor: NSColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingInvite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Venue',
            onPressed: () async {
              final venue = await _venueFuture;
              if (venue != null && mounted) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VenueFormScreen(venue: venue)),
                );
                _loadData();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Venue?>(
        future: _venueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const NSLoading(message: 'Loading venue...');
          }

          final venue = snapshot.data;
          if (venue == null) {
            return const NSErrorState(message: 'Venue not found');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header image & title
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    venue.imageUrl ?? 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=800',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: NSColors.royalBlue.withOpacity(0.1),
                      child: const Center(child: Icon(Icons.movie_outlined, size: 64, color: NSColors.royalBlue)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Text(venue.name, style: NSTextStyles.headlineSmall),
                    ),
                    NSVenueTypeBadge(type: venue.venueType),
                  ],
                ),
                if (venue.address != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: NSColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(venue.address!, style: NSTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                ],
                if (venue.websiteUrl != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.language, size: 16, color: NSColors.royalBlue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue.websiteUrl!,
                          style: NSTextStyles.bodySmall.copyWith(color: NSColors.royalBlue),
                        ),
                      ),
                    ],
                  ),
                ],
                if (venue.partnerNotes != null && venue.partnerNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NSColors.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: NSColors.warning.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Internal Notes', style: NSTextStyles.labelSmall.copyWith(color: NSColors.warning, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(venue.partnerNotes!, style: NSTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                // Showtimes Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Scheduled Showtimes', style: NSTextStyles.titleLarge),
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShowtimeFormScreen(initialVenueId: venue.id),
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
                          child: Text('No showtimes scheduled yet for this venue.', style: TextStyle(color: NSColors.textSecondary)),
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
                const SizedBox(height: 28),

                // Team Invites Section
                Text('Team Members & Invites', style: NSTextStyles.titleLarge),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inviteEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'teammate@venue.com',
                          labelText: 'Invite Email',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    NSPrimaryButton(
                      label: 'Invite',
                      isLoading: _isSendingInvite,
                      onPressed: _sendInvite,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                FutureBuilder<List<OrganizerInvite>>(
                  future: _invitesFuture,
                  builder: (context, inviteSnapshot) {
                    if (inviteSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    final invites = inviteSnapshot.data ?? [];
                    if (invites.isEmpty) {
                      return const Text('No pending invites.', style: TextStyle(color: NSColors.textSecondary));
                    }

                    return Column(
                      children: invites.map((inv) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.mail_outline, size: 20),
                          title: Text(inv.email, style: NSTextStyles.bodyMedium),
                          subtitle: Text('Role: ${inv.role}'),
                          trailing: Text(
                            inv.acceptedAt != null ? 'Accepted' : 'Pending',
                            style: TextStyle(
                              color: inv.acceptedAt != null ? NSColors.success : NSColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
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
