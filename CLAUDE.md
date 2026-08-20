# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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