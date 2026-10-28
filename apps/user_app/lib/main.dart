// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/bootstrap.dart';
import 'core/router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Don't block the first frame on initialisation: the splash paints right
  // away and waits for this to finish before entering the app.
  ensureAppReady();

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
