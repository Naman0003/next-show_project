import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared/api_keys.dart';
import 'package:supabase_client/supabase_client.dart';

import 'di/core_providers.dart';

Future<void>? _ready;
bool _isReady = false;

/// True once [ensureAppReady] has completed. The router keeps every route
/// except the splash on hold until then, since screens read Supabase and the
/// Hive boxes synchronously.
bool get isAppReady => _isReady;

/// Starts app-wide initialisation once and returns the same future on every
/// call. `main()` kicks it off without awaiting so the first frame (the
/// splash) paints immediately; [SplashScreen] awaits it before handing off.
Future<void> ensureAppReady() => _ready ??= Future.wait([
      initializeDateFormatting('de_DE', null),
      // Also registers the client for the shared NextShowSupabaseClient helpers
      // (fetchActiveListings, functions.invoke), which throw if left uninitialized.
      NextShowSupabaseClient.initialize(
        url: ApiKeys.supabaseUrl,
        anonKey: ApiKeys.supabaseAnonKey,
      ),
      Hive.initFlutter().then((_) => Future.wait([
            Hive.openBox<Map>(HiveBoxNames.watchlist),
            Hive.openBox<Map>(HiveBoxNames.listingCache),
          ])),
    ]).then((_) => _isReady = true);
