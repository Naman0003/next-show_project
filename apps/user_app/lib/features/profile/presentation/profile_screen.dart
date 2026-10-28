import 'package:core_models/core_models.dart' hide EventCategory;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../models/event_model.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/tap_scale_container.dart';
import '../../auth/presentation/split_auth_screen.dart';
import '../../home/application/home_providers.dart';
import '../../watchlist/application/watchlist_controller.dart';
import '../application/recently_viewed_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _doorsAlertsEnabled = true;
  bool _freeDropsEnabled = true;
  bool _weeklyDigestEnabled = false;

  final Set<EventCategory> _selectedCategories = {
    EventCategory.concerts,
    EventCategory.festivals,
    EventCategory.nightlife,
  };

  static const List<String> _germanCities = [
    'All Cities',
    'Berlin',
    'Munich',
    'Hamburg',
    'Cologne',
    'Frankfurt',
    'Leipzig',
  ];

  void _showCityPicker(BuildContext context, String currentCity) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).padding.bottom;
        return Material(
          color: AppColors.surfaceWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radiusCard)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.75,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Select Your City',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _germanCities.length,
                      itemBuilder: (context, index) {
                        final city = _germanCities[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.location_on_rounded,
                            color: city == currentCity ? AppColors.darkPrimary : AppColors.textMuted,
                          ),
                          title: Text(
                            city,
                            style: TextStyle(
                              fontWeight: city == currentCity ? FontWeight.w800 : FontWeight.w500,
                              color: city == currentCity ? AppColors.darkPrimary : AppColors.textPrimary,
                            ),
                          ),
                          trailing: city == currentCity
                              ? const Icon(Icons.check_circle_rounded, color: AppColors.darkPrimary)
                              : null,
                          onTap: () {
                            ref.read(selectedCityProvider.notifier).state = city;
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTicketInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).padding.bottom;
        return Material(
          color: AppColors.surfaceWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radiusCard)),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    size: 36,
                    color: AppColors.darkPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'My Tickets & Bookings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tickets you purchase on NextShow will automatically be synced and available offline here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                TapScaleContainer(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    ),
                    child: const Center(
                      child: Text(
                        'Got it',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        content: Text(message, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.darkPrimary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentlyViewed = ref.watch(recentlyViewedProvider);
    final watchlist = ref.watch(watchlistControllerProvider);
    final selectedCity = ref.watch(selectedCityProvider);
    final isSignedIn = AuthService.isSignedIn;
    final currentUser = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.lightCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TapScaleContainer(
              onTap: () => _showCityPicker(context, selectedCity),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.darkPrimary),
                    const SizedBox(width: 4),
                    Text(
                      selectedCity,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 12, 20, AppTokens.dockClearance(context)),
        children: [
          // 1. Account Header Card
          _AccountHeader(
            isSignedIn: isSignedIn,
            email: currentUser?.email,
            onAuthChange: () => setState(() {}),
          ),

          const SizedBox(height: 18),

          // 2. Quick Stats Bar
          _QuickStatsBar(
            watchlistCount: watchlist.length,
            currentCity: selectedCity,
            onTapWatchlist: () => context.go('/watchlist'),
            onTapCity: () => _showCityPicker(context, selectedCity),
            onTapTickets: () => _showTicketInfoSheet(context),
          ),

          const SizedBox(height: 24),

          // 3. Live Event Preferences Section
          const Text(
            'Favorite Genres',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Personalize the events highlighted on your home screen and feed.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cat in EventCategory.values.where((c) => c != EventCategory.all))
                TapScaleContainer(
                  onTap: () {
                    setState(() {
                      if (_selectedCategories.contains(cat)) {
                        if (_selectedCategories.length > 1) {
                          _selectedCategories.remove(cat);
                        }
                      } else {
                        _selectedCategories.add(cat);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedCategories.contains(cat)
                          ? AppColors.darkPrimary
                          : AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                      border: Border.all(
                        color: _selectedCategories.contains(cat)
                            ? AppColors.darkPrimary
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat.icon,
                          size: 15,
                          color: _selectedCategories.contains(cat)
                              ? Colors.white
                              : AppColors.darkPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _selectedCategories.contains(cat)
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: _selectedCategories.contains(cat)
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // 4. Notifications & Alerts Section
          const Text(
            'Notification Alerts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: AppTokens.cardShadow,
            ),
            child: Column(
              children: [
                _NotificationToggleRow(
                  icon: Icons.access_time_rounded,
                  title: 'Doors & Showtime Alerts',
                  subtitle: 'Remind me 2 hours before show doors open',
                  value: _doorsAlertsEnabled,
                  onChanged: (val) => setState(() => _doorsAlertsEnabled = val),
                ),
                const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                _NotificationToggleRow(
                  icon: Icons.bolt_rounded,
                  title: 'Free Ticket Drops',
                  subtitle: 'Get notified instantly when 100% free passes drop',
                  value: _freeDropsEnabled,
                  onChanged: (val) => setState(() => _freeDropsEnabled = val),
                ),
                const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                _NotificationToggleRow(
                  icon: Icons.newspaper_rounded,
                  title: 'Weekend Gig Digest',
                  subtitle: 'Top curated nightlife and concerts every Thursday',
                  value: _weeklyDigestEnabled,
                  onChanged: (val) => setState(() => _weeklyDigestEnabled = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 5. Recently Viewed Events
          const Text(
            'Recently Viewed',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (recentlyViewed.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Column(
                children: [
                  Icon(Icons.history_rounded, size: 36, color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text(
                    'No Recently Viewed Events',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Events you explore on the home screen will be remembered here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recentlyViewed.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final listing = recentlyViewed[index];
                  return _RecentlyViewedCard(listing: listing);
                },
              ),
            ),

          const SizedBox(height: 24),

          // 6. Support & Legal Section
          const Text(
            'Support & Legal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: AppTokens.cardShadow,
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Concierge Support',
                  onTap: () => _showInfoDialog(
                    context,
                    'NextShow Concierge',
                    'Concierge',
                  ),
                ),
                const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _showInfoDialog(
                    context,
                    'Privacy Policy',
                    'NextShow Privacy Policy',
                  ),
                ),
                const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () => _showInfoDialog(
                    context,
                    'Terms of Service',
                    'ToS',
                  ),
                ),
                if (isSignedIn) ...[
                  const Divider(height: 1, indent: 56, color: AppColors.borderLight),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    titleColor: AppColors.heartRed,
                    iconColor: AppColors.heartRed,
                    showChevron: false,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.surfaceWhite,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800)),
                          content: const Text('Are you sure you want to sign out of NextShow?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Sign Out', style: TextStyle(color: AppColors.heartRed, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await AuthService.signOut();
                        setState(() {});
                      }
                    },
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          // 7. Version Footnote
          const Center(
            child: Text(
              'NextShow v1.2.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACCOUNT HEADER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.isSignedIn,
    this.email,
    required this.onAuthChange,
  });

  final bool isSignedIn;
  final String? email;
  final VoidCallback onAuthChange;

  @override
  Widget build(BuildContext context) {
    if (!isSignedIn) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppTokens.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.darkPrimary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join NextShow',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Unlock tickets & sync saved gigs',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TapScaleContainer(
              onTap: () async {
                await ensureSignedIn(context);
                onAuthChange();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: const Center(
                  child: Text(
                    'Sign In or Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final initial = email != null && email!.isNotEmpty ? email![0].toUpperCase() : 'U';
    final username = email != null ? email!.split('@').first : 'Attendee';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppTokens.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.darkPrimary, Color(0xFF2B2D42)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 12, color: AppColors.neonGreen),
                      SizedBox(width: 4),
                      Text(
                        'Verified Attendee',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neonGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK STATS BAR
// ─────────────────────────────────────────────────────────────────────────────

class _QuickStatsBar extends StatelessWidget {
  const _QuickStatsBar({
    required this.watchlistCount,
    required this.currentCity,
    required this.onTapWatchlist,
    required this.onTapCity,
    required this.onTapTickets,
  });

  final int watchlistCount;
  final String currentCity;
  final VoidCallback onTapWatchlist;
  final VoidCallback onTapCity;
  final VoidCallback onTapTickets;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tickets Tile
        Expanded(
          child: _StatCard(
            icon: Icons.confirmation_number_outlined,
            label: 'Tickets',
            value: '0 Active',
            onTap: onTapTickets,
          ),
        ),
        const SizedBox(width: 10),

        // Watchlist Tile
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.heartRed,
            label: 'Watchlist',
            value: '$watchlistCount Saved',
            onTap: onTapWatchlist,
          ),
        ),
        const SizedBox(width: 10),

        // City Tile
        Expanded(
          child: _StatCard(
            icon: Icons.location_on_rounded,
            label: 'City',
            value: currentCity,
            onTap: onTapCity,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    this.iconColor = AppColors.darkPrimary,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TapScaleContainer(
      onTap: onTap,
      scaleDown: 0.95,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppTokens.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFICATION TOGGLE ROW
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationToggleRow extends StatelessWidget {
  const _NotificationToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceSecondary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.darkPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.darkPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECENTLY VIEWED CARD
// ─────────────────────────────────────────────────────────────────────────────

class _RecentlyViewedCard extends StatelessWidget {
  const _RecentlyViewedCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final imageUrl = listing.imageUrl ??
        'https://picsum.photos/seed/${listing.eventId}/300/400';
    final dateStr = DateFormat('d. MMM').format(listing.startTime.toLocal());

    return TapScaleContainer(
      onTap: () => EventDetailRoute($extra: listing).push(context),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: AppTokens.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: AppColors.surfaceSecondary,
                    child: const Center(
                      child: Icon(Icons.music_note, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.eventTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateStr · ${listing.venueName}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS TILE
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.titleColor = AppColors.textPrimary,
    this.iconColor = AppColors.darkPrimary,
    this.showChevron = true,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color titleColor;
  final Color iconColor;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
