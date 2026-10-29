import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../models/event_model.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/expandable_search_bar.dart';
import '../../../widgets/shimmer_skeleton.dart';
import '../../../widgets/tap_scale_container.dart';
import '../application/home_providers.dart';
import '../../newsfeed/application/feed_providers.dart';
import '../../watchlist/application/watchlist_controller.dart';
import '../widgets/hero_event_card.dart';
import '../widgets/vertical_date_rail.dart';
import '../../../core/router/app_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedDate = ref.watch(selectedDateProvider) ?? DateTime.now();
    final eventsAsync = ref.watch(filteredEventsProvider);
    final savedIds =
        ref.watch(watchlistControllerProvider).map((l) => l.showtimeId).toSet();

    // No AppBar here, so set dark status bar icons for the light canvas.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.lightCanvas,
        body: Stack(
          children: [
            // Main Body Area
            SafeArea(
              child: RefreshIndicator(
                color: AppColors.darkPrimary,
                backgroundColor: AppColors.surfaceWhite,
                onRefresh: () async {
                  ref.invalidate(feedListingsProvider);
                },
                child: Column(
                  children: [
                    // 1. Top Location Pill Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Row(
                        children: [
                          PopupMenuButton<String>(
                            initialValue: selectedCity,
                            color: AppColors.surfaceWhite,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(
                                  color: AppColors.borderLight),
                            ),
                            onSelected: (city) {
                              ref.read(selectedCityProvider.notifier).state =
                                  city;
                            },
                            itemBuilder: (context) => _germanCities.map((city) {
                              return PopupMenuItem<String>(
                                value: city,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 16,
                                      color: city == selectedCity
                                          ? AppColors.darkPrimary
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      city,
                                      style: TextStyle(
                                        color: city == selectedCity
                                            ? AppColors.darkPrimary
                                            : AppColors.textPrimary,
                                        fontWeight: city == selectedCity
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceWhite,
                                borderRadius:
                                    BorderRadius.circular(AppTokens.radiusPill),
                                border:
                                    Border.all(color: AppColors.borderLight),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      size: 16, color: AppColors.darkPrimary),
                                  const SizedBox(width: 6),
                                  Text(
                                    selectedCity,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.keyboard_arrow_down_rounded,
                                      size: 18, color: AppColors.textSecondary),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Breaking Events Digest Icon Button
                          TapScaleContainer(
                            onTap: () {
                              context.go('/feed');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.darkPrimary,
                                borderRadius:
                                    BorderRadius.circular(AppTokens.radiusPill),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1F000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.error,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                      .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true))
                                      .fade(
                                          begin: 0.3,
                                          end: 1.0,
                                          duration: 800.ms),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'LIVE DIGEST',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Action Bar Row (Expandable Search + Category Chips)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 12),
                      // Stack so the search bar can grow over the chips.
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 44 + 8),
                            child: Row(
                              children: [
                                // Horizontally Scrolling Category Chip Bar
                                Expanded(
                                  child: SizedBox(
                                    height: 42,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: EventCategory.values.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final category =
                                            EventCategory.values[index];
                                        final isSelected =
                                            selectedCategory == category;
                                        return CategoryChip(
                                          category: category,
                                          isSelected: isSelected,
                                          onTap: () {
                                            ref
                                                .read(selectedCategoryProvider
                                                    .notifier)
                                                .state = category;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Expandable search: 44px circle -> full-width bar
                          Positioned.fill(
                            child: ExpandableSearchBar(
                              controller: _searchController,
                              onChanged: (val) {
                                ref.read(searchQueryProvider.notifier).state =
                                    val;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Main Content: Left Vertical Date Rail + Right Event List
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vertical Date Rail (Left)
                          Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: VerticalDateRail(
                              selectedDate: selectedDate,
                              onDateSelected: (date) {
                                final current = ref.read(selectedDateProvider);
                                if (current != null &&
                                    current.year == date.year &&
                                    current.month == date.month &&
                                    current.day == date.day) {
                                  // Toggle off date filter if tapped again
                                  ref
                                      .read(selectedDateProvider.notifier)
                                      .state = null;
                                } else {
                                  ref
                                      .read(selectedDateProvider.notifier)
                                      .state = date;
                                }
                              },
                            ),
                          ),

                          // Event List (Right)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 20, left: 8),
                              child: eventsAsync.when(
                                data: (eventsList) {
                                  if (eventsList.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.event_busy_rounded,
                                              size: 48,
                                              color: AppColors.textMuted),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'No free events found for this filter.',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextButton(
                                            onPressed: () {
                                              ref
                                                  .read(selectedCategoryProvider
                                                      .notifier)
                                                  .state = EventCategory.all;
                                              ref
                                                  .read(selectedDateProvider
                                                      .notifier)
                                                  .state = null;
                                              ref
                                                  .read(selectedCityProvider
                                                      .notifier)
                                                  .state = 'All Cities';
                                            },
                                            child: const Text('Reset Filters',
                                                style: TextStyle(
                                                    color:
                                                        AppColors.darkPrimary,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.only(
                                        bottom:
                                            AppTokens.dockClearance(context)),
                                    itemCount: eventsList.length,
                                    itemBuilder: (context, index) {
                                      final event = eventsList[index];
                                      final listing = event.toListing();
                                      final isSaved =
                                          savedIds.contains(listing.showtimeId);

                                      return HeroEventCard(
                                        event: event,
                                        isSaved: isSaved,
                                        onTap: () {
                                          EventDetailRoute($extra: listing)
                                              .push(context);
                                        },
                                        onToggleSave: () async {
                                          final watchlist = ref.read(
                                              watchlistControllerProvider
                                                  .notifier);
                                          if (isSaved) {
                                            await watchlist
                                                .remove(listing.showtimeId);
                                          } else {
                                            await watchlist.add(listing);
                                          }
                                        },
                                      )
                                          .animate()
                                          .fadeIn(
                                              delay: (index * 70).ms,
                                              duration: 350.ms)
                                          .slideY(begin: 0.08, end: 0.0);
                                    },
                                  );
                                },
                                loading: () => const ShimmerSkeletonLoader(),
                                error: (err, stack) => const Center(
                                  child: Text('Failed to load events',
                                      style: TextStyle(color: AppColors.error)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
