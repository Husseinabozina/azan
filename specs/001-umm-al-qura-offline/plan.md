# Implementation Plan: Offline Umm Al-Qura Prayer Times

**Branch**: `001-umm-al-qura-offline` | **Date**: 2026-05-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-umm-al-qura-offline/spec.md`

## Summary

Refit the existing offline Umm Al-Qura integration so the prayer calendar
remains Hijri-first, keeps the clarified support-window and bundle-refresh
rules, and upgrades large-screen month browsing from a cramped low-emphasis
strip into a persistent side-panel navigation model that is readable and
operable from mosque control distance.

## Technical Context

**Language/Version**: Dart `^3.9.2` / Flutter stable

**Primary Dependencies**: Flutter, `flutter_bloc`, `easy_localization`, Hive,
`shared_preferences`, `hijri`, `jhijri`, `intl`, `flutter_screenutil`,
existing `adhan` fallback path

**Storage**: Repo-local `assets/data/umm_al_qura/v1/` bundle assets, Hive
prayer-day cache, `CacheHelper` / `SharedPreferences` for selected city,
language, Hijri offset, and official bundle freshness metadata

**Testing**: `flutter_test` unit and widget tests, targeted golden coverage
for large-screen calendar navigation, `flutter analyze`,
`dart run build_runner build --delete-conflicting-outputs`, and
`git diff --check`

**Target Platform**: Flutter mobile and tablet surfaces used in phone mode and
mosque-oriented large-screen layouts, especially landscape display workflows

**Project Type**: Flutter application with shared prayer-display and settings
surfaces

**Performance Goals**: Keep offline city hydration authoritative and local,
load a supported Hijri year without network access, and keep month switching on
the loaded calendar responsive enough for display-side operation without
precision interaction

**Constraints**: Offline behavior is mandatory for shipped bundle cities; date
availability must remain deterministic under Hijri offset rules; widgets must
stay presentation-focused; large-screen controls must remain readable across
`ar`, `en`, and `bn`; no new runtime dependency should be added unless current
Flutter layout primitives prove insufficient

**Scale/Scope**: Planning covers prayer-calendar helpers and models, official
bundle services, `AppCubit` schedule orchestration, selected-city persistence,
`lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart`,
`lib/views/select_location/select_location_screen.dart`, affected
localizations, generated outputs, and targeted tests for helper, cubit, and
calendar UI behavior

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Prayer-time correctness**: PASS. Official bundle hydration stays owned by
  `UmmAlQuraBundleService`, support-window logic stays in helpers and models,
  and `AppCubit` remains the orchestration layer for day loading, cache
  freshness, and override preservation. Planned coverage includes helper,
  bundle-service, import-validation, cubit, and calendar-window tests.
- **Localized readability**: PASS. Impacted locales are `ar`, `en`, and `bn`.
  Impacted screen classes are compact mobile, tablet, and mosque-style
  landscape displays. The new month-navigation side panel must be verified with
  widget and golden evidence so active-month emphasis and reading distance stay
  acceptable.
- **Architecture boundaries**: PASS. Business logic remains in
  `lib/controllers/` and `lib/core/`; `HijriPrayerCalendarScreen` stays focused
  on composition and responsive layout only. Persistence continues through Hive
  helpers and `CacheHelper`, not directly in widgets.
- **Verification plan**: PASS. Before merge the change set must run
  `dart run build_runner build --delete-conflicting-outputs`,
  `flutter analyze`, targeted `flutter test` runs for helper, cubit, bundle,
  and calendar surfaces, updated widget or golden evidence for the large-screen
  panel, and `git diff --check`.
- **Asset and dependency discipline**: PASS. No new assets or third-party
  dependencies are planned. Existing official bundle assets remain the runtime
  source, and any localization or asset-generator inputs changed by the UI work
  must regenerate `lib/gen/` and `lib/generated/` outputs in the same change.

## Project Structure

### Documentation (this feature)

```text
specs/001-umm-al-qura-offline/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── large-screen-calendar-navigation.md
│   ├── offline-bundle-refresh.md
│   ├── offline-calendar-window.md
│   └── offline-city-catalog.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── controllers/cubits/appcubit/
├── core/helpers/
├── core/models/
├── core/services/
├── gen/
├── generated/
└── views/
    ├── prayer_calendar/
    └── select_location/

assets/
├── data/umm_al_qura/v1/
└── translations/

test/
├── goldens/
├── hijri_prayer_calendar_window_test.dart
├── offline_calendar_guidance_test.dart
├── prayer_calendar_helper_test.dart
├── prayer_calendar_hive_helper_test.dart
├── select_location_offline_city_picker_test.dart
├── umm_al_qura_bundle_service_test.dart
└── umm_al_qura_import_test.dart

tool/
└── umm_al_qura_import.dart
```

**Structure Decision**: Keep official bundle and date-window logic inside
existing helpers, services, and cubit layers; keep the large-screen calendar
change confined to `lib/views/prayer_calendar/` presentation code plus
supporting view-model helpers; preserve existing persistence abstractions and
generated-output boundaries.

## Phase 0: Research

Research is captured in [research.md](./research.md) and resolves the planning
unknowns that matter for this revision:

- keep the repo-local bundle as the authoritative offline asset source
- preserve lazy city loading plus Hive-backed runtime caching
- keep the Hijri-first supported-window model with the Gregorian forward anchor
- refresh stale official cached days lazily when the shipped manifest token
  changes
- adopt a responsive month-navigation design that upgrades to a persistent
  large-screen side panel without adding a new layout dependency

## Phase 1: Design Artifacts

- [data-model.md](./data-model.md): extends the existing data model with
  navigation-specific month metadata and layout mode semantics for the prayer
  calendar
- [contracts/offline-city-catalog.md](./contracts/offline-city-catalog.md):
  keeps city selection bundle-authoritative and backward-compatible
- [contracts/offline-calendar-window.md](./contracts/offline-calendar-window.md):
  defines supported-date, Hijri-navigation, and official-day lookup behavior
- [contracts/offline-bundle-refresh.md](./contracts/offline-bundle-refresh.md):
  defines how cached official days refresh while preserving overrides
- [contracts/large-screen-calendar-navigation.md](./contracts/large-screen-calendar-navigation.md):
  defines the persistent side-panel behavior, emphasis, and operability rules
  for mosque-oriented layouts
- [quickstart.md](./quickstart.md): documents import, regeneration,
  verification, and manual large-screen walkthrough steps
- `AGENTS.md`: already points to `specs/001-umm-al-qura-offline/plan.md`, so
  no marker update was required in this planning pass

## Post-Design Constitution Check

- **Prayer-time correctness**: PASS. The design still keeps all schedule and
  date-boundary logic outside widgets, with one authoritative official bundle
  path and explicit stale-cache refresh behavior.
- **Localized readability**: PASS. The design adds a dedicated large-screen
  navigation contract, keeps Hijri-first wording, and calls for widget or
  golden proof across `ar`, `en`, and `bn` where labels differ in length.
- **Architecture boundaries**: PASS. Responsive layout mode is a view concern,
  but month availability and supported-window calculations remain helper or
  cubit derived data, not widget-owned business logic.
- **Verification plan**: PASS. The design requires updated automated tests and
  visual evidence for the large-screen panel in addition to existing offline
  correctness coverage.
- **Asset and dependency discipline**: PASS. The design uses existing fonts,
  themes, localization infrastructure, and Flutter layout primitives; no new
  dependency is justified.

## Complexity Tracking

No constitution exceptions are planned at this stage.
