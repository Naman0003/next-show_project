import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../data/mock_discovery_data_source.dart';
import 'category_grid.dart';
import 'cinema_theme.dart';
import 'movie_poster_card.dart';
import 'spotlight_carousel.dart';

/// Next Show's homepage — cinematic dark, scoped to this screen only (the
/// rest of the app stays on `ui_kit`'s light theme). Category grid feeds a
/// local filter over the mock "In the spotlight" and "Now Showing" data;
/// nothing here talks to Supabase yet.
class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  static const _dataSource = MockDiscoveryDataSource();

  // Owned here (rather than constructed inline in `build`) so toggling the
  // category filter — which calls setState and reruns build — doesn't hand
  // PageView a brand-new controller and silently snap the rail back to
  // page 0.
  final _nowShowingController = PageController(viewportFraction: 0.42);

  EventCategory? _selectedCategory;

  @override
  void dispose() {
    _nowShowingController.dispose();
    super.dispose();
  }

  List<Listing> _filtered(List<Listing> listings) {
    final category = _selectedCategory;
    if (category == null) return listings;
    return listings.where((listing) => listing.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spotlight = _filtered(_dataSource.getSpotlight());
    final nowShowing = _filtered(_dataSource.getNowShowing());

    return Scaffold(
      backgroundColor: CinemaColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            const CinemaWordmark(fontSize: 22),
            const SizedBox(height: 4),
            Text('Berlin, tonight', style: CinemaTextStyles.meta),
            const SizedBox(height: 24),
            CategoryGrid(
              selectedCategory: _selectedCategory,
              onSelected: (category) => setState(() => _selectedCategory = category),
            ),
            const SizedBox(height: 32),
            if (spotlight.isNotEmpty) ...[
              Text('In the spotlight', style: CinemaTextStyles.sectionHeader),
              const SizedBox(height: 16),
              SpotlightCarousel(listings: spotlight)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.06, end: 0),
              const SizedBox(height: 32),
            ],
            Text('Now Showing', style: CinemaTextStyles.sectionHeader),
            const SizedBox(height: 16),
            if (nowShowing.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Nothing in this category right now.',
                  style: CinemaTextStyles.meta,
                ),
              )
            else
              SizedBox(
                height: 260,
                child: PageView(
                  controller: _nowShowingController,
                  children: [
                    for (final listing in nowShowing) MoviePosterCard(listing: listing),
                  ].animate(interval: 60.ms).fadeIn(duration: 350.ms).slideX(begin: 0.08, end: 0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
