import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/floating_glass_dock.dart';

/// Persistent navigation shell powering the four main tabs. Wired up by the
/// [StatefulShellRoute] in `core/router/app_router.dart`.
///
/// The nav sits in a [Stack] as a floating pill over the content rather than
/// in `bottomNavigationBar`, so the dock hovers above the scrolling page
/// (`extendBody` semantics come for free).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep the dock pinned to the bottom when the keyboard opens; each tab's
      // own Scaffold still sees viewInsets and resizes its content itself.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingGlassDock(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
