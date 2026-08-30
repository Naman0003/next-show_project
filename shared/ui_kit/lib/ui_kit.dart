library ui_kit;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:core_models/core_models.dart';

/// NextShow brand colors
class NSColors {
  NSColors._();

  static const Color royalBlue = Color(0xFF2563EB);
  static const Color deepNavy = Color(0xFF0F172A);
  static const Color skyBlue = Color(0xFF60A5FA);
  static const Color iceBlue = Color(0xFFDBEAFE);
  static const Color snowWhite = Color(0xFFFCFCFD);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const List<Color> brandGradient = [royalBlue, skyBlue];
}

/// NextShow text theme
class NSTextStyles {
  static TextStyle get displayLarge => GoogleFonts.manrope(
    fontWeight: FontWeight.w800, color: NSColors.textPrimary, fontSize: 57);
  static TextStyle get displayMedium => GoogleFonts.manrope(
    fontWeight: FontWeight.w800, color: NSColors.textPrimary, fontSize: 45);
  static TextStyle get displaySmall => GoogleFonts.manrope(
    fontWeight: FontWeight.w700, color: NSColors.textPrimary, fontSize: 36);
  static TextStyle get headlineLarge => GoogleFonts.manrope(
    fontWeight: FontWeight.w700, color: NSColors.textPrimary, fontSize: 32);
  static TextStyle get headlineMedium => GoogleFonts.manrope(
    fontWeight: FontWeight.w700, color: NSColors.textPrimary, fontSize: 28);
  static TextStyle get headlineSmall => GoogleFonts.manrope(
    fontWeight: FontWeight.w600, color: NSColors.textPrimary, fontSize: 24);
  static TextStyle get titleLarge => GoogleFonts.manrope(
    fontWeight: FontWeight.w700, color: NSColors.textPrimary, fontSize: 22);
  static TextStyle get titleMedium => GoogleFonts.manrope(
    fontWeight: FontWeight.w600, color: NSColors.textPrimary, fontSize: 16);
  static TextStyle get titleSmall => GoogleFonts.manrope(
    fontWeight: FontWeight.w600, color: NSColors.textPrimary, fontSize: 14);
  static TextStyle get bodyLarge => GoogleFonts.inter(
    color: NSColors.textPrimary, fontSize: 16);
  static TextStyle get bodyMedium => GoogleFonts.inter(
    color: NSColors.textPrimary, fontSize: 14);
  static TextStyle get bodySmall => GoogleFonts.inter(
    color: NSColors.textSecondary, fontSize: 12);
  static TextStyle get labelLarge => GoogleFonts.inter(
    fontWeight: FontWeight.w500, color: NSColors.textPrimary, fontSize: 14);
  static TextStyle get labelMedium => GoogleFonts.inter(
    fontWeight: FontWeight.w500, color: NSColors.textSecondary, fontSize: 12);
  static TextStyle get labelSmall => GoogleFonts.inter(
    fontWeight: FontWeight.w500, color: NSColors.textSecondary, fontSize: 11);
}

/// NextShow theme data
ThemeData get nsTheme => ThemeData.light().copyWith(
  scaffoldBackgroundColor: NSColors.snowWhite,
  primaryColor: NSColors.royalBlue,
  textTheme: GoogleFonts.interTextTheme().copyWith(
    displayLarge: NSTextStyles.displayLarge,
    displayMedium: NSTextStyles.displayMedium,
    displaySmall: NSTextStyles.displaySmall,
    headlineLarge: NSTextStyles.headlineLarge,
    headlineMedium: NSTextStyles.headlineMedium,
    headlineSmall: NSTextStyles.headlineSmall,
    titleLarge: NSTextStyles.titleLarge,
    titleMedium: NSTextStyles.titleMedium,
    titleSmall: NSTextStyles.titleSmall,
    bodyLarge: NSTextStyles.bodyLarge,
    bodyMedium: NSTextStyles.bodyMedium,
    bodySmall: NSTextStyles.bodySmall,
    labelLarge: NSTextStyles.labelLarge,
    labelMedium: NSTextStyles.labelMedium,
    labelSmall: NSTextStyles.labelSmall,
  ),
  colorScheme: ColorScheme.light(
    primary: NSColors.royalBlue,
    secondary: NSColors.skyBlue,
    surface: NSColors.snowWhite,
    error: NSColors.error,
    onPrimary: NSColors.snowWhite,
    onSurface: NSColors.textPrimary,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: NSColors.textPrimary),
    titleTextStyle: GoogleFonts.manrope(
      color: NSColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(color: NSColors.royalBlue),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: NSColors.royalBlue,
      foregroundColor: NSColors.snowWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: NSColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      foregroundColor: NSColors.textPrimary,
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: NSColors.royalBlue,
    side: BorderSide(color: NSColors.border),
    labelStyle: GoogleFonts.inter(color: NSColors.textPrimary),
    secondaryLabelStyle: GoogleFonts.inter(color: NSColors.snowWhite),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  dividerTheme: DividerThemeData(color: NSColors.border),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: NSColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: NSColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: NSColors.royalBlue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: NSColors.error),
    ),
    hintStyle: GoogleFonts.inter(color: NSColors.textSecondary),
  ),
);

