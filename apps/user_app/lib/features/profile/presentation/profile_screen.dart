import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth_service.dart';
import '../../../core/theme/app_tokens.dart';
import '../../auth/presentation/split_auth_screen.dart';
import '../../discovery/presentation/cinema_theme.dart';
import '../../discovery/presentation/movie_poster_card.dart';
import '../application/recently_viewed_provider.dart';
import 'package:ui_kit/ui_kit.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Placeholder-only state: not wired to notifications infra yet.
  bool _newShowtimesEnabled = true;
  bool _priceDropsEnabled = false;
  bool _weeklyDigestEnabled = true;

  @override
  Widget build(BuildContext context) {
    final recentlyViewed = ref.watch(recentlyViewedProvider);
    final toggles = [
      (
        title: 'New showtimes for saved events',
        value: _newShowtimesEnabled,
        onChanged: (bool v) => setState(() => _newShowtimesEnabled = v),
      ),
      (
        title: 'Price drops',
        value: _priceDropsEnabled,
        onChanged: (bool v) => setState(() => _priceDropsEnabled = v),
      ),
      (
        title: 'Weekly Berlin digest',
        value: _weeklyDigestEnabled,
        onChanged: (bool v) => setState(() => _weeklyDigestEnabled = v),
      ),
    ];

    return Scaffold(
      backgroundColor: CinemaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: CinemaColors.textPrimary),
        title: Text('Profile', style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 20)),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, AppTokens.dockClearance(context)),
        children: [
          const _AccountSection(),
          const SizedBox(height: 24),
          Divider(color: CinemaColors.glassBorder),
          const SizedBox(height: 16),
          Text('Notification preferences', style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            'These toggles are placeholders — nothing is wired up yet.',
            style: CinemaTextStyles.meta,
          ),
          const SizedBox(height: 8),
          ...toggles.map(
            (toggle) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                toggle.title,
                style: CinemaTextStyles.meta.copyWith(color: CinemaColors.textPrimary, fontSize: 14),
              ),
              value: toggle.value,
              activeColor: NSColors.royalBlue,
              onChanged: toggle.onChanged,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: CinemaColors.glassBorder),
          const SizedBox(height: 16),
          Text('Recently viewed', style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            'Reads the offline listing cache (empty until browsing writes to it).',
            style: CinemaTextStyles.meta,
          ),
          const SizedBox(height: 12),
          if (recentlyViewed.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CinemaEmptyState(
                icon: Icons.history,
                title: 'Nothing viewed yet',
                subtitle: 'Events you open will be cached here for offline access.',
              ),
            )
          else
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentlyViewed.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: MoviePosterCard(listing: recentlyViewed[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountSection extends StatefulWidget {
  const _AccountSection();

  @override
  State<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<_AccountSection> {
  bool _isWorking = false;

  Future<void> _signIn() async {
    setState(() => _isWorking = true);
    await ensureSignedIn(context);
    if (mounted) setState(() => _isWorking = false);
  }

  Future<void> _signOut() async {
    setState(() => _isWorking = true);
    await AuthService.signOut();
    if (mounted) setState(() => _isWorking = false);
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = AuthService.isSignedIn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CinemaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CinemaColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                signedIn ? Icons.account_circle : Icons.account_circle_outlined,
                color: NSColors.skyBlue,
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      signedIn ? 'Signed in' : 'Not signed in',
                      style: CinemaTextStyles.cardTitle,
                    ),
                    Text(
                      signedIn
                          ? (AuthService.currentUser?.email ?? '')
                          : 'Sign in to save your watchlist and preferences.',
                      style: CinemaTextStyles.meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          signedIn
              ? CinemaSecondaryButton(
                  label: 'Sign out',
                  isLoading: _isWorking,
                  onPressed: _signOut,
                )
              : NSPrimaryButton(
                  label: 'Sign in',
                  isLoading: _isWorking,
                  onPressed: _signIn,
                ),
        ],
      ),
    );
  }
}
