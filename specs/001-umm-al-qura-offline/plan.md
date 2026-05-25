# Implementation Plan: Offline Umm Al-Qura Prayer Times

**Branch**: `001-umm-al-qura-offline` | **Date**: 2026-05-25 | **Spec**:
[spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-umm-al-qura-offline/spec.md`

**Note**: This plan refreshes the existing feature design so it matches the
clarified Hijri-first support window and bundle-refresh behavior before new
tasks are generated.

## Summary

Integrate the approved Umm Al-Qura bundle as repo-local Flutter assets, keep
the manifest-backed 118-city catalog authoritative for offline prayer times,
replace the current Gregorian-first support-window logic with a Hijri-first
mixed window that starts at the full current Hijri year and ends at the close
of the Hijri year containing the end of the fifth upcoming Gregorian year, and
refresh official cached days when a newer shipped bundle is detected while
preserving the selected city and local azan or iqama overrides.

## Technical Context

**Language/Version**: Dart 3.9.2 / Flutter stable

**Primary Dependencies**: Flutter, flutter_bloc, easy_localization,
hive/hive_flutter, shared_preferences, connectivity_plus, jhijri, built-in
gzip support from `dart:io`

**Storage**: SharedPreferences via `CacheHelper` for selected city and bundle
refresh metadata; Hive `prayer_calendar_days_box` for cached official days and
manual overrides; bundled app assets under `assets/data/umm_al_qura/v1/`

**Testing**: `flutter_test` unit and widget tests, existing
`prayer_calendar_helper` and `prayer_calendar_hive_helper` coverage, new
supported-window and bundle-refresh coverage, `flutter analyze`, and generated
output refresh where assets or localization inputs change

**Target Platform**: Android, iOS, and large-screen Flutter deployments using
the existing app runners; web is excluded from this feature's acceptance scope

**Project Type**: Flutter mobile/display application with offline asset-backed
domain services

**Performance Goals**: Cold offline city selection reaches today's official
schedule in under 5 seconds; repeated official day reads and year-navigation
loads resolve from in-memory or Hive-backed cache in under 500 ms on a
representative device; prayer-calendar navigation remains visually smooth on
phone and large-screen layouts

**Constraints**: No runtime network dependency for official prayer times; all
bundle access must come from repo-local assets, not the desktop source path;
all user-visible messaging remains localized for `ar`, `en`, and `bn`; primary
calendar navigation is Hijri month and year while Gregorian day context remains
visible; dates earlier than today inside the current Hijri year remain visible
but read-only; support ends at the close of the Hijri year containing the end
of the fifth upcoming Gregorian year; bundle updates must refresh official
cached days without discarding the selected city or user-maintained overrides

**Scale/Scope**: 118 official bundle cities, 11 available Hijri years in the
current bundle (`1447`-`1457`), one mixed user-facing support window derived
from the current Hijri year plus a Gregorian forward anchor, 6 daily prayer
times per date, and affected flows in city selection, startup hydration, home
prayer displays, calendar browsing, cache invalidation, and import validation

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Pre-Phase 0 Gate Result**: PASS

- **Prayer-time correctness**: Official bundle data remains the authoritative
  source for `PrayerCalendarDay.generatedAdhanMinutes`. `UmmAlQuraBundleService`,
  `PrayerCalendarHelper`, the supported-window model, and `AppCubit` own
  hydration, range rules, cache-refresh merging, and deterministic date-state
  logic. Unit tests will cover manifest parsing, supported-window boundaries,
  official-day hydration, and bundle-refresh replacement behavior.
- **Localized readability**: The feature changes the city picker, Hijri
  calendar navigation, supported-range messaging, read-only past-date states,
  and out-of-range guidance. The plan preserves readable localized copy in
  `ar`, `en`, and `bn` across portrait, landscape, and large-screen surfaces.
- **Architecture boundaries**: Bundle parsing and validation stay in
  `lib/core/` and `tool/`; cache invalidation and selection orchestration stay
  in `AppCubit`, `CacheHelper`, and Hive helpers; widgets remain
  presentation-first and consume typed data plus explicit availability state.
- **Verification plan**: `flutter analyze`, targeted unit tests for helpers,
  services, and refresh logic, widget tests for city selection and calendar
  navigation, generated-output refresh, and an offline manual walkthrough are
  all required before merge.
- **Asset and dependency discipline**: Runtime assets stay under
  `assets/data/umm_al_qura/v1/`; the bundle import tool validates coverage
  before shipping; no new third-party decompression dependency is required
  because the current accepted targets can use built-in gzip support; generated
  asset and localization outputs must refresh alongside source changes.

**Post-Phase 1 Re-check**: PASS

- `research.md` resolves the mixed Hijri/Gregorian support window, runtime
  cache-refresh strategy, and authoritative bundle-loading rules.
- `data-model.md` defines a neutral supported-window model, explicit cache
  freshness tokening, and preserved override behavior layered on official day
  records.
- `contracts/` now lock the Hijri-first calendar window, offline city catalog,
  and bundle-refresh behavior before implementation or task regeneration.

## Project Structure

### Documentation (this feature)

```text
specs/001-umm-al-qura-offline/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── offline-bundle-refresh.md
│   ├── offline-calendar-window.md
│   └── offline-city-catalog.md
└── tasks.md
```

### Source Code (repository root)

```text
assets/
└── data/
    └── umm_al_qura/
        └── v1/
            ├── manifest.json
            └── cities/
                └── gz/

lib/
├── controllers/cubits/appcubit/app_cubit.dart
├── core/helpers/prayer_calendar_helper.dart
├── core/helpers/prayer_calendar_hive_helper.dart
├── core/models/city_option.dart
├── core/models/gregorian_coverage_window.dart
├── core/models/official_city_catalog_entry.dart
├── core/models/prayer_calendar_day.dart
├── core/models/umm_al_qura_*.dart
├── core/services/official_city_catalog_service.dart
├── core/services/umm_al_qura_bundle_service.dart
├── core/utils/cache_helper.dart
├── data/data/city_country_data.dart
├── generated/
├── gen/
└── views/
    ├── prayer_calendar/hijri_prayer_calendar_screen.dart
    └── select_location/select_location_screen.dart

tool/
└── umm_al_qura_import.dart

test/
├── prayer_calendar_helper_test.dart
├── prayer_calendar_hive_helper_test.dart
├── select_location_offline_city_picker_test.dart
├── umm_al_qura_bundle_service_test.dart
├── umm_al_qura_import_test.dart
└── hijri_prayer_calendar_window_test.dart
```

**Structure Decision**: Keep the existing Flutter app structure and current
feature directories, update the existing official bundle services and city
selection flow, and refactor the current `gregorian_coverage_window.dart`
behavior into a neutral supported-window model that accurately represents the
Hijri-first mixed rule without pushing business logic into widgets.

## Complexity Tracking

No constitution violations or justified exceptions are currently identified.
