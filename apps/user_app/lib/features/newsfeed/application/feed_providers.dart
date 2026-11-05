import 'dart:async';

import 'package:core_models/core_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_client/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/application/home_providers.dart';

/// How far ahead the feed loads (the Home date rail shows 10 days; the Feed tab scrolls further).
const feedHorizon = Duration(days: 90);

/// Upcoming listings from `v_listings` for the city picked on Home, kept
/// live: any change to events, showtimes or venues (e.g. a scheduled
/// ingest-events run) triggers a refetch. Changes arrive in bursts during
/// ingestion, so refetches are debounced into one.
///
/// The city is filtered in the query. Ingested events carry their city in
/// `event_metadata.city`; listings without one count as Berlin, the only
/// city with untagged data so far.
final feedListingsProvider = StreamProvider.autoDispose<List<Listing>>((ref) {
  final client = NextShowSupabaseClient.client;
  final city = ref.watch(selectedCityProvider);
  final controller = StreamController<List<Listing>>();
  Timer? debounce;

  Future<void> load() async {
    try {
      final listings = await NextShowSupabaseClient.fetchActiveListings(
        city: city == 'All Cities' ? null : city,
        cityIncludesUntagged: city.toLowerCase() == 'berlin',
        to: DateTime.now().add(feedHorizon),
        // shortcut: safety cap; page by date if one city ever has more than 500 shows in 90 days.
        limit: 500,
      );
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
