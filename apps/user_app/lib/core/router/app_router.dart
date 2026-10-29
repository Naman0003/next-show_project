import 'package:core_models/core_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/booking/presentation/booking_web_view_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/newsfeed/presentation/event_breaking_carousel.dart';
import '../../features/discovery/presentation/splash_screen.dart';
import '../../features/event_detail/presentation/event_detail_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/seat_selection/presentation/seat_matrix_screen.dart';
import '../../features/watchlist/presentation/watchlist_screen.dart';
import '../../shell/app_shell.dart';
import '../bootstrap.dart';

part 'app_router.g.dart';

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: [
    TypedStatefulShellBranch<DiscoveryBranchData>(
      routes: [
        TypedGoRoute<DiscoveryRouteData>(path: '/discover'),
      ],
    ),
    TypedStatefulShellBranch<FeedBranchData>(
      routes: [
        TypedGoRoute<FeedRouteData>(path: '/feed'),
      ],
    ),
    TypedStatefulShellBranch<WatchlistBranchData>(
      routes: [
        TypedGoRoute<WatchlistRouteData>(path: '/watchlist'),
      ],
    ),
    TypedStatefulShellBranch<ProfileBranchData>(
      routes: [
        TypedGoRoute<ProfileRouteData>(path: '/profile'),
      ],
    ),
  ],
)
class AppShellRouteData extends StatefulShellRouteData {
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AppShell(navigationShell: navigationShell);
  }
}

class FeedBranchData extends StatefulShellBranchData {
  const FeedBranchData();
}

class FeedRouteData extends GoRouteData {
  const FeedRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const EventBreakingCarouselScreen();
}

class DiscoveryBranchData extends StatefulShellBranchData {
  const DiscoveryBranchData();
}

class DiscoveryRouteData extends GoRouteData {
  const DiscoveryRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

// Search tab is unwired from the shell (not registered above) but kept here,
// along with `features/search/`, so it can be restored by re-adding the
// branch to [AppShellRouteData] and the dock entry in `FloatingGlassDock`.
class SearchBranchData extends StatefulShellBranchData {
  const SearchBranchData();
}

class SearchRouteData extends GoRouteData {
  const SearchRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SearchScreen();
}

class WatchlistBranchData extends StatefulShellBranchData {
  const WatchlistBranchData();
}

class WatchlistRouteData extends GoRouteData {
  const WatchlistRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const WatchlistScreen();
}

class ProfileBranchData extends StatefulShellBranchData {
  const ProfileBranchData();
}

class ProfileRouteData extends GoRouteData {
  const ProfileRouteData();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}

@TypedGoRoute<EventDetailRoute>(path: '/event-detail')
class EventDetailRoute extends GoRouteData {
  const EventDetailRoute({required this.$extra});

  /// The full [Listing] to render — passed via go_router's typed `$extra`
  /// so we don't have to hand-roll (de)serialization for a query string.
  final Listing $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EventDetailScreen(listing: $extra);
}

@TypedGoRoute<BookingWebViewRoute>(path: '/booking')
class BookingWebViewRoute extends GoRouteData {
  const BookingWebViewRoute({required this.url, this.eventTitle});

  final String url;
  final String? eventTitle;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BookingWebViewScreen(destinationUrl: url, eventTitle: eventTitle);
}

/// Phase 4 dev-only entry point for the (dormant) seat matrix module.
/// Deliberately not linked from anywhere in the live booking flow — reach it
/// by typing the path directly, e.g. via `flutter run --dart-define`-less
/// deep link or the browser address bar in a web debug build.
@TypedGoRoute<DebugSeatMatrixRoute>(path: '/debug/seat-matrix')
class DebugSeatMatrixRoute extends GoRouteData {
  const DebugSeatMatrixRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SeatMatrixScreen();
}

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SplashScreen(from: state.uri.queryParameters['from']);
}

/// Lets the splash screen (and anything else) call `context.go('/')` and
/// land in the main shell's default tab, without every branch needing to
/// know its own path is really the "root".
@TypedGoRoute<RootRedirectRoute>(path: '/')
class RootRedirectRoute extends GoRouteData {
  const RootRedirectRoute();

  @override
  String? redirect(BuildContext context, GoRouterState state) => '/feed';
}

/// Whether [uri] is the Supabase auth redirect (`nextshow://login-callback`),
/// however the engine hands it over: with its host, as a path, or reduced to
/// just the PKCE `code` / `error` query.
@visibleForTesting
bool isAuthCallback(Uri uri) =>
    uri.host == 'login-callback' ||
    uri.path.contains('login-callback') ||
    uri.queryParameters.containsKey('code') ||
    uri.queryParameters.containsKey('error_description');

final GoRouter appRouter = GoRouter(
  routes: $appRoutes,
  initialLocation: '/splash',
  // Screens read Supabase and Hive synchronously, so hold any other entry
  // point (e.g. a web reload on /feed) on the splash until init is done,
  // remembering where it was headed.
  redirect: (context, state) {
    // The auth deep link (nextshow://login-callback?code=…) also reaches the
    // router; supabase_flutter exchanges the code, the user lands on Discover.
    if (isAuthCallback(state.uri)) {
      return isAppReady
          ? '/discover'
          : Uri(path: '/splash', queryParameters: {'from': '/discover'})
              .toString();
    }
    if (isAppReady || state.matchedLocation == '/splash') return null;
    return Uri(path: '/splash', queryParameters: {'from': state.uri.toString()})
        .toString();
  },
);
