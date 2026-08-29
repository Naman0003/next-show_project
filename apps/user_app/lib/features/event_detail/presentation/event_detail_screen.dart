import 'package:core_models/core_models.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/router/app_router.dart';
import '../../auth/presentation/login_screen.dart';
import '../../discovery/presentation/cinema_theme.dart';
import '../../watchlist/application/watchlist_controller.dart';

/// Phase 3 scaffold: real trailer/map/booking wiring, mocked event data.
/// TODO(phase-5): replace [_placeholderTrailerId] with the real trailer id
/// once event metadata carries one from Supabase.
const _placeholderTrailerId = 'dQw4w9WgXcQ';

/// `youtube_player_flutter` embeds via `flutter_inappwebview`, which only
/// declares Android/iOS platform support — it has no web (or desktop)
/// implementation, so building it there throws. Everywhere else falls back
/// to a tap-to-open-externally card.
bool get _supportsInlineTrailer =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.listing});

  final Listing listing;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    if (_supportsInlineTrailer) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: _placeholderTrailerId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final isSaved = ref
        .watch(watchlistControllerProvider)
        .any((l) => l.showtimeId == listing.showtimeId);

    return Scaffold(
      backgroundColor: CinemaColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: CinemaColors.textPrimary),
        title: Text(
          listing.eventTitle,
          style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        children: [
          _supportsInlineTrailer
              ? YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: NSColors.royalBlue,
                )
              : _TrailerFallback(listing: listing),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.eventTitle, style: CinemaTextStyles.spotlightTitle),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _VenueTypeBadge(type: listing.venueType),
                    const SizedBox(width: 8),
                    Text(listing.venueName, style: CinemaTextStyles.meta),
                  ],
                ),
                if (listing.eventDescription != null) ...[
                  const SizedBox(height: 14),
                  Text(listing.eventDescription!, style: CinemaTextStyles.body),
                ],
                const SizedBox(height: 22),
                _MicroInteractions(
                  isSaved: isSaved,
                  onSave: () async {
                    // Saving is per-account (Phase 5+ syncs the watchlist
                    // to Supabase), so it needs identity even though the
                    // local Hive write itself doesn't.
                    final signedIn = await ensureSignedIn(context);
                    if (!signedIn || !mounted) return;
                    await ref
                        .read(watchlistControllerProvider.notifier)
                        .add(listing);
                  },
                  onShare: () => Share.share(
                    'Check out ${listing.eventTitle} at ${listing.venueName} on NextShow: ${listing.bookingUrl}',
                    subject: listing.eventTitle,
                  ),
                  onNotify: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications are coming in a later phase.'),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text('Location', style: CinemaTextStyles.sectionHeader.copyWith(fontSize: 18)),
                const SizedBox(height: 10),
                _VenueMap(listing: listing),
                const SizedBox(height: 26),
                NSPrimaryButton(
                  label: 'Book Now',
                  icon: Icons.confirmation_number_outlined,
                  onPressed: () => BookingWebViewRoute(
                    url: listing.bookingUrl,
                    eventTitle: listing.eventTitle,
                  ).push(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailerFallback extends StatelessWidget {
  const _TrailerFallback({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse('https://www.youtube.com/watch?v=$_placeholderTrailerId'),
        mode: LaunchMode.externalApplication,
      ),
      child: Container(
        height: 200,
        width: double.infinity,
        color: CinemaColors.surfaceElevated,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (listing.imageUrl != null)
              Opacity(
                opacity: 0.5,
                child: Image.network(listing.imageUrl!, fit: BoxFit.cover),
              ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Text(
                'Trailer preview • opens on YouTube',
                style: CinemaTextStyles.meta.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dark-theme venue type badge (the shared `NSVenueTypeBadge` targets
/// light-mode contrast) — reuses [CinemaGlassBadge] for the frosted look
/// already established on Discovery/Search.
class _VenueTypeBadge extends StatelessWidget {
  const _VenueTypeBadge({required this.type});

  final VenueType type;

  static const _labels = {
    VenueType.cinema: 'Cinema',
    VenueType.club: 'Club',
    VenueType.theatre: 'Theatre',
  };

  static const _icons = {
    VenueType.cinema: Icons.movie,
    VenueType.club: Icons.nightlife,
    VenueType.theatre: Icons.theater_comedy,
  };

  @override
  Widget build(BuildContext context) {
    return CinemaGlassBadge(
      icon: _icons[type],
      iconColor: NSColors.skyBlue,
      label: _labels[type]!,
    );
  }
}

class _MicroInteractions extends StatelessWidget {
  const _MicroInteractions({
    required this.isSaved,
    required this.onSave,
    required this.onShare,
    required this.onNotify,
  });

  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onNotify;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChip(
            icon: isSaved ? Icons.bookmark : Icons.bookmark_add_outlined,
            label: isSaved ? 'Saved' : 'Save',
            onTap: isSaved ? null : onSave,
            highlighted: isSaved,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionChip(icon: Icons.ios_share, label: 'Share', onTap: onShare),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionChip(icon: Icons.notifications_none, label: 'Notify', onTap: onNotify),
        ),
      ],
    );
  }
}

/// Dark-theme action pill — the previous `OutlinedButton.icon`s pulled their
/// colors from the app's global light `ThemeData`, so on this dark screen
/// they'd have rendered as near-invisible dark-on-dark text and a faint
/// border. This is explicitly themed instead.
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? NSColors.skyBlue : CinemaColors.textPrimary;

    return NSPressScale(
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: highlighted ? NSColors.royalBlue.withOpacity(0.16) : CinemaColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlighted ? NSColors.royalBlue : CinemaColors.glassBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: CinemaTextStyles.meta.copyWith(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VenueMap extends StatelessWidget {
  const _VenueMap({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(listing.latitude, listing.longitude);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CinemaColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.nextshow.user_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: NSColors.royalBlue,
                    size: 36,
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
