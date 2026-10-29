import 'package:core_models/core_models.dart';
import 'package:supabase_client/supabase_client.dart';

import '../../../core/mocks/mock_listing_factory.dart';

/// Contract for turning a free-text (or voice-transcribed) mood query into
/// a list of matching [Listing]s. Two implementations:
/// [SupabaseAiConciergeService] (the real Phase 6+ backend, not deployed
/// yet) and [MockAiConciergeService] (what actually runs today).
abstract class AiConciergeService {
  Future<List<Listing>> search(String query);
}

/// Calls the `ai-concierge-search` Supabase Edge Function. Written against
/// the contract now so swapping [MockAiConciergeService] out later is a
/// one-line change in the controller — the edge function itself isn't
/// deployed yet, so this class doesn't run in the app until it is.
class SupabaseAiConciergeService implements AiConciergeService {
  const SupabaseAiConciergeService();

  static const _functionName = 'ai-concierge-search';

  @override
  Future<List<Listing>> search(String query) async {
    final response = await NextShowSupabaseClient.client.functions.invoke(
      _functionName,
      body: {'query': query},
    );

    final data = response.data as Map<String, dynamic>;
    final rawResults = data['results'] as List<dynamic>? ?? const [];

    return rawResults
        .map((json) => Listing.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}

/// Stands in for [SupabaseAiConciergeService] until that edge function is
/// deployed — mocks the round-trip latency and returns a fixed set of
/// placeholder [Listing]s, so the concierge state machine and UI can be
/// built and tested locally without an LLM API key.
class MockAiConciergeService implements AiConciergeService {
  const MockAiConciergeService();

  @override
  Future<List<Listing>> search(String query) async {
    await Future.delayed(const Duration(seconds: 2));
    return _placeholderResults;
  }

  static final _placeholderResults = <Listing>[
    buildMockListing(
      showtimeId: 'mock-concierge-1',
      startTime: DateTime.now().add(const Duration(hours: 4)),
      price: 13.5,
      showtimeAttributes: const {'language': 'OmU', 'format': '2D'},
      bookingUrl: 'https://example.com/book/mock-concierge-1',
      eventId: 'mock-concierge-event-1',
      eventTitle: 'Past Lives',
      eventDescription:
          'A tender, quietly devastating one — a good pick for a reflective mood.',
      durationMinutes: 105,
      venueId: 'mock-concierge-venue-1',
      venueName: 'Il Kino',
      venueAddress: 'Kastanienallee 20, Berlin',
      longitude: 13.4075,
      latitude: 52.5372,
    ),
    buildMockListing(
      showtimeId: 'mock-concierge-2',
      startTime: DateTime.now().add(const Duration(hours: 6)),
      price: 16.0,
      showtimeAttributes: const {'format': 'Live'},
      bookingUrl: 'https://example.com/book/mock-concierge-2',
      eventId: 'mock-concierge-event-2',
      category: EventCategory.comedy,
      eventTitle: 'Late Night Improv',
      eventDescription:
          'Loose, fast, and very silly — good for a lighter mood.',
      durationMinutes: 75,
      venueId: 'mock-concierge-venue-2',
      venueName: 'Quatsch Comedy Club',
      venueType: VenueType.club,
      venueAddress: 'Friedrichstraße 107, Berlin',
      longitude: 13.3879,
      latitude: 52.5219,
    ),
    buildMockListing(
      showtimeId: 'mock-concierge-3',
      startTime: DateTime.now().add(const Duration(hours: 8)),
      price: 24.0,
      showtimeAttributes: const {'format': 'Acoustic'},
      bookingUrl: 'https://example.com/book/mock-concierge-3',
      eventId: 'mock-concierge-event-3',
      category: EventCategory.music,
      eventTitle: 'Late Session: Berlin Strings',
      eventDescription:
          'Small-room acoustic set — good for winding a night down.',
      durationMinutes: 90,
      venueId: 'mock-concierge-venue-3',
      venueName: 'Villa Neukölln',
      venueType: VenueType.club,
      venueAddress: 'Weserstraße 202, Berlin',
      longitude: 13.4340,
      latitude: 52.4838,
    ),
  ];
}
