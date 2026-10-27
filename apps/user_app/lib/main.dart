// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/api_keys.dart';
import 'core/di/core_providers.dart';
import 'core/router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run initializations concurrently to eliminate launch blocking
  await Future.wait([
    initializeDateFormatting('de_DE', null),
    Supabase.initialize(
      url: ApiKeys.supabaseUrl,
      anonKey: ApiKeys.supabaseAnonKey,
    ),
    Hive.initFlutter().then((_) => Future.wait([
      Hive.openBox<Map>(HiveBoxNames.watchlist),
      Hive.openBox<Map>(HiveBoxNames.listingCache),
    ])),
  ]);

  runApp(const ProviderScope(child: NextShowApp()));
}

class NextShowApp extends StatelessWidget {
  const NextShowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Next Show',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
