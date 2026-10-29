import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../widgets/tap_scale_container.dart';
import '../../watchlist/application/watchlist_controller.dart';

/// Live Event Details Screen styled with the Home Screen's clean light UI kit
/// (AppColors.lightCanvas, surfaceWhite, darkPrimary) and conforming to details.png blueprint.
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
      backgroundColor: AppColors.lightCanvas,
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
                    final controller =
                        ref.read(watchlistControllerProvider.notifier);
                    if (isSaved) {
                      await controller.remove(listing.showtimeId);
                    } else {
                      await controller.add(listing);
                    }
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
                  offset: const Offset(0, -18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTokens.radiusCard),
                      ),
                      border:
                          Border.all(color: AppColors.borderLight, width: 1),
                      boxShadow: AppTokens.cardShadow,
                    ),
                    padding: EdgeInsets.fromLTRB(20, 16, 20,
                        120 + MediaQuery.of(context).padding.bottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtle sheet drag handle
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppColors.borderLight,
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
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),

                        // Optional Tagline
                        if (listing.showtimeAttributes['tagline'] != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            listing.showtimeAttributes['tagline'].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Date & time, e.g. "Sat, 31 Oct, 8:00 PM"
                        Text(
                          DateFormat('EEE, d MMM, h:mm a')
                              .format(listing.startTime),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Schedule row (Date & Doors, Showtime / Duration)
                        _ScheduleMetaRow(listing: listing),

                        const SizedBox(height: 14),

                        // Venue row -> details sheet (no map)
                        _VenueRow(listing: listing),

                        const SizedBox(height: 18),

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
          // Hero Poster Image with matching Hero tag
          Hero(
            tag: 'event-img-${listing.eventId}',
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.surfaceSecondary,
                child: const Center(
                  child: Icon(
                    Icons.music_note,
                    color: AppColors.textMuted,
                    size: 56,
                  ),
                ),
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
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
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
                    Colors.black.withValues(alpha: 0.4),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button (matching details.png & home screen theme)
                    _CircularFrostedButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                      semanticLabel: 'Back',
                    ),

                    // Right actions: Bookmark & Share
                    Row(
                      children: [
                        _CircularFrostedButton(
                          icon: isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          iconColor:
                              isSaved ? AppColors.heartRed : Colors.white,
                          backgroundColor: isSaved
                              ? AppColors.heartRed.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.35),
                          borderColor: isSaved
                              ? AppColors.heartRed
                              : Colors.white.withValues(alpha: 0.4),
                          onTap: onSave,
                          semanticLabel:
                              isSaved ? 'Saved' : 'Save to Watchlist',
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
    this.iconColor = Colors.white,
    this.backgroundColor,
    this.borderColor,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: TapScaleContainer(
        onTap: onTap,
        scaleDown: 0.85,
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor ?? Colors.white.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Center(
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
    final isFree = listing.price == null || listing.price == 0;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        // Category pill (Dark Primary - bold signature)
        _TagBadge(
          label: listing.category.name.toUpperCase(),
          isPrimary: true,
        ),

        // Genre pill if available
        if (genre != null && genre.isNotEmpty) _TagBadge(label: genre),

        // Venue Type pill
        _TagBadge(label: listing.venueType.name.toUpperCase()),

        // Age restriction pill
        _TagBadge(label: ageRating),

        // Free chip if free
        if (isFree)
          _TagBadge(
            label: 'FREE',
            textColor: AppColors.neonGreen,
            backgroundColor: AppColors.neonGreen.withValues(alpha: 0.12),
            borderColor: AppColors.neonGreen.withValues(alpha: 0.35),
          ),

        // Live Rating badge if available
        if (rating != null)
          _TagBadge(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
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
    this.isPrimary = false,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool isPrimary;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (isPrimary ? AppColors.darkPrimary : AppColors.surfaceSecondary);
    final fgColor =
        textColor ?? (isPrimary ? Colors.white : AppColors.textPrimary);
    final bdrColor =
        borderColor ?? (isPrimary ? Colors.transparent : AppColors.borderLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(color: bdrColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? fgColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w700,
              letterSpacing: isPrimary ? 0.6 : 0.2,
              color: fgColor,
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
    // Time only — the date sits in its own line under the title.
    final time = DateFormat('h:mm a');
    final doorsStr = time.format(listing.startTime);

    // Showtime / end time / duration formatting: e.g. "7:30 PM" or "2h 30m"
    String timeOrDuration;
    if (listing.durationMinutes != null && listing.durationMinutes! > 0) {
      final hours = listing.durationMinutes! ~/ 60;
      final minutes = listing.durationMinutes! % 60;
      timeOrDuration = hours > 0
          ? (minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h')
          : '$minutes min';
    } else if (listing.endTime != null) {
      timeOrDuration = time.format(listing.endTime!);
    } else {
      final showTime = listing.startTime.add(const Duration(minutes: 30));
      timeOrDuration = time.format(showTime);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppTokens.radiusButton),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Calendar Item
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: AppColors.darkPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'DOORS OPEN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doorsStr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 28,
            width: 1,
            color: AppColors.borderLight,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),

          // Clock / Duration Item
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    size: 15,
                    color: AppColors.darkPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SHOWTIME',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeOrDuration,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
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
        const Text(
          'About Event',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          secondChild: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.darkPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VENUE ROW & DETAILS SHEET
// ─────────────────────────────────────────────────────────────────────────────

/// Venue helpers shared by the row and its details sheet.
extension on Listing {
  /// `v_listings` returns null coordinates for venues without a location,
  /// which the shared client maps to 0,0 — a pin in the Atlantic. Treat that
  /// (and anything out of range) as "no location": directions then search by
  /// address instead.
  bool get hasVenueLocation =>
      !(latitude == 0 && longitude == 0) &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180;

  String get venueTypeLabel => switch (venueType) {
        VenueType.cinema => 'Cinema',
        VenueType.club => 'Club',
        VenueType.theatre => 'Theatre',
      };

  Uri get directionsUri {
    final query = hasVenueLocation
        ? '$latitude,$longitude'
        : Uri.encodeComponent(venueAddress ?? venueName);
    return Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
  }
}

/// Compact venue row; tapping it opens [_VenueDetailsSheet].
class _VenueRow extends StatelessWidget {
  const _VenueRow({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return TapScaleContainer(
      onTap: () => _VenueDetailsSheet.show(context, listing),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 22,
                color: AppColors.darkPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.venueName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    listing.venueAddress ?? listing.venueTypeLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with the venue card, full address and actions: directions,
/// copy address, share.
class _VenueDetailsSheet extends StatelessWidget {
  const _VenueDetailsSheet({required this.listing});

  final Listing listing;

  static Future<void> show(BuildContext context, Listing listing) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _VenueDetailsSheet(listing: listing),
    );
  }

  String get _address => listing.venueAddress ?? listing.venueName;

  Future<void> _directions() async {
    final uri = listing.directionsUri;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copyAddress(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _address));
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Address copied')),
    );
  }

  void _share() {
    Share.share(
      '${listing.venueName}\n$_address\n${listing.directionsUri}',
      subject: listing.venueName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = listing.venueImageUrl;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Venue details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _SheetIconButton(
                  icon: Icons.close_rounded,
                  semanticLabel: 'Close',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Venue card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: image != null
                          ? CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const _VenueIcon(),
                            )
                          : const _VenueIcon(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.venueName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listing.venueTypeLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Full address
            Text(
              _address,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),

            // Actions
            Row(
              children: [
                TapScaleContainer(
                  onTap: _directions,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_rounded,
                            size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Get directions',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _SheetIconButton(
                  icon: Icons.copy_rounded,
                  semanticLabel: 'Copy address',
                  size: 50,
                  onTap: () => _copyAddress(context),
                ),
                const SizedBox(width: 12),
                _SheetIconButton(
                  icon: Icons.ios_share_rounded,
                  semanticLabel: 'Share venue',
                  size: 50,
                  onTap: _share,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VenueIcon extends StatelessWidget {
  const _VenueIcon();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceWhite,
      child: Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 28,
          color: AppColors.darkPrimary,
        ),
      ),
    );
  }
}

class _SheetIconButton extends StatelessWidget {
  const _SheetIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.size = 40,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: TapScaleContainer(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Icon(icon, size: size * 0.42, color: AppColors.darkPrimary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STICKY BOTTOM ACTION BAR (MATCHING DETAILS.PNG & HOME SCREEN UI KIT)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    // Format price: e.g. "$1,250" or "$11" or "Free"
    final bool isFree = listing.price == null || listing.price == 0;
    final String formattedPrice;
    if (!isFree) {
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
            color: AppColors.surfaceWhite.withValues(alpha: 0.96),
            border: const Border(
              top: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.of(context).padding.bottom,
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
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color:
                          isFree ? AppColors.neonGreen : AppColors.textPrimary,
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
    return TapScaleContainer(
      onTap: onTap,
      scaleDown: 0.96,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkPrimary,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkPrimary.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 4),

            // Button label
            const Text(
              'Buy a ticket',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),

            // Embedded circular ticket badge (matching details.png)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.confirmation_number_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
