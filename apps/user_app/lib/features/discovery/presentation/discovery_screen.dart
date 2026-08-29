import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_discovery_data_source.dart';
import 'theme/cinema_tokens.dart';
import 'widgets/category_strip.dart';
import 'widgets/glass.dart';
import 'widgets/monumental_spotlight.dart';
import 'widgets/now_showing_rail.dart';
import 'widgets/spring_tap.dart';
import 'cinema_theme.dart' show CinemaWordmark;

// ─────────────────────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — "Marquee After Dark"  (brief-pinned; concept-seed skipped
// per new-work.md §3: precisely specified request + reference image.)
//
// THESIS: Berlin's night program as a cinema marquee after dark — one
//   monumental, processed title fills the screen, everything else is precise
//   mono signage. Refuses the scrollable grid of same-size event cards and the
//   rainbow category row.
// OWN-WORLD: Warm near-black ground (#0B0B0C), bone-white ink (#EDE9E1), a
//   single amber accent (#FFA424) for the live/selected state only. Monumental
//   grotesque display (Bricolage Grotesque) against tight technical monospace
//   (Martian Mono) for every label; hard-edged 1px neo-brutalist tags; frosted
//   glass pills with a crisp inner border + top inner-glow. Imagery is always
//   duotone + grain + linework, never raw. No gradients as surface.
// STORY: Land facing tonight's single strongest pick at full scale; read
//   runtime / language / price as mono signage in one glance; swipe the 3
//   spotlight picks; narrow by category; scan "Now Showing"; tap through to book.
// FIRST VIEWPORT: Wordmark top-left, glass bell top-right; a "BERLIN · TONIGHT"
//   mono strip; a frosted glass search row; then the spotlight anchor filling
//   ~46% of height — processed poster, glass bookmark top-right, and a
//   bottom-anchored marquee block (mono category tag, huge 2–3 line display
//   title, one mono metadata row, page dots). The floating amber-lit glass
//   dock hovers over the bottom.
// FORM: Cinema marquee / repertory-house signage. Not seeded — brief-pinned.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, DESIGN.md, and every shipping raster carrying
//   its provenance.
// ─────────────────────────────────────────────────────────────────────────────

/// NextShow's Discovery homepage. Dark, scoped to this screen (the rest of the
/// app stays on `ui_kit`'s light theme). The category strip filters the mock
/// spotlight + "Now Showing" data locally; nothing here talks to Supabase yet.
class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  static const _dataSource = MockDiscoveryDataSource();

  EventCategory? _selectedCategory;

  List<Listing> _filter(List<Listing> listings) {
    final category = _selectedCategory;
    if (category == null) return listings;
    return listings.where((l) => l.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spotlight = _filter(_dataSource.getSpotlight());
    final nowShowing = _filter(_dataSource.getNowShowing());
    final spotlightHeight =
        (MediaQuery.sizeOf(context).height * 0.46).clamp(320.0, 460.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: NsxColors.ground,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      NsxSpace.gutter, NsxSpace.x3, NsxSpace.gutter, 0),
                  child: Row(
                    children: [
                      const CinemaWordmark(fontSize: 20),
                      const Spacer(),
                      GlassIconButton(
                        icon: Icons.notifications_none,
                        semanticLabel: 'Notifications',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    NsxSpace.gutter, NsxSpace.x3, NsxSpace.gutter, NsxSpace.x4),
                child: Text('BERLIN  ·  TONIGHT', style: NsxType.monoTiny),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    NsxSpace.gutter, 0, NsxSpace.gutter, NsxSpace.x5),
                child: SpringTap(
                  haptic: true,
                  onTap: () => context.go('/search'),
                  child: GlassSurface(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(
                        horizontal: NsxSpace.x4, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            size: 18, color: NsxColors.muted),
                        const SizedBox(width: NsxSpace.x3),
                        Text('SEARCH EVENTS · TIMES · VENUES',
                            style: NsxType.mono.copyWith(
                                color: NsxColors.muted, fontSize: 10)),
                        const Spacer(),
                        const Icon(Icons.auto_awesome,
                            size: 15, color: NsxColors.accent),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (spotlight.isNotEmpty)
              SliverToBoxAdapter(
                child: MonumentalSpotlight(
                  key: ValueKey(_selectedCategory),
                  listings: spotlight.take(3).toList(),
                  height: spotlightHeight,
                ),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: NsxSpace.gutter, vertical: NsxSpace.x6),
                  child: Text('NO SPOTLIGHT PICK IN THIS CATEGORY',
                      style: NsxType.mono.copyWith(color: NsxColors.muted)),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: NsxSpace.x5)),
            SliverToBoxAdapter(
              child: CategoryStrip(
                selected: _selectedCategory,
                onSelected: (c) => setState(
                  () => _selectedCategory = c == _selectedCategory ? null : c,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: NsxSpace.x7)),
            SliverToBoxAdapter(child: NowShowingRail(listings: nowShowing)),
            const SliverToBoxAdapter(
              child: SizedBox(height: NsxSpace.dockClearance),
            ),
          ],
        ),
      ),
    );
  }
}
