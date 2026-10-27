import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_decorations.dart';
import '../../../models/event_model.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/shimmer_skeleton.dart';
import '../../../widgets/tap_scale_container.dart';
import '../application/home_providers.dart';
import '../widgets/trending_card.dart';
import '../widgets/upcoming_card.dart';
import '../../../core/router/app_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _trendingPageController = PageController(viewportFraction: 0.78);
  final TextEditingController _searchController = TextEditingController();
  int _activeTrendingIndex = 0;

  static const List<String> _germanCities = [
    'All Cities',
    'Berlin',
    'Munich',
    'Hamburg',
    'Cologne',
    'Frankfurt',
    'Leipzig',
  ];

  @override
  void dispose() {
    _trendingPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final eventsAsync = ref.watch(filteredEventsProvider);
    final trendingEventsAsync = ref.watch(trendingEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkCanvas,
      body: Stack(
        children: [
          // Top Background Gradient Glow Bleed
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            height: 320,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.topGlowGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // Main Scrollable Area
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.royalBlue,
              backgroundColor: AppColors.surfaceCard,
              onRefresh: () async {
                ref.invalidate(allEventsProvider);
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Top Header (Logo + City Selector + Notification)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        children: [
                          // Next Show Logo/Wordmark
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.royalBlue, AppColors.skyBlue],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 10),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, AppColors.skyBlue],
                                ).createShader(bounds),
                                child: const Text(
                                  'Next show',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // City Selector Pill Dropdown
                          PopupMenuButton<String>(
                            initialValue: selectedCity,
                            color: AppColors.surfaceCard,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.glassBorder),
                            ),
                            onSelected: (city) {
                              ref.read(selectedCityProvider.notifier).state = city;
                            },
                            itemBuilder: (context) => _germanCities.map((city) {
                              return PopupMenuItem<String>(
                                value: city,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_city_rounded,
                                      size: 16,
                                      color: city == selectedCity
                                          ? AppColors.skyBlue
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      city,
                                      style: TextStyle(
                                        color: city == selectedCity
                                            ? AppColors.skyBlue
                                            : AppColors.textPrimary,
                                        fontWeight: city == selectedCity
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            child: GlassDecorations.glassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              borderRadius: 100,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 16, color: AppColors.skyBlue),
                                  const SizedBox(width: 4),
                                  Text(
                                    selectedCity,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Notification Bell Button
                          TapScaleContainer(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No new notifications for free events!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: GlassDecorations.glassContainer(
                              padding: const EdgeInsets.all(10),
                              borderRadius: 100,
                              child: Stack(
                                children: [
                                  const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 20),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.neonGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Search Bar + Filter Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: GlassDecorations.glassContainer(
                              borderRadius: 20,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                onChanged: (val) {
                                  ref.read(searchQueryProvider.notifier).state = val;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search an event or artist',
                                  hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                                  border: InputBorder.none,
                                  icon: Icon(Icons.search_rounded, color: AppColors.skyBlue, size: 20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TapScaleContainer(
                            onTap: () {
                              ref.read(searchQueryProvider.notifier).state = '';
                              _searchController.clear();
                            },
                            child: GlassDecorations.glassContainer(
                              padding: const EdgeInsets.all(14),
                              borderRadius: 20,
                              child: const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Horizontal Category Bar
                  SliverToBoxAdapter(
                    child: Container(
                      height: 48,
                      margin: const EdgeInsets.symmetric(vertical: 14),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: EventCategory.values.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = EventCategory.values[index];
                          final isSelected = selectedCategory == category;
                          return CategoryChip(
                            category: category,
                            isSelected: isSelected,
                            onTap: () {
                              ref.read(selectedCategoryProvider.notifier).state = category;
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // 4. 🔥 Trending Free Events Section Header & PageView Carousel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: const [
                          Text(
                            '🔥 Trending Events',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Spacer(),
                          Text(
                            '100% FREE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neonGreen,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: trendingEventsAsync.when(
                        data: (trendingList) {
                          if (trendingList.isEmpty) {
                            return const Center(
                              child: Text('No trending free events found', style: TextStyle(color: AppColors.textMuted)),
                            );
                          }
                          return PageView.builder(
                            controller: _trendingPageController,
                            itemCount: trendingList.length,
                            onPageChanged: (idx) => setState(() => _activeTrendingIndex = idx),
                            itemBuilder: (context, index) {
                              final event = trendingList[index];
                              return TrendingCard(
                                event: event,
                                isCenter: index == _activeTrendingIndex,
                                onTap: () {
                                  EventDetailRoute($extra: event.toListing()).push(context);
                                },
                                onToggleSave: () {
                                  ref.read(savedEventsProvider.notifier).toggleSave(event.id);
                                },
                              );
                            },
                          );
                        },
                        loading: () => const ShimmerSkeletonLoader(),
                        error: (err, stack) => Center(
                          child: Text('Error loading events', style: TextStyle(color: AppColors.error)),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0),
                  ),

                  // 5. "Upcoming in your city" Section Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      child: Row(
                        children: [
                          Text(
                            'Upcoming in $selectedCity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          TapScaleContainer(
                            onTap: () {
                              ref.read(selectedCategoryProvider.notifier).state = EventCategory.all;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.glassSurface,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: const Text(
                                '+ See more',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.skyBlue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 6. Upcoming Vertical List
                  eventsAsync.when(
                    data: (eventsList) {
                      if (eventsList.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No free events match your filter.',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                              ),
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final event = eventsList[index];
                              return UpcomingCard(
                                event: event,
                                onTap: () {
                                  EventDetailRoute($extra: event.toListing()).push(context);
                                },
                                onToggleSave: () {
                                  ref.read(savedEventsProvider.notifier).toggleSave(event.id);
                                },
                              ).animate().fadeIn(delay: (index * 60).ms, duration: 350.ms);
                            },
                            childCount: eventsList.length,
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(child: ShimmerSkeletonLoader()),
                    error: (err, stack) => SliverToBoxAdapter(
                      child: Center(
                        child: Text('Error loading upcoming events', style: TextStyle(color: AppColors.error)),
                      ),
                    ),
                  ),

                  // Bottom padding for Floating Nav Bar clearance
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
