# NextShow × Cinema Integration — Task Tracker

> **Convention**: Tasks are tracked here with priority and status. Update this file as work progresses.
>
> **Status Legend**:
> - `[ ]` **PENDING** — Not started
> - `[~]` **IN PROGRESS** — Actively being worked on
> - `[x]` **COMPLETED** — Done and verified
> - `[!]` **BLOCKED** — Waiting on external dependency or decision
>
> **Priority**: `P0` (Critical path) → `P1` (High) → `P2` (Medium) → `P3` (Nice to have)

---

## Phase 1 — Discovery: Aggregate 3–5 Berlin Cinemas

### Data Ingestion & Pilot Onboarding (P0)

| Task | Status | Notes |
|------|--------|-------|
| Design cinema data adapter architecture (interfaces + normalizers) | [ ] | Adapter layer: each cinema source → standard Supabase schema |
| Build ingestion script/service (Dart/Node/Python) | [ ] | Fetches from APIs/CSV/feeds → upserts to Supabase |
| Identify & contact 3–5 Berlin independent cinemas | [ ] | Bizdev: need name, address, programme, booking URLs |
| Seed Supabase with real pilot cinema data | [ ] | Use `v_listings` view structure from schema.sql |
| Create partner dashboard in Admin App (venue/showtime CRUD) | [ ] | Allows cinemas to self-manage; onboards in minutes |

### Comparison & Polish (P1)

| Task | Status | Notes |
|------|--------|-------|
| Build cross-cinema comparison table UI | [ ] | Table: Cinema \| Time \| Price \| Distance \| Language \| Book |
| Add distance calculation (PostGIS ST_Distance) | [ ] | Show "2.4 km" from user location or Berlin center |
| Language/format badges (OV, OmU, 3D, IMAX) | [x] | Displayed on showtime cards via `showtime_attributes` JSONB |
| Trust signals ("Updated 15 min ago", partner badge) | [ ] | Addresses plan Question O |
| Deep-link to exact screening (screening-specific booking URLs) | [x] | Mandatory direct booking URL enforced in ShowtimeFormScreen |

---

## Phase 2 — Intelligent Discovery

| Task | Status | Notes |
|------|--------|-------|
| Enhance AI prompt with structured filters (location, price, time) | [ ] | Pre-filter or prompt-level constraints |
| Build "Night Out" composer (movie → dinner → drinks) | [ ] | Anchor concept from plan Section 6 |
| Search/click analytics dashboard | [ ] | Track queries, clicks, bookings via `outbound_clicks` |

---

## Shared Packages — Real Implementation

| Task | Status | Notes |
|------|--------|-------|
| `core_models`: Venue, Event, Showtime, User, Category enums | [x] | Shared across all 3 apps; added `isVerified` to `Event` |
| `supabase_client`: Typed query helpers, Realtime subscriptions | [x] | Initialize client, type-safe queries; `isVerified` persisted |
| `ui_kit`: EventCard, CinemaCard, ShowtimeChip, CategoryFilter, NextShowButton | [x] | Reusable, themed components |

---

## Admin & Organizer Apps — Scope Definition

| Task | Status | Notes |
|------|--------|-------|
| Define Admin App scope & screens | [ ] | Partner mgmt, content moderation, analytics, config |
| Define Organizer App scope & screens | [x] | Event creation, venue mgmt, showtime scheduling |
| Scaffold Admin App with real structure | [ ] | Replace default Flutter counter demo |
| Scaffold Organizer App with real structure | [x] | Full partner portal, venues, events, showtimes CRUD |

---

## Organizer App — Partner Workflow Features

