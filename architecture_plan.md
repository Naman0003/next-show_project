# NextShow — Production Architecture Plan

**Status:** Draft for founder review. No code has been changed to produce this document — it is a design artifact only.

---

## 1. Context & Goals

This is a ground-up architecture redesign of `apps/user_app`, NextShow's Flutter consumer app. The prior product plan (`docs/plan.md`) framed this as a lightweight MVP — "don't build seat selection, payments, or ticket inventory yet." That framing is now superseded: **NextShow is being built as a production-ready, finished app for a Gen Z audience**, not a prototype.

Concretely, that means:

- **UI/UX must be highly polished**: 120Hz-ready animation budgets, glassmorphism treatments, rich micro-interactions — not default Material widgets bolted together.
- **Architecture must be enterprise-grade**: strict Clean Architecture (data sources → repositories → Riverpod controllers → UI), type-safe routing, offline-first caching, no ad-hoc `setState`/direct-Supabase-call sprawl.
- **The interactive seat-selection module is architected now, not deferred.** Even though live bookings still route through affiliate outlinks in the near term, the seat matrix UI, its state contracts, and its exact JSON/Postgres schemas must be fully designed today so they're ready for real transactional data the moment that phase is greenlit. This is a deliberate override of `docs/plan.md`'s "Phase 5 — only after traction" stance on seat selection — the founder has accelerated this roadmap.

The document below is organized so each section can be reviewed independently: current-state grounding, target architecture (directory structure, state management, routing, offline caching, seat matrix, booking pipeline, new screens, UI system), and a sequential migration plan from today's code to that target.

---

## 2. Current State Summary

This section is what exists today, verified directly against the repository, and what's dead weight that the redesign removes.

### `apps/user_app/lib` — flat, no architecture

```
apps/user_app/lib/
├── main.dart                      # bare MaterialApp, no DI, home: HomeScreen(), Supabase.initialize() inline
├── models/event_model.dart        # hand-written Event/EventCategory/ShowTime/CinemaHall/CastMember — DUPLICATES shared/core_models
├── screens/
│   ├── auth/{login_screen.dart, otp_screen.dart}
│   ├── browse_screen.dart         # StatefulWidget + StreamBuilder over EventRepository.streamLiveEvents()
│   ├── event_detail_screen.dart   # detail + CinemaAggregatorScreen in one file; direct HTTP calls to TMDB in initState
│   ├── home_screen.dart           # AI/voice search landing, setState-driven
│   └── movies_screen.dart         # DEAD CODE — unreferenced anywhere
├── services/
│   ├── ai_recommendation_service.dart  # calls Gemini directly from the client (API key shipped in the app bundle)
│   ├── api_service.dart                # DEAD CODE — only used by orphaned movies_screen.dart
│   ├── auth_service.dart
│   ├── booking_service.dart            # url_launcher only, external browser, no in-app webview
│   ├── event_repository.dart           # hand-rolled realtime channel; refetches the FULL table on any change
│   └── voice_input_service.dart
├── theme/app_theme.dart           # standalone ThemeData, duplicates what ui_kit already provides
└── widgets/{account_menu_button.dart, next_show_logo.dart, voice_search_overlay.dart}
```

Key gaps:
- **No routing package** anywhere — zero `go_router`, zero Navigator 2.0. Pure `Navigator.push(MaterialPageRoute(...))` scattered across five files.
- **No real state management.** `riverpod: ^2.5.0` is declared in `pubspec.yaml` but is *never imported anywhere* (grep-verified, zero hits). Every screen manages its own state via `setState`.
- **No bottom navigation, no Profile screen, no Watchlist screen.** `Event.isFavorite` exists as a boolean field but is never read or written by any screen or widget — a stub with no feature behind it.
- **Dead code**: `screens/movies_screen.dart` + `services/api_service.dart` form an orphaned pair, unreachable from any live route.
- **Duplicated models**: `apps/user_app/lib/models/event_model.dart` hand-rolls its own `Event`/`EventCategory` (using `EventCategory.movies`), which diverges from `shared/core_models`'s `Event`/`EventCategory` (which uses `EventCategory.movie`) — a real bug source waiting to happen.

### Shared packages (`shared/`, not `packages/` — no melos/workspace tooling exists)

- **`shared/ui_kit/lib/ui_kit.dart`** (723 lines) — a complete, usable design system: `NSColors`, `NSTextStyles`, `nsTheme`, `NSEventCard`, `NSCategoryFilter`, `NSShowtimeChip`, `NSCinemaCard`, `NSPrimaryButton`/`NSSecondaryButton`, `NSLoading`, `NSEmptyState`, `NSErrorState`, `NSStatusBadge`, `NSVenueTypeBadge`. **Declared as a dependency in `user_app`'s pubspec but never imported anywhere in `apps/user_app/lib`** — pure dead weight today, despite being fully built.
- **`shared/core_models/lib/core_models.dart`** (205 lines, freezed + json_serializable) — `Profile`, `Venue` (PostGIS lat/lng flattened), `Event` (`externalIds`/`metadata` as `Map`), `Showtime` (**hall/format/audio currently live only as loose strings inside `attributes: Map<String,dynamic>` — no typed Hall/Seat/VenueLayout model exists anywhere**; `capacity` is a single int, not per-seat), `OutboundClick`, `OrganizerInvite`, `Listing` (flattened join view model for UI consumption).
- **`shared/supabase_client/lib/supabase_client.dart`** (688 lines, static-method class `NextShowSupabaseClient`) — venues/events/showtimes CRUD, `fetchActiveListings` (queries `v_listings` view, PostGIS RPC `fetch_listings_nearby` for radius search), `recordClick`/`fetchClicksForVenue`, `subscribeToShowtimes` (channel/`onPostgresChanges` API). This **diverges from two other realtime patterns already in the codebase**: `apps/organizer_app`'s `ShowtimeListScreen` uses a raw `.from('showtimes').stream(...)` query with its own private JSON mapper, and `apps/user_app`'s `event_repository.dart` uses yet another hand-rolled channel that refetches the entire table on any single row change.

### Database (`docs/schema.sql`)

