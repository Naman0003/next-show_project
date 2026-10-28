# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

start every response by calling me Mr. Performative

## Common Commands

### Build the Project
To build the project, use:
```bash
flutter build
```

### Lint the Code
To lint the code, you can run:
```bash
flutter analyze
```

### Run Tests
To run all tests in the project:
```bash
flutter test
```

To run a specific test file, use:
```bash
flutter test <path_to_test_file>
```

For example:
```bash
flutter test apps/user_app/test/widget_test.dart
```

## Code Architecture

The codebase consists of multiple applications (user_app, admin_app, organizer_app) and shared packages. Each application has its own set of libraries and tests.

- **apps/user_app**: Contains the user-facing application with various screens and services handling user interactions and data management.
- **apps/admin_app**: Contains administrative functionalities and services, primarily for management and configuration tasks.
- **apps/organizer_app**: Contains features related to organizing events and interfacing with users and administrators alike.

### Key Components
- **main.dart**: The entry point for each of the applications.
- **lib/screens**: Contains the UI screens for the respective applications.
- **lib/services**: Contains services for handling business logic, API calls, and data manipulation.
- **lib/models**: Data models representing the various entities in the application.

### Packages
- **core_models**: Contains shared data models used across applications.
- **supabase_client**: Interface for interacting with Supabase to handle database operations.
- **ui_kit**: Includes shared UI components.

No specific Cursor rules or Copilot instructions found, as the relevant directories are absent.

## Task Tracking — TODO.md

All upcoming work, priorities, and status are tracked in **TODO.md** at the repository root.

### Convention

| Symbol | Meaning |
|--------|---------|
| `[ ]` | **PENDING** — Not started |
| `[~]` | **IN PROGRESS** — Actively being worked on |
| `[x]` | **COMPLETED** — Done and verified |
| `[!]` | **BLOCKED** — Waiting on external dependency or decision |

### Priority Levels

- **P0** — Critical path (blocks everything else)
- **P1** — High (core feature work)
- **P2** — Medium (polish, enhancements)
- **P3** — Nice to have (future phases)

### How to Use

1. **Before starting work**: Check TODO.md, pick a P0/P1 task, change `[ ]` → `[~]`
2. **While working**: Keep TODO.md updated if scope changes
3. **When done**: Change `[~]` → `[x]`, add brief verification note if useful
4. **If blocked**: Change `[ ]` → `[!]`, note the blocker in the Notes column

This ensures anyone opening the project (human or AI) can immediately see what's next, what's in flight, and what's done — without digging through git history or asking.

## Recent Architecture Improvements & Features

The following features and structural updates have been completed:

### 1. Build System & Gradle Upgrades
- Upgraded both apps to Gradle `8.13` and declarative AGP `8.11.1`.
- All three apps are now on Gradle `9.3.1`, AGP `8.13.0` and Kotlin `2.4.0` so it builds with Android Studio's bundled Java 25 (Gradle 8.x can't run on Java 25). AGP 9.x is blocked by `flutter_inappwebview_android`, whose build file uses the removed `proguard-android.txt`.
- Configured Java 17 toolchain compatibility and target configurations.
- Added `-Xmx4G` memory optimizations and disabled obsolete Jetifier processing to speed up compilation.

### 2. Database Schema & RLS Security Definer Fixes
- Avoided PostgreSQL infinite RLS recursion (`42P17`) by routing profile lookups through `SECURITY DEFINER` SQL helper functions (`public.is_admin()`, `public.is_partner()`).
- Added the `is_verified` boolean attribute to the `public.events` table and the `public.v_listings` view to audit partner-provided content.

### 3. Clean Movie Search UX & Fallback Flow
- Designed a clean, unbranded "Find a Movie" autocomplete search flow.
- Core movie details (Title, Synopsis, Poster, Runtime, Director, Genres) are automatically fetched from external APIs and locked (read-only) for verified movies.
- Added a fallback button ("Didn't find your movie? Add a custom movie.") that unlocks custom inputs, enforcing an external reference link (IMDb, Letterboxd) and saving with `is_verified: false` for admin moderation.

### 4. Showtime Controls & Realtime Stream Ingestion
- Streamlined showtime creation to only ask for performance parameters (hall, audio chips, formats, direct booking URL).
- Replaced FutureBuilder in `ShowtimeListScreen` with a Supabase Realtime Stream subscription (`.stream(...)`), achieving instant visual updates for new/edited showtimes.
- Assigned unique `heroTag` properties to FloatActionButtons to prevent duplicate hero transition exceptions on screen pushes.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (`Naman0003/next-show_project`), via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout (root `CONTEXT.md` + `docs/adr/`). See `docs/agents/domain.md`.
