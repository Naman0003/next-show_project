import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/event_repository.dart';
import '../../../models/event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return MockEventRepository();
});

final selectedCityProvider = StateProvider<String>((ref) => 'Berlin');

final selectedCategoryProvider = StateProvider<EventCategory>((ref) => EventCategory.all);

final selectedDateProvider = StateProvider<DateTime?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

class SavedEventsNotifier extends StateNotifier<Set<String>> {
  SavedEventsNotifier() : super({'evt-1', 'evt-3'}); // Pre-saved items for demo

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
  final selectedDate = ref.watch(selectedDateProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return allEventsAsync.whenData((events) {
    return events.where((event) {
      final matchesCity = city == 'All Cities' || event.city.toLowerCase() == city.toLowerCase();
      final matchesCategory = category == EventCategory.all || event.category == category;
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