/// Scales its child down slightly while pressed, for tactile feedback on
/// buttons and tappable cards. Uses [Listener] (raw pointer events) rather
/// than [GestureDetector] so it never competes in the gesture arena with a
/// wrapped [ElevatedButton]/[InkWell]'s own tap handling.
class NSPressScale extends StatefulWidget {
  const NSPressScale({required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  State<NSPressScale> createState() => _NSPressScaleState();
}

class _NSPressScaleState extends State<NSPressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.enabled && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Category chips for filtering
class NSCategoryFilter extends StatelessWidget {
  final EventCategory? selectedCategory;
  final ValueChanged<EventCategory?> onChanged;
  final List<EventCategory> categories;

  const NSCategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.categories = const [
      EventCategory.movie,
      EventCategory.comedy,
      EventCategory.music,
      EventCategory.theatre,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CategoryChip(
            label: 'All',
            category: null,
            isSelected: selectedCategory == null,
            onTap: () => onChanged(null),
          ),
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _CategoryChip(
              label: _categoryLabel(cat),
              category: cat,
              isSelected: selectedCategory == cat,
              onTap: () => onChanged(cat),
            ),
          )),
        ],
      ),
    );
  }

  String _categoryLabel(EventCategory cat) {
    return cat.name[0].toUpperCase() + cat.name.substring(1);
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final EventCategory? category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: NSColors.royalBlue,
      backgroundColor: NSColors.snowWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? NSColors.royalBlue : NSColors.border,
        ),
      ),
      labelStyle: GoogleFonts.inter(
        color: isSelected ? NSColors.snowWhite : NSColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

/// Event card for browse screen
class NSEventCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;

  const NSEventCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NSPressScale(
      enabled: onTap != null,
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Image.network(
                      listing.imageUrl ?? 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: NSColors.border,
                        child: const Icon(Icons.event, size: 40, color: NSColors.royalBlue),
                      ),
                    ),
                    if (listing.showtimeAttributes['imdb_rating'] != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            listing.showtimeAttributes['imdb_rating'].toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: NSColors.warning,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              listing.eventTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NSTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              _categoryLabel(listing.category),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: NSTextStyles.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              listing.price != null
                  ? '€${listing.price!.toStringAsFixed(2)} onwards'
                  : 'Price TBD',
              style: NSTextStyles.labelMedium.copyWith(
                color: NSColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _categoryLabel(EventCategory cat) {
    return cat.name[0].toUpperCase() + cat.name.substring(1);
  }
}

/// Showtime chip for cinema aggregator
class NSShowtimeChip extends StatelessWidget {
  final String time;
  final String format;
  final double price;
  final VoidCallback? onTap;

  const NSShowtimeChip({
    super.key,
    required this.time,
    required this.format,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: NSColors.royalBlue),
          color: NSColors.snowWhite,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time, style: NSTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.bold, color: NSColors.textPrimary)),
            Text(format, style: NSTextStyles.labelSmall.copyWith(
              color: NSColors.skyBlue)),
            Text('€${price.toStringAsFixed(2)}', style: NSTextStyles.labelSmall.copyWith(
              color: NSColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

/// Cinema card showing venue + showtimes
class NSCinemaCard extends StatelessWidget {
  final String cinemaName;
  final String distance;
  final List<NSShowtimeChip> showtimeChips;
  final VoidCallback? onTap;

  const NSCinemaCard({
    super.key,
    required this.cinemaName,
    required this.distance,
    required this.showtimeChips,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NSColors.snowWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: NSColors.deepNavy.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cinemaName, style: NSTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(distance, style: NSTextStyles.bodySmall.copyWith(
            color: NSColors.success)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: showtimeChips,
          ),
        ],
      ),
    );
  }
}

/// One tab destination for [NSBottomNavBar].
class NSBottomNavBarDestination {
  const NSBottomNavBarDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Glassmorphic bottom navigation bar — a frosted-blur surface over
/// whatever's scrolling beneath it, replacing the stock Material
/// [NavigationBar]. Pair with `Scaffold(extendBody: true, ...)` so page
/// content actually extends behind the bar for the blur to pick up.
class NSBottomNavBar extends StatelessWidget {
  const NSBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NSBottomNavBarDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.6))),
            boxShadow: [
              BoxShadow(
                color: NSColors.deepNavy.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    _NSNavItem(
                      destination: destinations[i],
                      selected: i == selectedIndex,
                      onTap: () => onDestinationSelected(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NSNavItem extends StatelessWidget {
  const _NSNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NSBottomNavBarDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? NSColors.royalBlue : NSColors.textSecondary;

    return NSPressScale(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? NSColors.royalBlue.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? destination.selectedIcon : destination.icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                destination.label,
                style: NSTextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// NextShow logo widget
class NSLogo extends StatelessWidget {
  final double fontSize;

  const NSLogo({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    final iconSize = fontSize * 1.3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The source mark ships with its own solid background, so it's
        // presented as a rounded icon tile rather than composited directly
        // onto the page (which would leave a raw white square on dark
        // screens).
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize * 0.28),
          child: Image.asset(
            'packages/ui_kit/assets/logo_mark.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: fontSize * 0.4),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: NSColors.brandGradient,
          ).createShader(bounds),
          child: Text(
            'NEXT SHOW',
            style: GoogleFonts.manrope(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Primary button
class NSPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const NSPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return NSPressScale(
      enabled: !isLoading && onPressed != null,
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: NSColors.royalBlue,
            foregroundColor: NSColors.snowWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: NSColors.snowWhite),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: NSTextStyles.labelLarge.copyWith(color: NSColors.snowWhite),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary button
class NSSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const NSSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return NSPressScale(
      enabled: !isLoading && onPressed != null,
      child: SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: NSColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: NSColors.royalBlue),
                )
              : Text(label, style: NSTextStyles.labelLarge),
        ),
      ),
    );
  }
}

/// A shimmering placeholder box, for skeleton loading states that mirror the
/// shape of the content they'll be replaced by (rather than a generic
/// centered spinner).
class NSSkeleton extends StatefulWidget {
  const NSSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  final double width;
  final double height;
  final double borderRadius;

  /// Overrides for use on non-light backgrounds. Default to the light-mode
  /// `NSColors` tokens when omitted, so existing callers are unaffected.
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<NSSkeleton> createState() => _NSSkeletonState();
}

class _NSSkeletonState extends State<NSSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? NSColors.border;
    final highlight = widget.highlightColor ?? NSColors.snowWhite;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: base)),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => FractionalTranslation(
                  translation: Offset(_controller.value * 3 - 1.5, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          base.withOpacity(0),
                          highlight.withOpacity(0.9),
                          base.withOpacity(0),
                        ],
                        stops: const [0.35, 0.5, 0.65],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder shaped like a horizontal list-item result card
/// (thumbnail + title + subtitle lines) — for search/list results that are
/// still loading.
class NSListItemSkeleton extends StatelessWidget {
  const NSListItemSkeleton({super.key, this.baseColor, this.highlightColor});

  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NSSkeleton(width: 56, height: 78, borderRadius: 8, baseColor: baseColor, highlightColor: highlightColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NSSkeleton(width: double.infinity, height: 14, baseColor: baseColor, highlightColor: highlightColor),
                const SizedBox(height: 8),
                NSSkeleton(width: double.infinity, height: 12, baseColor: baseColor, highlightColor: highlightColor),
                const SizedBox(height: 6),
                NSSkeleton(width: 120, height: 12, baseColor: baseColor, highlightColor: highlightColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading indicator
class NSLoading extends StatelessWidget {
  final String? message;

  const NSLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: NSColors.royalBlue),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: NSTextStyles.bodyMedium.copyWith(
              color: NSColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Empty state
class NSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const NSEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: NSColors.textSecondary),
            const SizedBox(height: 16),
            Text(title, style: NSTextStyles.headlineSmall, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: NSTextStyles.bodyMedium, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state
class NSErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const NSErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: NSColors.error),
            const SizedBox(height: 16),
            Text(message, style: NSTextStyles.headlineSmall, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              NSPrimaryButton(label: 'Try Again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

/// Status badge for showtimes/events
class NSStatusBadge extends StatelessWidget {
  final EventStatus status;

  const NSStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case EventStatus.draft:
        bgColor = NSColors.warning.withOpacity(0.15);
        textColor = NSColors.warning;
        label = 'Draft';
        break;
      case EventStatus.published:
        bgColor = NSColors.success.withOpacity(0.15);
        textColor = NSColors.success;
        label = 'Published';
        break;
      case EventStatus.cancelled:
        bgColor = NSColors.error.withOpacity(0.15);
        textColor = NSColors.error;
        label = 'Cancelled';
        break;
      case EventStatus.archived:
        bgColor = NSColors.textSecondary.withOpacity(0.15);
        textColor = NSColors.textSecondary;
        label = 'Archived';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: NSTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Venue type badge
class NSVenueTypeBadge extends StatelessWidget {
  final VenueType type;

  const NSVenueTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String label;

    switch (type) {
      case VenueType.cinema:
        icon = Icons.movie;
        label = 'Cinema';
        break;
      case VenueType.club:
        icon = Icons.nightlife;
        label = 'Club';
        break;
      case VenueType.theatre:
        icon = Icons.theater_comedy;
        label = 'Theatre';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: NSColors.royalBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: NSColors.royalBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: NSTextStyles.labelSmall.copyWith(
              color: NSColors.royalBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal segmented toggle: a pill slides behind the active label as the
/// selection changes. For switching between a small number (2–4) of mutually
/// exclusive modes — e.g. Sign In / Sign Up on an auth form.
///
/// Styling defaults to the light `NS` tokens. Pass the optional colour / label
/// overrides to drop it onto a dark surface:
///
/// ```dart
/// NSSegmentedToggle(
///   segments: const ['SIGN IN', 'SIGN UP'],
///   selectedIndex: mode.index,
///   onChanged: (i) => setState(() => mode = AuthMode.values[i]),
///   thumbColor: NsxColors.accent,
///   trackColor: NsxColors.glassFill,
///   borderRadius: 2,
/// )
/// ```
class NSSegmentedToggle extends StatelessWidget {
  const NSSegmentedToggle({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.trackColor,
    this.thumbColor,
    this.borderColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.borderRadius = 12,
    this.height = 44,
    this.padding = const EdgeInsets.all(4),
  }) : assert(segments.length >= 2, 'NSSegmentedToggle needs at least 2 segments');

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Track fill behind the segments. Defaults to a faint ice-blue wash.
  final Color? trackColor;

  /// The sliding pill behind the active label. Defaults to [NSColors.royalBlue].
  final Color? thumbColor;

  /// Optional 1px border around the track.
  final Color? borderColor;

  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final double borderRadius;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final track = trackColor ?? NSColors.iceBlue.withOpacity(0.4);
    final thumb = thumbColor ?? NSColors.royalBlue;
    final selStyle = selectedLabelStyle ??
        NSTextStyles.labelLarge.copyWith(
          color: NSColors.snowWhite,
          fontWeight: FontWeight.w700,
        );
    final unselStyle = unselectedLabelStyle ??
        NSTextStyles.labelLarge.copyWith(color: NSColors.textSecondary);

    final count = segments.length;
    final index = selectedIndex.clamp(0, count - 1);
    final innerRadius =
        (borderRadius - padding.top).clamp(0.0, borderRadius).toDouble();
    final thumbHeight = height - padding.vertical;

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: track,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumbWidth = constraints.maxWidth / count;
          return Stack(
            children: [
              AnimatedAlign(
                alignment: Alignment(
                  count == 1 ? 0 : (index / (count - 1)) * 2 - 1,
                  0,
                ),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: thumbWidth,
                  height: thumbHeight,
                  decoration: BoxDecoration(
                    color: thumb,
                    borderRadius: BorderRadius.circular(innerRadius),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: NSPressScale(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: i == index ? selStyle : unselStyle,
                              child: Text(
                                segments[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}