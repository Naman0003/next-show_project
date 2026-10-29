import 'dart:async';

import 'package:core_models/core_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/application/home_providers.dart';

/// Upcoming listings from `v_listings`, kept live: any change to events,
/// showtimes or venues (e.g. a scheduled ingest-events run) triggers a
/// refetch. Changes arrive in bursts during ingestion, so refetches are
/// debounced into one.
final feedListingsProvider = StreamProvider.autoDispose<List<Listing>>((ref) {
  final client = NextShowSupabaseClient.client;
  final controller = StreamController<List<Listing>>();
  Timer? debounce;

  Future<void> load() async {
    try {
      final listings =
          await NextShowSupabaseClient.fetchActiveListings(limit: 100);
      if (!controller.isClosed) controller.add(listings);
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    }
  }

  void scheduleReload(PostgresChangePayload _) {
    debounce?.cancel();
    debounce = Timer(const Duration(seconds: 2), load);
  }

  var channel = client.channel('feed_listings');
  for (final table in const ['events', 'showtimes', 'venues']) {
    channel = channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      callback: scheduleReload,
    );
  }
  channel.subscribe();

  load();

  ref.onDispose(() {
    debounce?.cancel();
    client.removeChannel(channel);
    controller.close();
  });
  return controller.stream;
});

/// [feedListingsProvider] narrowed to the city picked on Home. Ingested
/// events carry their city in `eventMetadata['city']`; listings without one
/// are Berlin, the only city with real data so far.
final feedForCityProvider =
    Provider.autoDispose<AsyncValue<List<Listing>>>((ref) {
  final city = ref.watch(selectedCityProvider).toLowerCase();
  return ref.watch(feedListingsProvider).whenData((listings) {
    if (city == 'all cities') return listings;
    return listings
        .where((l) =>
            ((l.eventMetadata['city'] as String?) ?? 'Berlin').toLowerCase() ==
            city)
        .toList();
  });
});
