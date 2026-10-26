import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/event_repository.dart';
import '../../../models/event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return MockEventRepository();
});

final selectedCityProvider = StateProvider<String>((ref) => 'Berlin');

final selectedCategoryProvider = StateProvider<EventCategory>((ref) => EventCategory.all);

final searchQueryProvider = StateProvider<String>((ref) => '');

class SavedEventsNotifier extends StateNotifier<Set<String>> {
  SavedEventsNotifier() : super({'evt-1', 'evt-6'}); // Seed initial saved items for demo

  void toggleSave(String eventId) {
    if (state.contains(eventId)) {
      state = {...state}..remove(eventId);
    } else {
      state = {...state, eventId};
    }
  }

  bool isSaved(String eventId) => state.contains(eventId);
}

final savedEventsProvider = StateNotifierProvider<SavedEventsNotifier, Set<String>>((ref) {
  return SavedEventsNotifier();
});

final allEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEvents();
});

final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final allEventsAsync = ref.watch(allEventsProvider);
  final city = ref.watch(selectedCityProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final savedSet = ref.watch(savedEventsProvider);

  return allEventsAsync.whenData((events) {
    return events.map((e) => e.copyWith(isSaved: savedSet.contains(e.id))).where((event) {
      final matchesCity = city == 'All Cities' || event.city.toLowerCase() == city.toLowerCase();
      final matchesCategory = category == EventCategory.all || event.category == category;
      final matchesQuery = query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.subtitle.toLowerCase().contains(query) ||
          event.venueName.toLowerCase().contains(query) ||
          event.city.toLowerCase().contains(query);

      return matchesCity && matchesCategory && matchesQuery;
    }).toList();
  });
});

final trendingEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final filteredAsync = ref.watch(filteredEventsProvider);
  return filteredAsync.whenData((events) {
    final trending = events.where((e) => e.isTrending).toList();
    return trending.isNotEmpty ? trending : events;
  });
});
