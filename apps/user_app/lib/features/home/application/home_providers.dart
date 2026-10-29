import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/event_model.dart';
import '../../newsfeed/application/feed_providers.dart';

final selectedCityProvider = StateProvider<String>((ref) => 'Berlin');

final selectedCategoryProvider =
    StateProvider<EventCategory>((ref) => EventCategory.all);

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Real upcoming events, shared with the Feed tab's live `v_listings` stream
/// (one fetch + one Realtime subscription for both tabs).
final allEventsProvider = Provider.autoDispose<AsyncValue<List<Event>>>((ref) {
  return ref
      .watch(feedListingsProvider)
      .whenData((listings) => listings.map(Event.fromListing).toList());
});

final filteredEventsProvider =
    Provider.autoDispose<AsyncValue<List<Event>>>((ref) {
  final allEventsAsync = ref.watch(allEventsProvider);
  final city = ref.watch(selectedCityProvider);
  final category = ref.watch(selectedCategoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return allEventsAsync.whenData((events) {
    return events.where((event) {
      final matchesCity = city == 'All Cities' ||
          event.city.toLowerCase() == city.toLowerCase();
      final matchesCategory =
          category == EventCategory.all || event.category == category;
      final matchesQuery = query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.venueName.toLowerCase().contains(query) ||
          event.city.toLowerCase().contains(query);

      bool matchesDate = true;
      if (selectedDate != null) {
        matchesDate = event.startDate.year == selectedDate.year &&
            event.startDate.month == selectedDate.month &&
            event.startDate.day == selectedDate.day;
      }

      return matchesCity && matchesCategory && matchesQuery && matchesDate;
    }).toList();
  });
});