| Task | Status | Notes |
|------|--------|-------|
| Mandatory TMDB movie search (no blank text input for movie title) | [x] | Fields disabled until TMDB movie selected or custom mode chosen |
| Metadata auto-lock (Title, Poster, Synopsis, Runtime, Director, Genres) | [x] | Fields read-only once TMDB movie bound; shown with 🔒 icon |
| Custom Indie / Festival movie fallback form | [x] | "Add Custom Movie" unlocks editable fields; sets `is_verified: false` |
| Custom movie external reference URL (mandatory for unverified) | [x] | Letterboxd / IMDb / Festival program link required |
| `is_verified` flag on `public.events` table | [!] | **Run SQL migration in Supabase** — see schema.sql / walkthrough.md |
| `is_verified` exposed in `v_listings` view | [!] | **Included in same SQL migration block** |
| Showtime: Screen / Hall Name field | [x] | e.g. "Hall 1", "Kino 3" stored in `showtime.attributes` |
| Showtime: Audio/Subtitle tag choice chips (OmU, OmeU, DF, OV) | [x] | Structured choice chips in ShowtimeFormScreen |
| Showtime: Screening format choice chips (2D, IMAX, 35mm, etc.) | [x] | `format` stored in `showtime.attributes` |
| Showtime: Mandatory direct booking URL | [x] | HTTP/HTTPS validated before save |
| Showtime: Rich cards showing movie title + poster + format badges | [x] | ShowtimeListScreen updated |
| "Schedule Showtime" shortcut after event creation | [x] | Auto-navigates to ShowtimeFormScreen post-create |
| "Schedule Showtime for this Event" button on EventDetailScreen | [x] | Primary CTA on detail screen |
| TMDB Dio failover (multi-host, errno 104 fix) | [x] | Failover from `api.themoviedb.org` → `api.tmdb.org` |
| Remove `_fallbackCatalog` (show empty state instead) | [x] | Returns `NSEmptyState` widget when search yields no results |
| OTP code length fix (8 digits instead of 6) | [x] | Updated auth screens to accept 8-digit Supabase OTP |
| Home screen Upcoming Showtimes overflow fix | [x] | Bounded height + scroll on the showtimes box |
| Quick Actions grid uniform tile sizes | [x] | `Add Venue`, `Create Event`, `New Showtime` equal-width tiles |
| Showtime card shows movie title (not just time) | [x] | Prevents confusion when multiple movies share a schedule |
| TMDB search box overflow in header row | [x] | Fixed with `overflow: TextOverflow.ellipsis` + smaller badge padding |
| Clean Movie Search UX (unbranded TMDB) | [x] | Tap-to-search field, "Find a Movie" sheet, "Didn't find your movie? Add a custom movie" fallback |
| Showtime list Realtime subscription | [x] | Replaced FutureBuilder with Supabase Realtime stream for instant list sync |
| FAB Hero tag conflicts resolved | [x] | Assigned unique heroTags (`fab_new_venue`, `fab_new_showtime`, `fab_new_event`) to FABs |
| Git untracked `.idea` folder | [x] | Cleared cached index and committed `.idea` directory |
| Fix `setState()` called after `dispose()` in `ShowtimeFormScreen` | [x] | Add liveness checks (`mounted`) before updating dropdown data |

---

## Infrastructure & Ops

| Task | Status | Notes |
|------|--------|-------|
| Set up scheduled ingestion (cron: hourly/daily per cinema) | [ ] | Question L: update frequency |
| Monitoring/alerting for stale data | [ ] | Question O: trust = no outdated info |
| CI/CD pipeline for all 3 apps | [ ] | Build, test, deploy |
| Document API keys / secrets management | [ ] | Currently in `shared/api_keys.dart` |
| Google Places API integration for venue address autocomplete | [ ] | P2 - Add to organizer_app venue form later |
| S3/Cloud Storage bucket for venue/event images | [ ] | P1 - Supabase Storage or AWS S3 for photo uploads |
| Gradle 8.13 + AGP 8.11.1 + Java 17 upgrade | [x] | Both apps; JVM heap tuned (-Xmx4G) |
| RLS infinite recursion fix (PostgreSQL 42P17) | [x] | `is_admin()` / `is_partner()` SECURITY DEFINER helpers |

---

## Backlog / Future Phases

| Task | Status | Notes |
|------|--------|-------|
| Phase 4: Booking integration (affiliate/referral tracking) | [ ] | Questions S/T/U/V |
| Phase 5: Native ticketing (payments, seats, inventory) | [ ] | Questions W/X/Y — only after traction |
| Multi-city expansion | [ ] | Beyond Berlin |
| Recommendation engine v2 (collaborative filtering) | [ ] | Beyond Gemini prompt-based |