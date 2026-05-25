# Implementation Plan: Offline Umm Al-Qura Prayer Times

**Branch**: `001-umm-al-qura-offline` | **Date**: 2026-05-23 | **Spec**:
[spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-umm-al-qura-offline/spec.md`

**Note**: This plan covers Phase 0 research and Phase 1 design artifacts for
integrating the prepared Umm Al-Qura bundle into the existing azan app.

## Summary

Integrate the prepared Umm Al-Qura bundle as repo-local Flutter assets, expand
the app's city catalog to match the bundle's 118 supported cities, replace the
current generated prayer-calendar source with an official offline bundle
service, and adapt the city selection and calendar UI to show the full current
Gregorian year plus the next 5 full Gregorian years while keeping earlier dates
in the current year visible but read-only.

## Technical Context

**Language/Version**: Dart 3.9.2 / Flutter stable

**Primary Dependencies**: Flutter, flutter_bloc, easy_localization,
hive/hive_flutter, shared_preferences, flutter_gen_runner, connectivity_plus,
archive (planned, for runtime gzip asset decoding)

**Storage**: SharedPreferences for selected city/settings; Hive
`prayer_calendar_days_box` for cached official days and manual overrides;
bundled app assets under `assets/data/umm_al_qura/v1/`

**Testing**: `flutter_test` unit and widget tests, existing
`prayer_calendar_helper` and `prayer_calendar_hive_helper` coverage, new bundle
import/service/window tests, `flutter analyze`

**Target Platform**: Android, iOS, and large-screen Flutter deployments using
the existing app runners; web is not a target for this feature's acceptance
scope

**Project Type**: Flutter mobile/display application with offline asset-backed
domain services

**Performance Goals**: Cold offline city selection reaches today's official
schedule in under 5 seconds; repeated day or calendar reads resolve from
assets/Hive in under 500 ms on a representative device; calendar navigation
remains visually smooth

**Constraints**: No runtime network dependency for official prayer times; all
bundle access must come from repo-local assets, not the source desktop path;
all user-visible messaging remains localized for `ar`, `en`, and `bn`; full
current Gregorian year plus next 5 full Gregorian years must be browsable;
earlier dates inside the current Gregorian year remain visible but blocked from
editing/selection; manual adhan/iqama overrides must survive the source swap

**Scale/Scope**: 118 official bundle cities, 10 underlying Hijri years in the
source package, user-facing 6-Gregorian-year browsing window, 6 daily prayer
times per date, affected flows in `SelectLocationScreen`,
`HijriPrayerCalendarScreen`, home screen initializers, city lookup helpers, and
prayer-day persistence

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Pre-Phase 0 Gate Result**: PASS

- **Prayer-time correctness**: Official bundle data becomes the authoritative
  source for `PrayerCalendarDay.generatedAdhanMinutes`. `AppCubit`,
  `PrayerCalendarHelper`, and `PrayerCalendarHiveHelper` stay responsible for
  orchestration, window logic, and override persistence. Unit tests will cover
  manifest parsing, city-key selection, Gregorian window rules, and
  official-time hydration.
- **Localized readability**: The feature changes city selection and calendar
  browsing UI. The plan preserves localized labels, explicit read-only past-day
  states, and out-of-range guidance in shared portrait/landscape surfaces.
- **Architecture boundaries**: Bundle parsing/import stays in `lib/core/` and
  `tool/`; widgets remain presentation-first and consume typed view models from
  `AppCubit`.
- **Verification plan**: `flutter analyze`, existing prayer-calendar tests,
  new service/window/widget tests, and offline manual walkthroughs are planned.
  Theme audit is not required unless visual treatment expands beyond the
  touched surfaces.
- **Asset and dependency discipline**: The runtime app will load bundle assets
  from `assets/data/umm_al_qura/v1/`. A dedicated import/validation tool will
  copy and verify bundle contents before shipping. A single decompression
  dependency is justified to keep gzip loading cross-platform within accepted
  targets.

**Post-Phase 1 Re-check**: PASS

- `research.md` resolves the bundle-import, city-catalog, runtime-loading, and
  coverage-window decisions.
- `data-model.md` defines stable bundle IDs, alias-aware city metadata, runtime
  cached day records, and date availability states.
- `contracts/` locks the city-selection and calendar-window behavior before
  implementation updates `SelectLocationScreen` and
  `HijriPrayerCalendarScreen`.

## Project Structure

### Documentation (this feature)

```text
specs/001-umm-al-qura-offline/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
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
├── core/helpers/location_helper.dart
├── core/helpers/prayer_calendar_helper.dart
├── core/models/city_option.dart
├── core/models/prayer_calendar_day.dart
├── core/models/umm_al_qura_*.dart
├── core/services/umm_al_qura_*.dart
├── core/utils/cache_helper.dart
├── data/data/city_country_data.dart
├── views/prayer_calendar/hijri_prayer_calendar_screen.dart
└── views/select_location/select_location_screen.dart

tool/
└── umm_al_qura_import.dart

test/
├── prayer_calendar_helper_test.dart
├── prayer_calendar_hive_helper_test.dart
├── umm_al_qura_bundle_service_test.dart
├── umm_al_qura_calendar_window_test.dart
├── select_location_offline_city_picker_test.dart
└── hijri_prayer_calendar_window_test.dart
```

**Structure Decision**: Keep the existing Flutter app structure and integrate
the feature into current city selection, prayer initialization, and calendar
flows. Add a dedicated offline bundle import/tooling path under `tool/`, new
bundle models/services under `lib/core/`, repo-local schedule assets under
`assets/data/umm_al_qura/v1/`, and targeted widget/unit coverage under `test/`.

## Complexity Tracking

No constitution violations or exceptions are currently identified.
