# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

<!-- One custom NextShow design language ships on both iOS and Android (not
per-OS adaptation). Material 3 governs structure, navigation, and interaction;
brand expresses through Material theming. On iPhone hardware the app still owes
iOS its OS guarantees: safe-area insets, Reduce Motion, edge-swipe back. -->

## Users

Primary: Gen Z consumers in Berlin, on their phone, deciding "what can I do
tonight?" — often last-minute, frequently with one or two friends, budget-
conscious (e.g. "under €25 for three"), and location-aware down to the
neighborhood (Neukölln, Kreuzberg). They currently piece this together across
Google, Instagram, Eventbrite, DICE, and individual cinema sites.

Secondary (not this surface): independent Berlin cinema operators who self-manage
their programme through the organizer app.

## Product Purpose

NextShow is the decision layer for going out in a city: **discover → compare →
go to book**. The consumer app aggregates what's on — starting with cinema, then
comedy, music, theatre, sports — and lets people compare their real options
(film, venue, time, price, distance, language) and deep-link to the exact
screening's booking page. NextShow owns discovery; the venue owns the transaction.

First milestone success: someone in Berlin opens NextShow, sees cinema alongside
other experiences, compares options, and actually goes somewhere because of it.

## Positioning

Germany has no consumer platform that brings a city's cinema options together
with the rest of what's on *and* lets people compare across venues. Two things a
neighboring product cannot easily copy:

- **Cinema as the anchor for a whole night out.** Time + location + duration +
  price compose into "dinner at 17:45 nearby → film at 19:30 → drinks at 22:00",
  not just isolated listings.
- **An adapter layer that normalizes every venue's data** (API, feed, CSV, or
  manual entry) into one shape — Film → Cinema → Screening → Time → Price →
  Language → Booking — so scaling from 5 to 100 venues does not mean 100
  codebases.

Deliberate bias toward small, independent local venues: visibility for places
people don't already know exist.

## Operating Context

- Mobile, in-city, same-day decisions; often in a group with a spending ceiling.
- Filtering by neighborhood/distance and by language/format is central, not a
  detail: OV (Original Version), OmU (Original with German subtitles), OmeU
  (Original with English subtitles), DF (German dub).
- Booking completes off-platform on the cinema's own site via an in-app webview
  with a "Return to NextShow" bar; outbound clicks are attributed with UTM params
  and recorded (`outbound_clicks`).
- Partner cinemas self-serve their programme via the organizer dashboard;
  onboarding target is minutes, not days.
- Freshness is existential — a stale showtime or price breaks trust and the
  product. Surfaces should carry provenance ("updated 15 min ago", partner badge).

## Capabilities and Constraints

- **Phase 1 (current):** discovery + comparison + outbound booking links only.
  No payments, seat selection, ticket inventory, refunds, or cancellations.
- **Data:** Supabase Postgres — `events` (films), `venues` (PostGIS location),
  `showtimes` (JSONB `attributes`: hall, format 2D/3D/IMAX/35mm/70mm/4K, audio
  OmU/OmeU/DF/OV), `v_listings` flattened view, `outbound_clicks`.
- **Film de-duplication** across title variants ("The Substance" / "THE
  SUBSTANCE" / "The Substance (2024)") is a known unsolved problem.
- Movie metadata (title, synopsis, poster, runtime, director, genres) is
  auto-fetched from external APIs and locked read-only for verified titles;
  custom/unverified titles require an external reference link (IMDb, Letterboxd)
  and go to admin moderation (`is_verified: false`).
- **Seat-selection module** is fully architected (models, `CustomPainter` matrix
  UI, Postgres/JSON schema contracts) but deliberately disconnected from live
  booking — reachable only via a debug route.
- **AI Concierge** ("something fun tonight, two friends, under €25, near
  Neukölln") is contract-defined against a Supabase Edge Function but currently
  runs a mock; the old client-side Gemini key is dead code pending removal.
- **Bilingual from launch:** the entire app must ship fully localized in both
  German and English (user-switchable, locale-aware dates/times/prices). Not a
  later-phase add — every new surface, string, and empty/error state is authored
  with both locales in mind, and layouts must absorb German text expansion.
- **Undecided product facts** (do not resolve by inventing): legal/technical
  clearance to display cinema prices; whether cinemas can supply screening-
  specific booking links at scale; affiliate/referral model; data-refresh cadence
  (15 min / hourly / daily).
- **Explicitly deferred:** native ticketing, payments, venue settlement — Phase 5,
  only after traction.

## Brand Commitments

- Name **"NextShow"** is locked. Tagline in the founder brief: "Your city.
  Finally in one place."
- The current `shared/ui_kit` identity (royal blue `#2563EB`, Manrope + Inter,
  Material light theme) is a **placeholder, not binding**. `architecture_plan.md`
  treats the shipped UI as "dead weight" and calls for a Gen Z-grade redesign:
  120Hz-ready animation budgets, glassmorphism treatments, rich micro-interactions
  — "not default Material widgets bolted together."
- Voice/tone: not yet formally established (open decision).
- Logo: only a placeholder `NextShowLogo` widget exists; no final asset.

## Evidence on Hand

_Snapshot as of 2026-08-29. This section is expected to change materially over
the next ~2 weeks and should be refreshed via `/impeccable init` when it does._

- **No real pilot cinema data yet.** Supabase holds mock/test data only.
  Identifying and onboarding the first 3–5 independent Berlin cinemas plus
  event/gig partners is in progress — expected within days.
- **Public deployment targeted ~2026-09-13** (~15 days out); a real userbase and
  real behavioral data (searches, clicks, bookings) begin accruing after that.
- AI Concierge and recommendations run mock services.
- No finalized brand assets (logo files, marketing copy) in the repo.
- Authoritative product documents: `docs/plan.md` and `architecture_plan.md`.
- Until real data exists, design work must not fabricate: partner names,
  testimonials, real prices, booking-link availability, or user/traction numbers.
  Use realistic placeholders and mark them as such.

## Product Principles

1. **Discover → Compare → Go to book.** NextShow owns the decision; the venue
   owns the transaction — until traction proves a reason to change.
2. **Small → working → tested → traction → deeper.** Ship the smallest realistic
   version; don't overengineer ahead of proof.
3. **One normalized shape for every venue.** No per-cinema custom code.
4. **Trust is the product.** Never surface outdated showtimes or prices; show
   freshness and provenance.
5. **Cinema is the anchor for the night out**, not a standalone listing.
6. **Visibility for the overlooked.** Favor independent local venues.

## Accessibility & Inclusion

- **Full German + English localization is a launch requirement** — user-
  switchable, with locale-aware formatting. German strings run ~30% longer, so
  every layout must flex rather than truncate or clip.
- Film language and subtitle information (OV / OmU / OmeU / DF) is a primary
  filter surface, not a secondary label.
- The seat-selection blueprint includes an accessible list-view alternative to
  the visual matrix.
- No formal accessibility standard (WCAG level, etc.) has been set yet.
