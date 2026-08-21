library ui_kit;

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
    return GestureDetector(
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
        border: Border.all(color: NSColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
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

/// NextShow logo widget
class NSLogo extends StatelessWidget {
  final double fontSize;

  const NSLogo({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
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
    return SizedBox(
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
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: NSTextStyles.labelLarge),
                ],
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
    return SizedBox(
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