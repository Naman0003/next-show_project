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
| Language/format badges (OV, OmU, 3D, IMAX) | [ ] | From `showtimes.attributes` JSONB |
| Trust signals ("Updated 15 min ago", partner badge) | [ ] | Addresses plan Question O |
| Deep-link to exact screening (screening-specific booking URLs) | [ ] | Depends on cinema partners providing unique URLs |

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
| `core_models`: Venue, Event, Showtime, User, Category enums | [x] | Shared across all 3 apps |
| `supabase_client`: Typed query helpers, Realtime subscriptions | [x] | Initialize client, type-safe queries |
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

## Infrastructure & Ops

| Task | Status | Notes |
|------|--------|-------|
| Set up scheduled ingestion (cron: hourly/daily per cinema) | [ ] | Question L: update frequency |
| Monitoring/alerting for stale data | [ ] | Question O: trust = no outdated info |
| CI/CD pipeline for all 3 apps | [ ] | Build, test, deploy |
| Document API keys / secrets management | [ ] | Currently in `shared/api_keys.dart` |
| Google Places API integration for venue address autocomplete | [ ] | P2 - Add to organizer_app venue form later |
| S3/Cloud Storage bucket for venue/event images | [ ] | P1 - Supabase Storage or AWS S3 for photo uploads |

---

## Backlog / Future Phases

| Task | Status | Notes |
|------|--------|-------|
| Phase 4: Booking integration (affiliate/referral tracking) | [ ] | Questions S/T/U/V |
| Phase 5: Native ticketing (payments, seats, inventory) | [ ] | Questions W/X/Y — only after traction |
| Multi-city expansion | [ ] | Beyond Berlin |
| Recommendation engine v2 (collaborative filtering) | [ ] | Beyond Gemini prompt-based |