Tables: `profiles`, `venues` (PostGIS `location geography(point,4326)`), `events` (jsonb `external_ids`, `metadata`), `showtimes` (jsonb `attributes`, GIN-indexed), `outbound_clicks`, `organizer_invites`. View: `v_listings` (flattened showtime+event+venue join). Security: `is_admin()`/`is_partner()` `SECURITY DEFINER` helpers avoid RLS recursion; RLS enabled on every table.

**No halls/seats/venue-layout tables exist at all.** `apps/organizer_app`'s showtime form today writes hall/format/audio as free strings into the `attributes` JSONB bag (`screen_name` default `"Hall 1"`, `audio_subtitle` one of OmU/OmeU/DF/OV/Original, `format` one of 2D/3D/IMAX 2D/IMAX 3D/35mm/70mm/4K), with a plain integer `capacity` and a required `bookingUrl`. A production seat-selection module needs entirely new tables, designed from scratch — see §7.

---

## 3. Feature-First Directory Structure

```
apps/user_app/lib/
├── main.dart                          # ProviderScope + MaterialApp.router bootstrap
├── app.dart                           # NextShowApp widget (theme + router wiring)
├── core/
│   ├── config/env.dart                # wraps shared/lib/api_keys.dart, feature flags
│   ├── di/core_providers.dart         # supabaseClientProvider, connectivityProvider
│   ├── cache/
│   │   ├── hive_registrar.dart        # central Hive.registerAdapter() calls + typeIds
│   │   ├── hive_boxes.dart            # box providers (watchlistBoxProvider, etc.)
│   │   └── models/                    # WatchlistEntry, CachedListingPage, ProfileSnapshot (Hive TypeAdapters)
│   ├── routing/
│   │   ├── app_router.dart            # @TypedGoRoute / @TypedStatefulShellRoute defs
│   │   ├── app_router.g.dart          # generated by go_router_builder
│   │   └── router_refresh_stream.dart # GoRouterRefreshStream(authControllerProvider.stream)
│   ├── theme/app_theme.dart           # thin: exposes nsTheme/nsDarkTheme from ui_kit
│   ├── errors/result.dart             # lightweight Result<T>/Failure types for repositories
│   └── widgets/connectivity_banner.dart  # "Offline — showing saved results"
├── features/
│   ├── auth/
│   │   ├── data/auth_remote_data_source.dart
│   │   ├── application/auth_controller.dart          # @riverpod class AuthController
│   │   └── presentation/{login_screen.dart, otp_screen.dart}
│   ├── discovery/                      # Home / For You
│   │   ├── data/{listing_remote_data_source.dart, listing_local_data_source.dart}
│   │   ├── domain/listing_repository.dart
│   │   ├── application/home_feed_controller.dart
│   │   └── presentation/{home_screen.dart, widgets/event_carousel.dart, widgets/category_chip_row.dart}
│   ├── search/                         # AI Concierge + faceted search
│   │   ├── data/ai_concierge_remote_data_source.dart # calls a Supabase Edge Function, not Gemini directly
│   │   ├── application/{ai_concierge_controller.dart, voice_input_controller.dart, faceted_search_controller.dart}
│   │   └── presentation/{search_screen.dart, widgets/voice_overlay.dart, widgets/facet_filter_sheet.dart}
│   ├── event_detail/
│   │   ├── data/listing_by_id_data_source.dart
│   │   ├── application/event_detail_controller.dart
│   │   └── presentation/{event_detail_screen.dart, widgets/hero_media.dart, widgets/venue_map.dart, widgets/social_proof_row.dart, widgets/notify_me_button.dart}
│   ├── booking/                        # Phase 1 outlink pipeline
│   │   ├── data/{outlink_data_source.dart, outbound_click_data_source.dart}
│   │   ├── application/booking_controller.dart
│   │   └── presentation/{booking_webview_screen.dart, widgets/return_to_nextshow_bar.dart}
│   ├── seat_selection/                 # Phase 2 blueprint — architected now, disconnected from real booking
│   │   ├── data/{seat_map_remote_data_source.dart, mock_seat_map_data_source.dart}
│   │   ├── domain/seat_map_repository.dart
│   │   ├── application/{seat_selection_controller.dart, seat_hold_controller.dart}
│   │   └── presentation/{seat_matrix_screen.dart, widgets/seat_matrix_painter.dart, widgets/seat_legend.dart, widgets/accessible_seat_list_view.dart}
│   ├── watchlist/
│   │   ├── data/watchlist_local_data_source.dart      # Hive-backed
│   │   ├── application/watchlist_controller.dart
│   │   └── presentation/{watchlist_screen.dart, widgets/alert_settings_sheet.dart}
│   └── profile/
│       ├── data/profile_data_source.dart
│       ├── application/{profile_controller.dart, notification_prefs_controller.dart}
│       └── presentation/{profile_screen.dart, settings_screen.dart, booking_history_screen.dart}
└── shell/
    └── bottom_nav_shell.dart           # StatefulNavigationShell host, uses ui_kit's NSBottomNavBar
```

Every feature strictly follows **data sources → repositories → Riverpod controllers → UI**: `data/*_data_source.dart` talks to Supabase/Hive only; `domain/*_repository.dart` (abstract, plus an impl) composes data sources and is the only thing controllers depend on; `application/*_controller.dart` is the sole `@riverpod` state layer; `presentation/*` is pure UI that only reads controllers via `ref.watch` — it never touches a data source or `Supabase.instance.client` directly.

