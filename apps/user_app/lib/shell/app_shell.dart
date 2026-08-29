import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

/// Persistent bottom-navigation shell powering the four main tabs.
/// Wired up by the [StatefulShellRoute] in `core/router/app_router.dart`.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: NSBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NSBottomNavBarDestination(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            label: 'Discover',
          ),
          NSBottomNavBarDestination(
            icon: Icons.search_outlined,
            selectedIcon: Icons.search,
            label: 'Search',
          ),
          NSBottomNavBarDestination(
            icon: Icons.bookmark_border,
            selectedIcon: Icons.bookmark,
            label: 'Watchlist',
          ),
          NSBottomNavBarDestination(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
