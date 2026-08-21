// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:ui_kit/ui_kit.dart';
import '../services/organizer_repository.dart';
import 'venues/venue_list_screen.dart';
import 'venues/venue_form_screen.dart';
import 'events/event_list_screen.dart';
import 'events/event_form_screen.dart';
import 'showtimes/showtime_list_screen.dart';
import 'showtimes/showtime_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const NSLogo(fontSize: 20),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, color: NSColors.textSecondary),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sign Out', style: TextStyle(color: NSColors.error)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await NextShowSupabaseClient.signOut();
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          VenueListScreen(),
          EventListScreen(),
          ShowtimeListScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: NSColors.royalBlue,
        unselectedItemColor: NSColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Venues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Showtimes',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  late Future<PartnerStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = OrganizerRepository.fetchPartnerStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = NextShowSupabaseClient.currentUser;

    return RefreshIndicator(
      onRefresh: () async => _loadStats(),
      color: NSColors.royalBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: NSColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partner Portal',
                    style: NSTextStyles.labelMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Organizer',
                    style: NSTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your venues, events, and screening showtimes.',
                    style: NSTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Metrics Overview', style: NSTextStyles.titleLarge),
            const SizedBox(height: 12),

            // Stats grid
            FutureBuilder<PartnerStats>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: NSLoading(message: 'Loading partner metrics...'),
                  );
                }

                if (snapshot.hasError) {
                  return NSErrorState(
                    message: 'Failed to load stats: ${snapshot.error}',
                    onRetry: _loadStats,
                  );
                }

                final stats = snapshot.data!;

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _StatCard(
                      title: 'My Venues',
                      value: stats.venueCount.toString(),
                      icon: Icons.location_on,
                      color: NSColors.royalBlue,
                    ),
                    _StatCard(
                      title: 'Total Events',
                      value: stats.eventCount.toString(),
                      icon: Icons.movie_filter,
                      color: NSColors.skyBlue,
                    ),
                    _StatCard(
                      title: 'Upcoming Showtimes',
                      value: stats.upcomingShowtimesCount.toString(),
                      icon: Icons.access_time_filled,
                      color: NSColors.warning,
                    ),
                    _StatCard(
                      title: 'Clicks (7 days)',
                      value: stats.clickCountThisWeek.toString(),
                      icon: Icons.ads_click,
                      color: NSColors.success,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Quick Actions
            Text('Quick Actions', style: NSTextStyles.titleLarge),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_location_alt,
                    label: 'Add Venue',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VenueFormScreen()),
                      );
                      _loadStats();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.post_add,
                    label: 'Create Event',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EventFormScreen()),
                      );
                      _loadStats();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.more_time,
                    label: 'New Showtime',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShowtimeFormScreen()),
                      );
                      _loadStats();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: NSColors.snowWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NSColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: NSTextStyles.labelMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: NSTextStyles.displaySmall.copyWith(
              fontSize: 28,
              color: NSColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 84,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: NSColors.royalBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NSColors.royalBlue.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: NSColors.royalBlue, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: NSTextStyles.labelMedium.copyWith(
                color: NSColors.royalBlue,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
