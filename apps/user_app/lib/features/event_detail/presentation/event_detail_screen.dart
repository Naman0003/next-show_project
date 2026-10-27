import 'dart:ui' as ui;

import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../auth/presentation/split_auth_screen.dart';
import '../../discovery/presentation/theme/cinema_tokens.dart';
import '../../watchlist/application/watchlist_controller.dart';

/// Redesigned Live Event Details Screen adhering to the blueprint in details.png
/// and the app's "Marquee After Dark" dark aesthetic.
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.listing});

  final Listing listing;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final isSaved = ref
        .watch(watchlistControllerProvider)
        .any((l) => l.showtimeId == listing.showtimeId);

    return Scaffold(
      backgroundColor: NsxColors.ground,
      body: Stack(
        children: [
          // Scrollable content area
          CustomScrollView(
            slivers: [
              // Hero Image with floating actions
              SliverToBoxAdapter(
                child: _HeroBanner(
                  listing: listing,
                  isSaved: isSaved,
                  onSave: () async {
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
                ),
              ),

              // Content Sheet
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: NsxColors.ground,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      border: Border.all(color: NsxColors.hairline.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 16,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtle sheet drag handle
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 22),
                            decoration: BoxDecoration(
                              color: NsxColors.muted.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Live category / genre badge pills with breathing room
                        _EventBadgesRow(listing: listing),
                        const SizedBox(height: 14),

                        // Event Title
                        Text(
                          listing.eventTitle,
                          style: const TextStyle(
                            fontFamily: NsxFonts.display,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: NsxColors.bone,
                            height: 1.15,
                          ),
                        ),

                        // Optional Tagline
                        if (listing.showtimeAttributes['tagline'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            listing.showtimeAttributes['tagline'].toString(),
                            style: const TextStyle(
                              fontFamily: NsxFonts.display,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: NsxColors.muted,
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // Schedule row (Date & Doors, Showtime / Duration)
                        _ScheduleMetaRow(listing: listing),

                        const SizedBox(height: 20),

                        // Expandable Description
                        _ExpandableDescription(
                          description: listing.eventDescription ??
                              'Join us for a spectacular live performance featuring incredible talent, energetic stage production, and an unforgettable evening at ${listing.venueName}.',
                          isExpanded: _isDescriptionExpanded,
                          onToggle: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                          },
                        ),

                        const SizedBox(height: 28),

                        // Venue info & Map section
                        _VenueMapSection(listing: listing),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Sticky bottom action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActionBar(listing: listing),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.listing,
    required this.isSaved,
    required this.onSave,
    required this.onShare,
  });

  final Listing listing;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = (screenHeight * 0.44).clamp(320.0, 460.0);
    final imageUrl = listing.imageUrl ??
        'https://picsum.photos/seed/${listing.eventId}/900/1400';

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero Poster Image
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: NsxColors.surface,
              child: const Center(
                child: Icon(Icons.music_note, color: NsxColors.muted, size: 56),
              ),
            ),
          ),

          // Top gradient scrim for floating buttons
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Bottom subtle vignette
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          // Top action buttons bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button (matching details.png)
                    _CircularFrostedButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                      semanticLabel: 'Back',
                    ),

                    // Right actions: Bookmark & Share
                    Row(
                      children: [
                        _CircularFrostedButton(
                          icon: isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                          iconColor: isSaved ? NsxColors.accent : NsxColors.bone,
                          onTap: onSave,
                          semanticLabel: isSaved ? 'Saved' : 'Save to Watchlist',
                        ),
                        const SizedBox(width: 10),
                        _CircularFrostedButton(
                          icon: Icons.ios_share_rounded,
                          onTap: onShare,
                          semanticLabel: 'Share',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularFrostedButton extends StatelessWidget {
  const _CircularFrostedButton({
    required this.icon,
    required this.onTap,
    this.iconColor = NsxColors.bone,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.black.withValues(alpha: 0.38),
            shape: CircleBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
            ),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 42,
                height: 42,
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGES / TAGS ROW
// ─────────────────────────────────────────────────────────────────────────────

class _EventBadgesRow extends StatelessWidget {
  const _EventBadgesRow({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final genre = listing.showtimeAttributes['genre'] as String?;
    final rating = listing.showtimeAttributes['imdb_rating'] as num?;
    final ageRating = listing.eventMetadata['age_rating'] as String? ?? '18+';

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        // Category pill
        _TagBadge(
          label: listing.category.name.toUpperCase(),
          accent: true,
        ),

        // Genre pill if available
        if (genre != null && genre.isNotEmpty)
          _TagBadge(label: genre),

        // Venue Type pill
        _TagBadge(label: listing.venueType.name.toUpperCase()),

        // Age restriction pill
        _TagBadge(label: ageRating),

        // Live Rating badge if available
        if (rating != null)
          _TagBadge(
            icon: Icons.star_rounded,
            iconColor: NsxColors.accent,
            label: rating.toStringAsFixed(1),
          ),
      ],
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({
    required this.label,
    this.icon,
    this.iconColor,
    this.accent = false,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent ? NsxColors.accent.withValues(alpha: 0.14) : NsxColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent ? NsxColors.accent.withValues(alpha: 0.5) : NsxColors.hairline,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? NsxColors.bone),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: NsxFonts.mono,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: accent ? NsxColors.accent : NsxColors.bone,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCHEDULE ROW (CALENDAR & CLOCK - MATCHING DETAILS.PNG)
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleMetaRow extends StatelessWidget {
  const _ScheduleMetaRow({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    // Date formatting: e.g. "12 October, 7pm"
    final dateStr = DateFormat('d MMMM, ha').format(listing.startTime).toLowerCase();
    
    // Showtime / end time / duration formatting: e.g. "7:30pm" or "180 min"
    String timeOrDuration;
    if (listing.durationMinutes != null && listing.durationMinutes! > 0) {
      final hours = listing.durationMinutes! ~/ 60;
      final minutes = listing.durationMinutes! % 60;
      timeOrDuration = hours > 0
          ? (minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h')
          : '$minutes min';
    } else if (listing.endTime != null) {
      timeOrDuration = DateFormat('ha').format(listing.endTime!).toLowerCase();
    } else {
      // Default live show start offset or fallback
      final showTime = listing.startTime.add(const Duration(minutes: 30));
      timeOrDuration = DateFormat('h:mma').format(showTime).toLowerCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: NsxColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NsxColors.hairline),
      ),
      child: Row(
        children: [
          // Calendar Item
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: NsxColors.accent,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    dateStr,
                    style: const TextStyle(
                      fontFamily: NsxFonts.mono,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NsxColors.bone,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 20,
            width: 1,
            color: NsxColors.hairline,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),

          // Clock / Duration Item
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: NsxColors.accent,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    timeOrDuration,
                    style: const TextStyle(
                      fontFamily: NsxFonts.mono,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NsxColors.bone,
                    ),
                    overflow: TextOverflow.ellipsis,
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
// EXPANDABLE DESCRIPTION (MATCHING DETAILS.PNG)
// ─────────────────────────────────────────────────────────────────────────────

class _ExpandableDescription extends StatelessWidget {
  const _ExpandableDescription({
    required this.description,
    required this.isExpanded,
    required this.onToggle,
  });

  final String description;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: NsxFonts.display,
              fontSize: 15,
              height: 1.5,
              color: NsxColors.muted,
            ),
          ),
          secondChild: Text(
            description,
            style: const TextStyle(
              fontFamily: NsxFonts.display,
              fontSize: 15,
              height: 1.5,
              color: NsxColors.muted,
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 240),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExpanded ? 'Read Less' : 'Read More',
                style: const TextStyle(
                  fontFamily: NsxFonts.display,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NsxColors.bone,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: NsxColors.bone,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VENUE LOCATION & MINI MAP PREVIEW
// ─────────────────────────────────────────────────────────────────────────────

class _VenueMapSection extends StatelessWidget {
  const _VenueMapSection({required this.listing});

  final Listing listing;

  Future<void> _launchDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${listing.latitude},${listing.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final point = LatLng(listing.latitude, listing.longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Venue Title & Address
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.venueName,
                    style: const TextStyle(
                      fontFamily: NsxFonts.display,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: NsxColors.bone,
                    ),
                  ),
                  if (listing.venueAddress != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      listing.venueAddress!,
                      style: const TextStyle(
                        fontFamily: NsxFonts.mono,
                        fontSize: 12,
                        color: NsxColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            InkWell(
              onTap: _launchDirections,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.directions_outlined, size: 16, color: NsxColors.accent),
                    SizedBox(width: 4),
                    Text(
                      'Directions',
                      style: TextStyle(
                        fontFamily: NsxFonts.mono,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NsxColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Mini Map Card (matching details.png)
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: NsxColors.hairline),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 14.2,
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
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: NsxColors.ground,
                              shape: BoxShape.circle,
                              border: Border.all(color: NsxColors.accent, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.music_note,
                                color: NsxColors.accent,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Tap overlay to open directions
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _launchDirections,
                      splashColor: Colors.white10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STICKY BOTTOM ACTION BAR (MATCHING DETAILS.PNG)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    // Format price: e.g. "$1,250" or "$11" or "Free"
    final String formattedPrice;
    if (listing.price != null && listing.price! > 0) {
      final formatter = NumberFormat.currency(
        symbol: '\$',
        decimalDigits: listing.price! % 1 == 0 ? 0 : 2,
      );
      formattedPrice = formatter.format(listing.price);
    } else {
      formattedPrice = 'Free';
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: NsxColors.ground.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(color: NsxColors.hairline.withValues(alpha: 0.8), width: 1),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            14 + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: [
              // Left: "From" label & Price
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'From',
                    style: TextStyle(
                      fontFamily: NsxFonts.mono,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: NsxColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      fontFamily: NsxFonts.display,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: NsxColors.bone,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 24),

              // Right: Big "Buy a ticket" pill button with right badge icon
              Expanded(
                child: _BuyTicketPillButton(
                  onTap: () => BookingWebViewRoute(
                    url: listing.bookingUrl,
                    eventTitle: listing.eventTitle,
                  ).push(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuyTicketPillButton extends StatelessWidget {
  const _BuyTicketPillButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Ink(
          decoration: BoxDecoration(
            color: NsxColors.accent,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: NsxColors.accent.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 8),

                // Button label
                Text(
                  'Buy a ticket',
                  style: TextStyle(
                    fontFamily: NsxFonts.display,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: NsxColors.accentInk,
                  ),
                ),

                // Embedded circular ticket badge (matching details.png)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: NsxColors.accentInk,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Center(
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        size: 20,
                        color: NsxColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
