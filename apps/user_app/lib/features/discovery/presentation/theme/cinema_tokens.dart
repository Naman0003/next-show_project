import 'package:flutter/widgets.dart';

/// Design tokens for the Discovery, Search, Watchlist and Profile surfaces.
/// Originally the dark "Marquee After Dark" palette; now light, matched to
/// `AppColors` so every screen in the app shares one light look. Not wired
/// into `MaterialApp.theme`.
///
/// One accent ([NsxColors.accent]) carries the live/selected state and
/// nothing else — no rainbow category colors, no gradient surfaces.
class NsxColors {
  NsxColors._();

  /// Off-white canvas (AppColors.lightCanvas). The whole surface sits on this.
  static const Color ground = Color(0xFFF8F9FA);

  /// Raised panels (cards, poster fallbacks, skeletons).
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHi = Color(0xFFF1F3F5);

  /// 1px borders and dividers.
  static const Color hairline = Color(0xFFE5E7EB);

  /// Primary ink. The name is kept from the dark palette, where it was a
  /// bone white; it's now near-black (AppColors.textPrimary).
  static const Color bone = Color(0xFF111827);

  /// Secondary ink for mono metadata and captions. Meets 4.5:1 on [ground].
  static const Color muted = Color(0xFF6B7280);

  /// The single accent (royal blue, matching the logo and switches). Used
  /// only for the current / selected / live state.
  static const Color accent = Color(0xFF2563EB);

  /// Ink that sits on top of an [accent] fill.
  static const Color accentInk = Color(0xFFFFFFFF);

  /// Glass fill + border, tuned for [BackdropFilter] over the light ground.
  static const Color glassFill = Color(0xB3FFFFFF); // white @ 70%
  static const Color glassBorder = Color(0x14111827); // ink @ ~8%

  /// Shimmer sweep for loading skeletons.
  static const Color shimmer = Color(0xFFE9ECEF);
}

/// Font family names — registered in `pubspec.yaml` against the bundled
/// variable TTFs, so type is exact and offline-safe (no `google_fonts`
/// runtime fetch).
class NsxFonts {
  NsxFonts._();
  static const String display = 'Bricolage Grotesque';
  static const String mono = 'Martian Mono';
}

/// Two voices, held far apart on purpose: a monumental grotesque for display,
/// a tight technical monospace for every label, tag, and metadata run. The
/// small amount of running copy (venue names, descriptions) uses the display
/// family at regular weight rather than adding a third face.
class NsxType {
  NsxType._();

  static const List<FontVariation> _w400 = [FontVariation('wght', 400)];
  static const List<FontVariation> _w500 = [FontVariation('wght', 500)];
  static const List<FontVariation> _w600 = [FontVariation('wght', 600)];
  static const List<FontVariation> _w700 = [FontVariation('wght', 700)];
  static const List<FontVariation> _w800 = [FontVariation('wght', 800)];

  /// The monumental title on the spotlight anchor. Caller sizes down on
  /// narrow screens / long strings via [TextStyle.copyWith].
  static const TextStyle displayXl = TextStyle(
    fontFamily: NsxFonts.display,
    fontVariations: _w800,
    fontWeight: FontWeight.w800,
    color: NsxColors.bone,
    fontSize: 44,
    height: 0.98,
    letterSpacing: -1.6,
  );

  /// Section headings ("Now Showing").
  static const TextStyle display = TextStyle(
    fontFamily: NsxFonts.display,
    fontVariations: _w800,
    fontWeight: FontWeight.w800,
    color: NsxColors.bone,
    fontSize: 26,
    height: 1.02,
    letterSpacing: -0.9,
  );

  /// Card titles.
  static const TextStyle title = TextStyle(
    fontFamily: NsxFonts.display,
    fontVariations: _w700,
    fontWeight: FontWeight.w700,
    color: NsxColors.bone,
    fontSize: 17,
    height: 1.1,
    letterSpacing: -0.4,
  );

  /// The workhorse mono label: category tags, "VIEW ALL", nav labels.
  /// Author copy in the case you want it — these do not force-uppercase.
  static const TextStyle mono = TextStyle(
    fontFamily: NsxFonts.mono,
    fontVariations: _w500,
    fontWeight: FontWeight.w500,
    color: NsxColors.bone,
    fontSize: 11,
    height: 1.3,
    letterSpacing: 0.8,
  );

  /// Smallest mono — the location/freshness strip, page counters.
  static const TextStyle monoTiny = TextStyle(
    fontFamily: NsxFonts.mono,
    fontVariations: _w600,
    fontWeight: FontWeight.w600,
    color: NsxColors.muted,
    fontSize: 9.5,
    height: 1.3,
    letterSpacing: 1.0,
  );

  /// Running copy — venue names, one-line descriptions.
  static const TextStyle text = TextStyle(
    fontFamily: NsxFonts.display,
    fontVariations: _w400,
    fontWeight: FontWeight.w400,
    color: NsxColors.bone,
    fontSize: 14,
    height: 1.45,
  );

  static const TextStyle textMuted = TextStyle(
    fontFamily: NsxFonts.display,
    fontVariations: _w400,
    fontWeight: FontWeight.w400,
    color: NsxColors.muted,
    fontSize: 13,
    height: 1.4,
  );

  /// Non-const so callers can still tweak; exposes the semibold display weight
  /// for the rare mid-emphasis run.
  static TextStyle get textStrong =>
      text.copyWith(fontVariations: _w600, fontWeight: FontWeight.w600);
}

/// 4pt base spacing scale. Tight groups, generous separation.
class NsxSpace {
  NsxSpace._();
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x7 = 32;
  static const double x8 = 48;

  /// Page gutter.
  static const double gutter = 20;

  /// Clearance the floating dock needs at the bottom of a scroll view.
  static const double dockClearance = 108;
}