**Explicit deletions:** `apps/user_app/lib/screens/movies_screen.dart`, `apps/user_app/lib/services/api_service.dart`, `apps/user_app/lib/models/event_model.dart` (replaced by `core_models`'s `Event`/`Listing`), and `apps/user_app/lib/theme/app_theme.dart`'s current standalone `ThemeData` (replaced by `ui_kit.nsTheme`).

**Changes to `shared/`:**
- `shared/core_models`: split the single `core_models.dart` into `lib/src/catalog_models.dart` (existing models, unchanged), `lib/src/seat_models.dart` (new, §7), `lib/src/booking_models.dart` (new `BookingMode` enum), re-exported via a slim barrel file. Add a `bookingMode` field to `Listing`/`Venue`.
- `shared/supabase_client`: add `fetchSeatMap(showtimeId)`, `holdSeats(...)`, `releaseHold(...)`; **consolidate the three divergent realtime patterns** (this package's own `subscribeToShowtimes`, organizer_app's raw `.stream()`, user_app's full-table-refetch channel) into one canonical `watchListings(...)` method used by both `user_app` and `organizer_app` going forward.
- `shared/ui_kit`: add `lib/src/motion.dart`, `skeletons.dart`, `glass.dart`, `lottie_assets.dart`, `NSBottomNavBar`, `nsDarkTheme` — detailed in §10.

---

## 4. Riverpod Migration Plan

### DI foundation (`core/di/core_providers.dart`)

```dart
@riverpod
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

@riverpod
Stream<ConnectivityResult> connectivity(Ref ref) =>
    Connectivity().onConnectivityChanged.map((r) => r.first);
```

Every data source is constructor-injected and exposed as a provider:

```dart
@riverpod
ListingRemoteDataSource listingRemoteDataSource(Ref ref) =>
    ListingRemoteDataSource(ref.watch(supabaseClientProvider));

@riverpod
ListingLocalDataSource listingLocalDataSource(Ref ref) =>
    ListingLocalDataSource(ref.watch(listingCacheBoxProvider));

@riverpod
ListingRepository listingRepository(Ref ref) => ListingRepositoryImpl(
      remote: ref.watch(listingRemoteDataSourceProvider),
      local: ref.watch(listingLocalDataSourceProvider),
    );
```

This is what replaces every inline `EventRepository()` construction and every direct `Supabase.instance.client` call currently sprinkled through `booking_service.dart`, `event_repository.dart`, and `ai_recommendation_service.dart`.

### Concrete provider signatures

**Home feed** (cache-then-network + realtime, mechanism detailed in §6):

```dart
@riverpod
class HomeFeedController extends _$HomeFeedController {
  @override
  Stream<List<Listing>> build({EventCategory? category}) {
    return ref.watch(listingRepositoryProvider).watchListings(category: category);
  }
}
```

**AI Search / concierge:**

```dart
@freezed
class AiConciergeState with _$AiConciergeState {
  const factory AiConciergeState.idle() = _Idle;
  const factory AiConciergeState.loading(String query) = _Loading;
  const factory AiConciergeState.result(String assistantMessage, List<Listing> recommendations) = _Result;
  const factory AiConciergeState.error(String message) = _Error;
}

@riverpod
class AiConciergeController extends _$AiConciergeController {
  @override
  AiConciergeState build() => const AiConciergeState.idle();

  Future<void> sendQuery(String text) async {
    state = AiConciergeState.loading(text);
    final grounded = await ref.read(listingRepositoryProvider).fetchGroundingSet(limit: 80);
    final result = await ref.read(aiConciergeRepositoryProvider).ask(text, grounded);
    state = AiConciergeState.result(result.message, result.listings);
  }
}

@riverpod
class VoiceInputController extends _$VoiceInputController {
  @override
  VoiceInputState build() => const VoiceInputState.idle();
  Future<void> startListening() async { /* ports voice_input_service.dart's silence-detection logic */ }
  Future<void> stopListening() async { ... }
}

@riverpod
class FacetedSearchController extends _$FacetedSearchController {
  @override
  FacetedSearchState build() => FacetedSearchState.initial();
  void setCategory(EventCategory? c) => state = state.copyWith(category: c);
  void setDateRange(DateTimeRange? r) => state = state.copyWith(dateRange: r);
  void setPriceRange(RangeValues r) => state = state.copyWith(priceRange: r);
  void setVenueId(String? id) => state = state.copyWith(venueId: id);
}
```

**Watchlist** (Hive-backed, reactive on box mutation):

```dart
@riverpod
class WatchlistController extends _$WatchlistController {
  @override
  List<WatchlistEntry> build() {
    final box = ref.watch(watchlistBoxProvider);
    final sub = box.watch().listen((_) => ref.invalidateSelf());
    ref.onDispose(sub.cancel);
    return box.values.toList()..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  Future<void> toggle(Listing listing) async {
    final box = ref.read(watchlistBoxProvider);
    if (box.containsKey(listing.showtimeId)) {
      await box.delete(listing.showtimeId);
    } else {
      await box.put(listing.showtimeId, WatchlistEntry.fromListing(listing));
    }
  }

  Future<void> setAlert(String showtimeId, {bool? priceAlert, bool? availabilityAlert}) async {
    final box = ref.read(watchlistBoxProvider);
    final entry = box.get(showtimeId);
    if (entry == null) return;
    await box.put(showtimeId, entry.copyWith(
      priceAlertEnabled: priceAlert ?? entry.priceAlertEnabled,
      availabilityAlertEnabled: availabilityAlert ?? entry.availabilityAlertEnabled,
    ));
  }
}
```

**Auth / profile:**

```dart
@riverpod
class AuthController extends _$AuthController {
  @override
  Stream<AuthState> build() => NextShowSupabaseClient.onAuthStateChange;

  Future<void> signInWithOtp(String email) => NextShowSupabaseClient.signInWithOtp(email: email);
  Future<void> verifyOtp(String email, String code) =>
      NextShowSupabaseClient.verifyOtp(email: email, code: code);
  Future<void> signOut() => NextShowSupabaseClient.signOut();
}

@riverpod
Future<Profile?> currentProfile(Ref ref) async {
  final authState = await ref.watch(authControllerProvider.future);
  final userId = authState.session?.user.id;
  if (userId == null) return null;
  return ref.watch(profileRepositoryProvider).fetchProfile(userId);
}
```

**Booking / outlink** (mechanism detailed in §8):

```dart
@riverpod
class BookingController extends _$BookingController {
  @override
  BookingState build(String showtimeId) => const BookingState.idle();

  Future<void> launch(Listing listing) async {
    state = const BookingState.launching();
    final repo = ref.read(bookingRepositoryProvider);
    final clickId = await repo.recordClick(listing.showtimeId);
    final uri = repo.buildOutlinkUri(listing.bookingUrl, clickId: clickId);
    state = BookingState.ready(uri);
  }
}
```

### `main.dart` bootstrap

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  registerHiveAdapters(); // core/cache/hive_registrar.dart
  await Supabase.initialize(url: ApiKeys.supabaseUrl, anonKey: ApiKeys.supabaseAnonKey);

  final watchlistBox = await Hive.openBox<WatchlistEntry>('watchlist');
  final listingCacheBox = await Hive.openBox<CachedListingPage>('listing_cache');
  final profileCacheBox = await Hive.openBox<ProfileSnapshot>('profile_cache');

  runApp(ProviderScope(
    overrides: [
      watchlistBoxProvider.overrideWithValue(watchlistBox),
      listingCacheBoxProvider.overrideWithValue(listingCacheBox),
      profileCacheBoxProvider.overrideWithValue(profileCacheBox),
    ],
    child: const NextShowApp(),
  ));
}
```

---

## 5. Routing (go_router + go_router_builder)

**Decision: `StatefulShellRoute`** (via `TypedStatefulShellRoute`, IndexedStack semantics) for the bottom nav — not a hand-rolled `IndexedStack`+`Navigator`, and not plain push-based tab switching. It preserves each tab's own `Navigator` stack, scroll position, and provider subtree state when switching tabs — Home's scroll offset and Search's facet state must survive a Search→Watchlist→Search hop. A rebuild-on-switch approach would refetch and rescroll every time, which fails the instant-tab-switch feel this app is being judged against.

```dart
@TypedStatefulShellRoute<BottomNavShellRouteData>(
  branches: [
    TypedStatefulShellBranch<HomeBranchData>(routes: [
      TypedGoRoute<HomeRouteData>(path: '/home'),
    ]),
    TypedStatefulShellBranch<SearchBranchData>(routes: [
      TypedGoRoute<SearchRouteData>(path: '/search'),
    ]),
    TypedStatefulShellBranch<WatchlistBranchData>(routes: [
      TypedGoRoute<WatchlistRouteData>(path: '/watchlist'),
    ]),
    TypedStatefulShellBranch<ProfileBranchData>(routes: [
      TypedGoRoute<ProfileRouteData>(path: '/profile', routes: [
        TypedGoRoute<SettingsRouteData>(path: 'settings'),
        TypedGoRoute<BookingHistoryRouteData>(path: 'bookings'),
      ]),
    ]),
  ],
)
class BottomNavShellRouteData extends StatefulShellRouteData {
  static Widget builder(BuildContext context, GoRouterState state, StatefulNavigationShell shell) =>
      BottomNavShell(navigationShell: shell);
}

// Top-level routes (full-screen pushes over the shell)
@TypedGoRoute<EventDetailRouteData>(path: '/event/:eventId')
class EventDetailRouteData extends GoRouteData {
  const EventDetailRouteData({required this.eventId, this.$extra});
  final String eventId;
  final Listing? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EventDetailScreen(eventId: eventId, seedListing: $extra);
}

@TypedGoRoute<BookingOutlinkRouteData>(path: '/booking/:showtimeId')
class BookingOutlinkRouteData extends GoRouteData {
  const BookingOutlinkRouteData({required this.showtimeId, this.$extra});
  final String showtimeId;
  final Listing? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BookingWebViewScreen(showtimeId: showtimeId, seedListing: $extra);
}

@TypedGoRoute<SeatSelectionRouteData>(path: '/booking/:showtimeId/seats')
class SeatSelectionRouteData extends GoRouteData {
  const SeatSelectionRouteData({required this.showtimeId, this.$extra});
  final String showtimeId;
  final VenueLayout? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SeatMatrixScreen(showtimeId: showtimeId, seedLayout: $extra);
}

@TypedGoRoute<LoginRouteData>(path: '/login')
class LoginRouteData extends GoRouteData { ... }
```

### State persistence: AI Search → Event Detail, no relookup

```dart
// In search results list, tapping a card:
onTap: () => EventDetailRouteData(eventId: listing.eventId, $extra: listing).push(context),

// EventDetailController seeds synchronously from $extra, refreshes in background:
@riverpod
class EventDetailController extends _$EventDetailController {
  @override
  Future<Listing> build(String eventId, {Listing? seed}) async {
    if (seed != null) {
      unawaited(_refreshInBackground(eventId));
      return seed; // renders instantly, zero network round-trip
    }
    return ref.watch(listingRepositoryProvider).fetchListingByEventId(eventId); // cold deep-link path
  }

  Future<void> _refreshInBackground(String eventId) async {
    final fresh = await ref.read(listingRepositoryProvider).fetchListingByEventId(eventId);
    if (state.value != fresh) state = AsyncData(fresh);
  }
}
```

`go_router_builder`'s `$extra` convention is used specifically because `Listing` isn't (and shouldn't be) URL-encoded — it's an in-memory-only optimization. A cold start, push-notification tap, or shared-link deep link into `/event/:eventId` has no `$extra` and falls back to the network/cache fetch path automatically — the same route class handles both cases correctly.

**Deep linking:** `flutter_local_notifications`'s tap handler and `share_plus` links both resolve to `context.go('/event/$eventId')` (no `$extra`, triggering the cold-fetch branch). Auth-gated routes (`/profile`, `/watchlist`) use `GoRouter(redirect: ...)` driven by a `GoRouterRefreshStream(ref.read(authControllerProvider.notifier).stream)`, so auth changes trigger router re-evaluation without polling.

---

## 6. Offline / Caching Strategy

### Decision: Hive (`hive_flutter` + `hive_generator`), not Isar

1. **Access pattern fit.** The only offline needs are keyed lookups and small full-box reads — Watchlist by `showtimeId`, Home feed cache by category key, a single-row Profile snapshot. This is a pure key-value shape. Isar's relational query engine (where-clauses, compound indexes, links) solves a problem this app doesn't have.
2. **Platform footprint.** The repo already builds desktop targets for every app (`linux/`, `macos/`, `windows/` folders exist per app). Hive is pure Dart with no native binary; Isar ships a native core library per platform that must be bundled and verified on each target — extra packaging risk for zero functional benefit here.
3. **Reactivity maps directly onto Riverpod.** `box.watch()` returns a `Stream<BoxEvent>` a controller can `listen()` to and `ref.invalidateSelf()` on — exactly the primitive `WatchlistController` (§4) already uses. No adapter layer needed.
4. **Combined tooling risk.** The team is simultaneously absorbing `riverpod_generator` and `go_router_builder`. Hive's codegen (`TypeAdapter` via `hive_generator`) is materially simpler than Isar's collection/schema generator, keeping total new-tool surface area lower for one migration. Isar's original maintainer also paused active development in 2024 — a supply-chain risk not worth taking on for a package this central to cold-start UX.

Isar would be the right call only if NextShow needed complex on-device querying (e.g. full offline text search across thousands of cached events with compound filters) — it doesn't; the offline surface is narrow by design.

### Box schema (`core/cache/models/`, in `apps/user_app` — only this app needs offline-first UX today)

| Box | Key | Value | Purpose |
|---|---|---|---|
| `watchlist` | `showtimeId` | `WatchlistEntry {showtimeId, eventId, listingSnapshotJson, savedAt, priceAlertEnabled, availabilityAlertEnabled, lastKnownPriceCents}` | instant Watchlist render, alert state |
| `listing_cache` | `cacheKey` (e.g. `home:all`, `home:movie`) | `CachedListingPage {cacheKey, listingsJson, fetchedAt}` | instant Home feed render |
| `profile_cache` | `userId` | `ProfileSnapshot` | instant Profile tab render |
| `search_history` | auto-increment | `SearchHistoryEntry {query, askedAt}` | AI concierge continuity |
| `app_meta` | string | dynamic | `lastSyncAt`, `hiveSchemaVersion` for future migrations |

TypeIds are centrally allocated in `core/cache/hive_registrar.dart` to prevent collisions as boxes grow.

### Invalidation / refresh policy

- **Soft TTL** on `listing_cache`: 5 minutes. Stale cache renders instantly (no spinner) while a background refresh runs.
- **Hard fallback**: on fetch failure (checked via `connectivityProvider`), keep serving cache indefinitely with a persistent `ConnectivityBanner` ("Offline — showing saved results"); the UI is never blanked on a realtime/network error.
- **Watchlist never TTL-expires** (user-owned data). Instead, `WatchlistScreen` opportunistically re-fetches each tracked `showtimeId`'s current price/status on open, diffing against `lastKnownPriceCents` to fire a local notification on a drop, and updates the stored snapshot.

### Composition with Supabase Realtime (cache-then-network, stream-first with cache fallback)

`ListingRepositoryImpl.watchListings({category})`:
1. Emit the Hive `CachedListingPage` synchronously if present (zero-latency first frame), even if stale.
2. Call `NextShowSupabaseClient.fetchActiveListings(category: category)`, write-through to Hive, emit the fresh list.
3. Open one realtime channel (via the consolidated `NextShowSupabaseClient.watchListings(...)` from §3) on `events`/`showtimes`/`venues`; on each change, patch just the affected showtime via a targeted `v_listings` point query by `showtime_id`. This directly fixes today's `EventRepository.streamLiveEvents()` behavior, which does a **full table re-fetch on any change** — an inefficiency worth calling out and correcting here.
4. On any stream/network error, swallow it and keep emitting the last Hive snapshot already on the stream — realtime disconnects never blank the screen.

This is the concrete mechanism behind `HomeFeedController.build()`'s `Stream<List<Listing>>` in §4.

---

## 7. Interactive Seat Matrix Blueprint

This is architected in full now, per the founder's accelerated roadmap — designed to stay venue/ticketing-backend agnostic (matching `docs/plan.md`'s own "adapter layer, not a custom system per cinema" principle), and to ship disconnected from live booking until explicitly greenlit (see §8's `booking_mode` flag).

### New Postgres tables

```sql
create type seat_status as enum ('available', 'held', 'sold', 'blocked');
create type seat_type as enum ('standard', 'premium', 'wheelchair', 'companion', 'recliner', 'sofa');

create table public.venue_layouts (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz default now() not null,
    updated_at timestamptz default now() not null,
    venue_id uuid references public.venues(id) on delete cascade not null,
    name text not null,                      -- "Hall 1", "Saal A"
    layout_version int default 1 not null,
    source text default 'manual' not null,   -- 'manual' | 'organizer_api' | 'imported'
    external_ref text,                       -- id in the organizer's own ticketing backend (adapter key)
    metadata jsonb default '{}'::jsonb,
    is_active boolean default true
);

create table public.seat_sections (
    id uuid primary key default gen_random_uuid(),
    venue_layout_id uuid references public.venue_layouts(id) on delete cascade not null,
    label text not null,                     -- "Orchestra", "Balcony", "Standing"
    sort_order int default 0 not null,
    seat_type seat_type default 'standard' not null,
    base_price_cents int,
    color_hex text,
    metadata jsonb default '{}'::jsonb
);

create table public.seats (
    id uuid primary key default gen_random_uuid(),
    seat_section_id uuid references public.seat_sections(id) on delete cascade not null,
    venue_layout_id uuid references public.venue_layouts(id) on delete cascade not null, -- denormalized for fast lookup
    row_label text not null,                 -- "A"
    seat_number text not null,               -- "12" (text, to support "12a" split seats)
    seat_type seat_type default 'standard' not null,
    x numeric not null,                      -- normalized 0..1 layout-relative coordinate
    y numeric not null,
    rotation numeric default 0,              -- degrees, for curved rows
    is_accessible boolean default false,
    price_cents int,                         -- overrides section base_price_cents
    unique (venue_layout_id, row_label, seat_number)
);
create index idx_seats_layout on public.seats(venue_layout_id);

-- Availability is per-showtime, not per-layout
create table public.showtime_seats (
    id uuid primary key default gen_random_uuid(),
    showtime_id uuid references public.showtimes(id) on delete cascade not null,
    seat_id uuid references public.seats(id) on delete cascade not null,
    status seat_status default 'available' not null,
    price_cents int,                         -- showtime-specific dynamic-pricing override
    updated_at timestamptz default now() not null,
    unique (showtime_id, seat_id)
);
create index idx_showtime_seats_lookup on public.showtime_seats(showtime_id, status);

-- Ephemeral TTL locks, prevent double-booking during checkout
create table public.seat_holds (
    id uuid primary key default gen_random_uuid(),
    showtime_seat_id uuid references public.showtime_seats(id) on delete cascade not null,
    held_by uuid references auth.users(id) on delete cascade,
    session_token text not null,             -- pre-auth session identifier
    created_at timestamptz default now() not null,
    expires_at timestamptz not null,
    unique (showtime_seat_id)
);
create index idx_seat_holds_expiry on public.seat_holds(expires_at);

alter table public.venues add column if not exists booking_mode text default 'outlink' not null; -- 'outlink' | 'native_seat_select'
alter table public.showtimes add column if not exists venue_layout_id uuid references public.venue_layouts(id);
```

A scheduled `expire_seat_holds()` function (pg_cron) flips expired holds' seats back to `available` — documented now, wired only when Phase 2 goes live.

### Seat-layout JSON schema (organizer backend → app ingest, `SeatMapPayload`)

```json
{
  "venueLayoutId": "uuid",
  "venueId": "uuid",
  "name": "Hall 1",
  "layoutVersion": 3,
  "sections": [
    {
      "id": "uuid",
      "label": "Orchestra",
      "seatType": "standard",
      "basePriceCents": 1200,
      "colorHex": "#2563EB",
      "seats": [
        {
          "id": "uuid",
          "rowLabel": "A",
          "seatNumber": "1",
          "seatType": "standard",
          "x": 0.12,
          "y": 0.40,
          "rotation": 0,
          "isAccessible": false,
          "priceCents": 1200,
          "status": "available"
        }
      ]
    }
  ],
  "generatedAt": "2026-08-24T10:00:00Z"
}
```

### Dart models (`shared/core_models/lib/src/seat_models.dart`, freezed)

```dart
enum SeatStatus { available, held, sold, blocked }
enum SeatType { standard, premium, wheelchair, companion, recliner, sofa }
enum BookingMode { outlink, nativeSeatSelect }

@freezed
class VenueLayout with _$VenueLayout {
  const factory VenueLayout({
    required String id,
    required String venueId,
    required String name,
    required int layoutVersion,
    required List<SeatSection> sections,
    @Default({}) Map<String, dynamic> metadata,
  }) = _VenueLayout;
  factory VenueLayout.fromJson(Map<String, dynamic> json) => _$VenueLayoutFromJson(json);
}

@freezed
class SeatSection with _$SeatSection {
  const factory SeatSection({
    required String id,
    required String label,
    required SeatType seatType,
    int? basePriceCents,
    String? colorHex,
    required List<Seat> seats,
  }) = _SeatSection;
  factory SeatSection.fromJson(Map<String, dynamic> json) => _$SeatSectionFromJson(json);
}

@freezed
class Seat with _$Seat {
  const factory Seat({
    required String id,
    required String rowLabel,
    required String seatNumber,
    required SeatType seatType,
    required double x,
    required double y,
    @Default(0) double rotation,
    @Default(false) bool isAccessible,
    int? priceCents,
    @Default(SeatStatus.available) SeatStatus status,
  }) = _Seat;
  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);

  const Seat._();
  String get accessibilityLabel =>
      'Seat $rowLabel$seatNumber, ${seatType.name}, ${status.name}'
      '${priceCents != null ? ", ${(priceCents! / 100).toStringAsFixed(2)} euro" : ""}';
}

