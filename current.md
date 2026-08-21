# NextShow Project - Current Session Summary & Status

## Overview
This document summarizes the fixes, upgrades, and architecture updates completed during this session across `next-show_project` (`apps/organizer_app`, `apps/user_app`, `shared/`, and database schema).

---

## 1. Android & Gradle Build Fixes
- **Gradle Version Upgrade**:
  - Upgraded Gradle wrapper to **Gradle 8.13** (`gradle-8.13-all.zip`) across both `apps/organizer_app` and `apps/user_app`.
- **Android Gradle Plugin (AGP)**:
  - Updated `com.android.application` to version **8.11.1** in `settings.gradle`.
  - Migrated `settings.gradle` from legacy imperative script inclusion (`app_plugin_loader.gradle`) to standard declarative plugins syntax (`dev.flutter.flutter-plugin-loader`).
- **JVM Heap Allocation & Jetifier**:
  - Configured `org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=512m` in `gradle.properties` to prevent `Java heap space` OutOfMemory errors.
  - Set `android.enableJetifier=false` to bypass obsolete AndroidX bytecode transformation overhead.
  - Added `android.skipBuildDependencyValidation=true` to handle Flutter CLI version validation bypasses.
- **Java 17 Compatibility**:
  - Updated `compileOptions` (`sourceCompatibility`, `targetCompatibility`) and `kotlinOptions.jvmTarget` to **Java 17** in `android/app/build.gradle` to eliminate obsolete Java 8 warnings.

---

## 2. Database Schema & RLS Policy Updates
- **Idempotent Schema Consolidation** ([docs/schema.sql](file:///c:/Users/laksh/Workspace/next-show_project/docs/schema.sql)):
  - Updated `handle_new_user()` trigger function to include `SET search_path = public` and explicit schema qualification `public.user_role`.
  - Added RLS insert policy for `public.profiles`:
    ```sql
    CREATE POLICY "Service role can insert profiles"
      ON public.profiles FOR INSERT
      WITH CHECK (true);
    ```
  - Idempotent schema additions added for organizer app models (`end_time`, `capacity`, `tickets_sold`, `image_url` on `showtimes`, `event_status` on `events`, `partner_notes` on `venues`, and `organizer_invites` table).

---

## 3. Organizer App (`apps/organizer_app`)
- **Self-Service Partner Role Onboarding**:
  - `AuthGate` in `lib/main.dart` allows users signed in with default `'user'` role to upgrade their account to `'partner'` directly from the UI.
- **Performance & Widget Loop Fix**:
  - Fixed infinite `FutureBuilder` rebuild loop (`cancelAndRedraw` log spam) in `AuthGate` by caching `_partnerRoleFuture`.
- **Auth Layout Fixes**:
  - Resolved `SingleChildScrollView` + `Spacer()` layout conflict in `LoginScreen` to prevent blank rendering.

---

## 4. Next Steps & Note on Organizer App Login
> **Note**: We will temporarily bypass/disable mandatory login in `organizer_app` (or test with a bypass flag) to allow rapid manual testing of the main organizer screens while focusing on testing `user_app` end-to-end.
