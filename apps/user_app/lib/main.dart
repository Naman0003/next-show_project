// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/api_keys.dart';
import 'core/di/core_providers.dart';
import 'core/router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: ApiKeys.supabaseUrl,
    anonKey: ApiKeys.supabaseAnonKey,
  );

  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<Map>(HiveBoxNames.watchlist),
    Hive.openBox<Map>(HiveBoxNames.listingCache),
  ]);

  runApp(const ProviderScope(child: NextShowApp()));
}

class NextShowApp extends StatelessWidget {
  const NextShowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Next Show Berlin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