@freezed
class SeatHold with _$SeatHold {
  const factory SeatHold({
    required String showtimeSeatId,
    required DateTime expiresAt,
    required String sessionToken,
  }) = _SeatHold;
  factory SeatHold.fromJson(Map<String, dynamic> json) => _$SeatHoldFromJson(json);
}
```

### Widget architecture: InteractiveViewer (pan/zoom) wrapping a single CustomPainter canvas

**Decision:** not a widget-per-seat grid. A venue can have 500–2000+ seats. A `Wrap`/`GridView` of one `GestureDetector`+`Container` per seat means that many `RenderObject`s participate in layout and hit-testing on every frame during a continuous pan/zoom gesture — incompatible with a 120Hz budget. A single `CustomPainter.paint()` batches all seats into grouped `canvas.drawCircle`/`drawRRect` calls by status color, which is dramatically cheaper. `InteractiveViewer` is used only for its solved problem (pan/zoom physics, inertia, scale bounds) — seat rendering and hit-testing are fully custom.

- **Tap-to-select**: `GestureDetector.onTapUp` converts the tap offset via `transformationController.toScene(localPosition)` into painter-space coordinates, then does a nearest-seat lookup against a grid-bucketed spatial index (bucketed by rounded x/y) rather than a linear scan — keeps hit-testing near O(1) even for large maps.
- **Selection state**: `SeatSelectionController` (keyed by `showtimeId`) holds `Set<String> selectedSeatIds` + `Map<String, SeatStatus> liveStatusOverrides` (patched by realtime). The painter's `shouldRepaint` compares a small immutable snapshot value object, not a deep list diff every frame.
- **Color coding**: available = outline/white; held = amber with a lightweight pulse limited to just the held seats' paint pass; sold = disabled gray; blocked = dashed hatch; selected = filled brand blue with a check glyph.
- **Accessibility**: per-seat `Semantics` nodes on a canvas don't scale to thousands of seats, and CustomPainter content is invisible to screen readers by default. **A "Switch to list view" toggle** renders the identical seat data as a real scrollable `ListView` grouped by section/row, each seat a proper `Semantics(label: seat.accessibilityLabel, button: true, selected: ...)` tappable row — this satisfies screen-reader operability without paying the cost of thousands of Semantics nodes in the default canvas view.
- **Booking/hold API** (architected now, disconnected today): `selectSeat(seatId)` optimistically toggles locally; "Reserve" calls `seatHoldRepository.holdSeats(showtimeId, selectedSeatIds)` → optimistic UI marks seats `held` with a visible TTL countdown (`SeatHold.expiresAt`, default 5 min) → server confirms via a `seat_holds` insert + status flip on `showtime_seats` → the realtime channel on that showtime patches any other concurrent viewer's UI to also show those seats held → on TTL expiry (confirmed by the following realtime event), the controller reverts the optimistic seats. **Today**, this repository is backed by `MockSeatMapDataSource` returning a fixture `SeatMapPayload`, reachable only via an internal debug route — fully disconnected from the production booking pipeline (Phase 4, §11).

---

## 8. Hybrid Booking Pipeline (Phase 1 → Phase 2)

- Replace the current `BookingService.launchBookingUrl` (url_launcher-only, always exits to the external browser) with `webview_flutter`-based `BookingWebViewScreen`.
- `BookingController.launch(listing)`:
  1. Record the click via an **extended** `outbound_clicks` table (additive migration: `session_id text`, `utm_source text default 'app'`, `utm_medium text default 'outlink_webview'`, `device_platform text`) — keeps the existing table/RLS, adds conversion-funnel-ready columns.
  2. Build the outlink URI appending `ref=nextshow`, `utm_source=nextshow_app`, `utm_medium=outlink`, `utm_campaign={category}`, and `ns_session={clickId}` (the new click row's id). This is the concrete meaning of "maintain session state": since NextShow doesn't control the affiliate's checkout, session correlation is **best-effort param echoing, not a guarantee** — worth stating plainly rather than overpromising.
  3. Push `BookingOutlinkRouteData(showtimeId, $extra: listing)`, opening a `WebViewWidget` pointed at the built URI.
- **Chrome**: AppBar with venue/event title + close button; a persistent bottom "Return to NextShow" pill (per the target UX brief) that pops back to Event Detail instantly — trivial to implement since the webview is just one route pushed on top of the existing navigation stack; nothing is lost by leaving and returning, since the app process itself never exits.
- **Fallback**: if `webview_flutter` fails to load (some affiliate sites send `X-Frame-Options`/anti-embed headers), detected via `NavigationDelegate.onWebResourceError`/`onHttpError`, show an inline error state with a button that falls back to today's `url_launcher` external-browser flow — preserving current behavior as a safety net rather than a regression.
- **`bookingMode` flag**: `venues.booking_mode text default 'outlink'` (`'outlink' | 'native_seat_select'`), denormalized into `v_listings` (`v.booking_mode`) so `Listing.bookingMode` is available without a join. Event Detail's CTA branches:

```dart
onPressed: () => switch (listing.bookingMode) {
  BookingMode.outlink => BookingOutlinkRouteData(showtimeId: listing.showtimeId, $extra: listing).push(context),
  BookingMode.nativeSeatSelect => SeatSelectionRouteData(showtimeId: listing.showtimeId).push(context),
},
```

Every venue stays `'outlink'` until an admin/organizer flips the flag — meaning the seat-matrix code can ship fully built in Phase 4 with **zero production routing risk**, since no venue opts in until the founder greenlights it.

---

## 9. New Screens / Features Mapping

- **Home / For You** (`features/discovery`): personalization from `currentProfileProvider.preferredCategories`/`favoriteVenueIds`, plus watchlist categories as an implicit signal, plus geolocation. Trending needs a small `v_trending_showtimes` view (rank by 7-day `outbound_clicks` count); "live gigs" = `category in (music, comedy)` starting within 48h; "nearby" reuses the existing `fetch_listings_nearby` RPC already in `NextShowSupabaseClient.fetchActiveListings`.
- **Search & AI Concierge** (`features/search`): one screen, persistent search bar (mic + text), horizontal facet chip row opening `FacetFilterSheet`; natural-language queries route to `AiConciergeController`, filter taps route to `FacetedSearchController`; both render into the same `NSEventCard`-based result list.
- **Watchlist / Saved** (`features/watchlist`): `WatchlistEntry` list from Hive, alert toggles via `AlertSettingsSheet` (§6 data model).
- **Profile & Settings** (`features/profile`): booking history = `outbound_clicks` joined to showtimes/events for the current user, labeled honestly as "Recently Viewed Bookings" in UI copy — Phase 1 has no purchase confirmation, so the copy shouldn't overpromise. Favorite genres/artists = existing `profiles.preferred_categories` + new additive `profiles.favorite_artist_ids text[]`. Notification prefs = new additive `profiles.notification_prefs jsonb default '{}'::jsonb`, mirrored to `flutter_local_notifications` channel subscriptions. Ticket storage = Phase 1 placeholder `SavedTicketStub` (Hive: `{showtimeId, bookingUrlVisitedAt, addToCalendarAdded}`) so the data contract exists before Phase 2 real tickets.
- **Event Detail** (`features/event_detail`): trailer via `youtube_player_flutter` (sourced from `event.metadata['trailer_key']`, already populated by existing TMDB ingestion) with `cached_network_image` poster fallback; venue map via `flutter_map` (see §10 justification); social proof via a Supabase **Presence** channel (a new use of Realtime, not Postgres Changes) for a live "N people viewing" count, plus `event.metadata['tmdb_rating']`; micro-interactions: `NotifyMeButton` (writes a `WatchlistEntry` with `availabilityAlertEnabled=true`), `AddToCalendarButton` (`add_2_calendar`), `SaveToCollectionButton` (`WatchlistController.toggle`), `ShareButton` (`share_plus`, sharing `https://nextshow.berlin/event/{eventId}` resolved by go_router).

