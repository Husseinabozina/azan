# Azan

Azan is a Flutter application for prayer-time experiences, iqama and
display-board views, multilingual devotional content, and theme-rich mosque or
home display surfaces.

## Stack

- Dart 3 / Flutter stable
- `flutter_bloc` for state management
- `easy_localization` for `ar`, `en`, and `bn`
- Hive and shared preferences for local persistence
- Generated assets and localization outputs in `lib/gen/` and `lib/generated/`

## Getting Started

1. Run `flutter pub get`
2. Start the app with `flutter run`

## Common Commands

- `flutter analyze`
- `flutter test`
- `dart run build_runner build --delete-conflicting-outputs`
- `dart run tool/background_theme_audit.dart --fail-on-issues`

## Project Structure

- `lib/views/`: screens and presentation widgets
- `lib/controllers/`: cubits and app state
- `lib/core/`: shared helpers, models, services, theming, and UI components
- `lib/data/`: data sources and integration plumbing
- `assets/`: bundled fonts, images, audio, SVG, and translations
- `test/`: unit, widget, and golden coverage
- `tool/`: repository-specific scripts and audits

## Workflow Expectations

- Keep business logic and persistence out of widgets whenever possible.
- Refresh generated files when localization, assets, or codegen inputs change.
- Run `flutter analyze` and the relevant tests for every change.
- Run the background theme audit when theme or background assets are touched.
- Follow the project constitution in `.specify/memory/constitution.md`.