---

## 10. UI / Animation System

`ui_kit` build-out (all in `shared/ui_kit/lib/src/`):

- `motion.dart`: `NSDurations` (fast=150ms, medium=300ms, slow=500ms), `NSCurves` (emphasized easing) — every `flutter_animate` chain references these instead of magic numbers.
- `skeletons.dart`: `NSShimmerSkeleton` (wraps `shimmer` with `NSColors.border`/`NSColors.iceBlue`), plus `NSEventCardSkeleton`/`NSListingRowSkeleton` matching `NSEventCard`'s exact layout so the shimmer-to-content swap has zero layout jump.
- `glass.dart`: `NSGlassCard` (`BackdropFilter` + blur + translucent gradient border) for the glassmorphism treatment — used on the bottom nav bar, event-detail hero overlay, and the AI concierge input bar.
- `lottie_assets.dart`: catalogued Lottie keys for empty states, an AI-thinking indicator, and an "Added to Watchlist" success check.
- `NSBottomNavBar`: animated selection pill (`AnimatedAlign`) + icon bounce on tab switch, consumed directly by `shell/bottom_nav_shell.dart`.
- `nsDarkTheme`: mirrors `nsTheme` with a dark `ColorScheme`; wired via `MaterialApp.router(theme: nsTheme, darkTheme: nsDarkTheme, themeMode: ThemeMode.system)`.

**Application:** full-screen/list loading states (`HomeFeedController`/`AiConciergeController`'s `AsyncValue.loading()`) render skeleton lists, not a bare spinner — `NSLoading` stays reserved for inline button-level loading only. Route transitions use a shared `CustomTransitionPage` (`NSPageTransitions.slideUpFade`) for pushed routes (event detail, booking webview, seat selection); bottom-nav tab switches stay instant/untransitioned by design, matching `StatefulShellRoute`'s default native tab-bar feel.

Since `ui_kit` is currently **declared but entirely unused** in `user_app`, wiring its existing 723 lines into `main.dart`'s theme and the current screens is Phase 0 work (§11), done *before* adding any new widgets — so the team isn't building new design-system pieces on top of an unverified integration path.

**Maps recommendation:** `flutter_map` (OSM tiles) over `google_maps_flutter`. A Berlin-only app has no need for Google's billing/API-key management, and `flutter_map` has no native-SDK setup burden across the build targets already present per app (android/ios/linux/macos/windows folders exist for `user_app`, `organizer_app`, and `admin_app` alike), whereas `google_maps_flutter` needs per-platform key wiring on all of them.

---

## 11. Migration Phases

**Phase 0 — Dead-code removal + ui_kit wiring** *(no new architecture)*
- Delete `screens/movies_screen.dart` + `services/api_service.dart` (orphaned pair); delete `models/event_model.dart`, repointing `event_repository.dart`/screens to `core_models`'s `Event`/`Listing` (this also kills the `EventCategory.movies` vs. `EventCategory.movie` divergence).
- Rewrite `EventRepository.fetchLiveEvents()` to call `NextShowSupabaseClient.fetchActiveListings(...)` instead of hand-parsing raw `v_listings` rows.
- Wire `ui_kit.nsTheme` into `main.dart`; swap ad-hoc widgets in `browse_screen.dart`/`event_detail_screen.dart`/`home_screen.dart` for existing `NSEventCard`/`NSCategoryFilter`/`NSShowtimeChip`/`NSLoading`/`NSEmptyState`/`NSErrorState` — adoption only, no new ui_kit widgets yet.
- Add all new pubspec dependencies (`flutter_riverpod`, `riverpod_generator`, `riverpod_annotation`, `build_runner`, `go_router`, `go_router_builder`, `hive`, `hive_flutter`, `hive_generator`, `flutter_animate`, `shimmer`, `lottie`, `cached_network_image`, `webview_flutter`, `youtube_player_flutter`, `add_2_calendar`, `share_plus`, `flutter_local_notifications`, `flutter_map`, `latlong2`, `connectivity_plus`).
- **Done when:** app builds/runs with no visual regression (ui_kit now actually applied), dead code gone, new deps present but inert.

**Phase 1 — Riverpod + go_router skeleton + bottom nav shell**
- `ProviderScope` in `main.dart`; `MaterialApp` → `MaterialApp.router`; implement `BottomNavShellRouteData` with 4 branches (Watchlist/Profile as placeholder screens initially). Migrate `AuthService` → `AuthController`; migrate `EventRepository`/`BookingService` call sites in Browse/Event Detail to Riverpod controllers (Booking stays url_launcher-only — webview comes Phase 3).
- **Done when:** a real persistent 4-tab bottom nav exists, zero remaining `Navigator.push(MaterialPageRoute)`, zero remaining raw `setState`+`EventRepository()` on migrated screens, `/event/:eventId` deep link works.

**Phase 2 — Watchlist + Profile with Hive**
- Full `features/watchlist` and `features/profile`; cache-then-network Home feed per §6, fully replacing `EventRepository.streamLiveEvents()`; add `profiles.notification_prefs`/`favorite_artist_ids` migrations.
- **Done when:** Home and Watchlist render instantly from cache; airplane-mode test passes (offline banner, last-known data, no blank screen).

**Phase 3 — Rich Event Detail + webview outlink booking**
- Full `features/event_detail` (trailer, map, social proof, micro-interactions); `BookingWebViewScreen` replacing url_launcher-only flow; extended `outbound_clicks` columns; `booking_mode` flag + `v_listings` update.
- **Done when:** "Book Now" opens an in-app webview for all venues (all still `outlink`); Add to Calendar/Share verified end-to-end.

**Phase 4 — Seat Matrix blueprint scaffolding** *(UI-only, disconnected)*
- DB migration for `venue_layouts`/`seat_sections`/`seats`/`showtime_seats`/`seat_holds` (schema only, one manually-seeded demo venue); full `features/seat_selection` per §7, reachable only via an internal debug route.
- **Done when:** the seat matrix is demoable standalone, pan/zoom/tap/select is smooth on a mid-range device profile, and it has zero effect on production booking (no venue has `booking_mode='native_seat_select'`).

**Phase 5 — AI Concierge upgrade**
- Move Gemini calls behind a Supabase Edge Function (`supabase/functions/ai-concierge`), retiring client-side `google_generative_ai` key exposure; build full `features/search` (voice+text+facets), porting `voice_input_service.dart`'s working silence-detection workaround as-is.
- **Done when:** the Search tab fully replaces the old category grid, and no API key ships in the client bundle.

**Phase 6 — Polish / production hardening**
- Dark mode, glassmorphism pass, Lottie empty states, animation-consistency audit against `NSDurations`/`NSCurves`, accessibility audit (seat matrix list-view mode + all new screens), DevTools frame-timing pass on Home scroll + seat matrix pan/zoom.
- **Done when:** founder sign-off against the original UX brief.

---

## 12. Critical Files Reference

- `apps/user_app/lib/main.dart`
- `shared/core_models/lib/core_models.dart`
- `shared/supabase_client/lib/supabase_client.dart`
- `shared/ui_kit/lib/ui_kit.dart`
- `docs/schema.sql`

---

*This document is a review artifact. No source code, pubspec, or configuration files were modified to produce it. Implementation begins only after founder sign-off, phase by phase per §11.*
