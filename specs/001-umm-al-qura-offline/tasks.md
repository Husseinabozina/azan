---

description: "Task list for Offline Umm Al-Qura Prayer Times"
---

# Tasks: Offline Umm Al-Qura Prayer Times

**Input**: Design documents from `/specs/001-umm-al-qura-offline/`

**Prerequisites**: [plan.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/plan.md) (required), [spec.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/spec.md) (required for user stories), [research.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/research.md), [data-model.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/data-model.md), [contracts/](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/contracts/), [quickstart.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/quickstart.md)

**Tests**: Include verification tasks for every story. This feature changes offline schedule logic, persistence, cache refresh, and UI, so it requires unit, state, and widget coverage plus final `flutter analyze` and targeted `flutter test` runs from [quickstart.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/quickstart.md).

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently after the shared foundation lands.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on incomplete tasks)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- Every task includes the exact file path to change

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Keep the approved bundle and repo-level inputs aligned with the refreshed feature plan.

- [X] T001 Update bundle asset declarations and runtime prerequisites in `pubspec.yaml` for `assets/data/umm_al_qura/v1/`
- [X] T002 Maintain the repo import and validation workflow in `tool/umm_al_qura_import.dart` for the approved bundle source and repo-local destination
- [X] T003 Import the approved bundle into `assets/data/umm_al_qura/v1/manifest.json` and `assets/data/umm_al_qura/v1/cities/gz/`
- [X] T004 Refresh generated asset references in `lib/gen/assets.gen.dart` after bundle assets are synchronized

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the shared domain, cache-refresh metadata, localization, and supported-window plumbing that all user stories depend on.

**⚠️ CRITICAL**: Do not begin story work until this phase is complete.

- [X] T005 Extend persisted city and bundle-refresh metadata in `lib/core/models/city_option.dart` and `lib/core/utils/cache_helper.dart`
- [X] T006 [P] Refactor supported-window and official bundle domain models in `lib/core/models/gregorian_coverage_window.dart`, `lib/core/models/official_city_catalog_entry.dart`, `lib/core/models/umm_al_qura_bundle_manifest.dart`, and `lib/core/models/umm_al_qura_schedule_day.dart`
- [X] T007 [P] Update shared Hijri-first range and date-availability helpers in `lib/core/helpers/prayer_calendar_helper.dart` and `lib/core/models/gregorian_coverage_window.dart`
- [X] T008 Implement manifest tokening, catalog loading, and official day decoding updates in `lib/core/services/official_city_catalog_service.dart` and `lib/core/services/umm_al_qura_bundle_service.dart`
- [X] T009 [P] Update prayer-day persistence and stale-official-day merge support in `lib/core/helpers/prayer_calendar_hive_helper.dart` and `lib/core/models/prayer_calendar_day.dart`
- [X] T010 [P] Add shared localized copy for Hijri-first supported-range, read-only past-day, out-of-range, and bundle-refresh states in `assets/translations/ar.json`, `assets/translations/en.json`, and `assets/translations/bn.json`
- [X] T011 [P] Update curated Saudi city metadata and alias mappings in `lib/data/data/city_country_data.dart` and `lib/core/helpers/location_helper.dart`

**Checkpoint**: The app can parse the shipped bundle, resolve a stable official city catalog, derive the mixed Hijri/Gregorian support window, and persist official bundle-backed days with refresh metadata.

---

## Phase 3: User Story 1 - Guided Offline City Setup (Priority: P1) 🎯 MVP

**Goal**: Let the operator pick any shipped bundle city once and reliably see today's official prayer times offline after restart.

**Independent Test**: Disable internet, select a city from the offline catalog, confirm today's schedule appears, restart the app offline, and verify the city plus today's official times are restored.

### Tests for User Story 1

- [X] T012 [P] [US1] Add same-day official hydration and source-token coverage in `test/umm_al_qura_bundle_service_test.dart`
- [X] T013 [P] [US1] Add offline city picker and saved `bundleId` restore coverage in `test/select_location_offline_city_picker_test.dart`
- [X] T014 [P] [US1] Add AppCubit offline startup and city restore coverage in `test/app_cubit_offline_schedule_test.dart`

### Implementation for User Story 1

- [X] T015 [US1] Wire selected-city persistence and startup hydration through the official bundle path in `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/controllers/cubits/appcubit/app_state.dart`
- [X] T016 [US1] Update the offline city selection flow and recoverable selection errors in `lib/core/utils/selection_dialoge.dart` and `lib/views/select_location/select_location_screen.dart`
- [X] T017 [US1] Route home and same-day official prayer-time reads through the manifest-token-aware cache in `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/core/helpers/prayer_calendar_hive_helper.dart`
- [X] T018 [US1] Preserve saved `bundleId` resolution across shipped bundle updates in `lib/core/services/official_city_catalog_service.dart` and `lib/core/utils/cache_helper.dart`

**Checkpoint**: User Story 1 is complete when offline city selection and same-day schedule restore work without any network dependency.

---

## Phase 4: User Story 2 - Browse Fixed Multi-Year Official Schedule (Priority: P2)

**Goal**: Let the user browse the full current Hijri year plus the forward window that extends through the final supported Hijri year while still seeing Gregorian context for each day.

**Independent Test**: With internet disabled, open the calendar for a selected city, browse supported dates at the start, middle, and end of the mixed support window, and verify each date resolves to the official timetable.

### Tests for User Story 2

- [X] T019 [P] [US2] Add mixed supported-window unit coverage in `test/prayer_calendar_helper_test.dart` and `test/umm_al_qura_calendar_window_test.dart`
- [X] T020 [P] [US2] Add Hijri-first calendar navigation and boundary widget coverage in `test/hijri_prayer_calendar_window_test.dart`

### Implementation for User Story 2

- [X] T021 [US2] Implement the mixed Hijri/Gregorian supported-window model and date-availability rules in `lib/core/helpers/prayer_calendar_helper.dart` and `lib/core/models/gregorian_coverage_window.dart`
- [X] T022 [US2] Teach official range loading to hydrate the supported Hijri-year window in `lib/core/services/umm_al_qura_bundle_service.dart` and `lib/controllers/cubits/appcubit/app_cubit.dart`
- [X] T023 [US2] Expose supported Hijri years, supported-range labels, and day-availability state from `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/controllers/cubits/appcubit/app_state.dart`
- [X] T024 [P] [US2] Add localized supported-range labels and final-Hijri-year boundary hints in `assets/translations/ar.json`, `assets/translations/en.json`, and `assets/translations/bn.json`
- [X] T025 [US2] Refactor `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart` to use Hijri year and month navigation with Gregorian day context

**Checkpoint**: User Story 2 is complete when supported future dates load offline across the mixed window with clear Hijri-first range context.

---

## Phase 5: User Story 3 - Trust Coverage and Keep Existing Operations (Priority: P3)

**Goal**: Keep manual adjustments intact, refresh stale official cache correctly, block unsupported dates clearly, and make the supported range obvious so the official bundle never feels ambiguous.

**Independent Test**: Try unsupported future dates and past dates in the current Hijri year, verify the UI blocks them clearly, simulate a newer bundle token, and confirm existing adhan or iqama overrides still apply on refreshed official days.

### Tests for User Story 3

- [X] T026 [P] [US3] Add bundle-refresh cache invalidation and override-merge coverage in `test/prayer_calendar_hive_helper_test.dart` and `test/prayer_calendar_day_test.dart`
- [X] T027 [P] [US3] Add out-of-range recovery, read-only past-date, and refresh messaging widget coverage in `test/offline_calendar_guidance_test.dart`
- [X] T028 [P] [US3] Add mixed-window completeness validation coverage in `test/umm_al_qura_import_test.dart`

### Implementation for User Story 3

- [X] T029 [US3] Align import-time completeness validation with the final supported Hijri-year rule in `tool/umm_al_qura_import.dart` and `lib/core/models/umm_al_qura_bundle_manifest.dart`
- [X] T030 [P] [US3] Preserve manual adhan and iqama overrides while refreshing stale official days in `lib/core/models/prayer_calendar_day.dart`, `lib/core/helpers/prayer_calendar_hive_helper.dart`, and `lib/controllers/cubits/appcubit/app_cubit.dart`
- [X] T031 [US3] Implement manifest-token comparison and lazy official cache-refresh orchestration in `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/core/utils/cache_helper.dart`
- [X] T032 [US3] Expose out-of-range recovery, stale-city fallback, and refresh error state in `lib/controllers/cubits/appcubit/app_state.dart` and `lib/controllers/cubits/appcubit/app_cubit.dart`
- [X] T033 [US3] Implement read-only past-date guidance, out-of-range recovery, and bundle-refresh-safe messaging in `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart` and `lib/views/select_location/select_location_screen.dart`

**Checkpoint**: User Story 3 is complete when unsupported dates are handled clearly and newer shipped bundles refresh official base data without breaking overrides or saved city state.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Refresh generated outputs and run the full targeted verification sweep.

- [X] T034 [P] Regenerate asset and localization outputs in `lib/gen/assets.gen.dart`, `lib/generated/locale_keys.g.dart`, and `lib/generated/codegen_loader.g.dart`
- [X] T035 [P] Validate the offline walkthrough in `specs/001-umm-al-qura-offline/quickstart.md` against `test/app_cubit_offline_schedule_test.dart`, `test/select_location_offline_city_picker_test.dart`, `test/hijri_prayer_calendar_window_test.dart`, and `test/offline_calendar_guidance_test.dart`
- [X] T036 [P] Run `flutter analyze` and the targeted `flutter test` commands documented in `specs/001-umm-al-qura-offline/quickstart.md` for touched files under `lib/`, `test/`, and `tool/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup** has no dependencies and starts immediately.
- **Phase 2: Foundational** depends on Phase 1 and blocks every user story.
- **Phase 3: US1** depends on Phase 2 and is the MVP slice.
- **Phase 4: US2** depends on Phase 2 and can proceed independently once the shared official bundle services and supported-window model exist.
- **Phase 5: US3** depends on Phase 2; if one developer owns the calendar surface, sequence its UI work after US2 to avoid churn in `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart`.
- **Phase 6: Polish** depends on every story you choose to ship.

### User Story Dependencies

- **US1**: No dependency on other user stories after the foundational phase is done.
- **US2**: No dependency on US1 behavior, but it reuses the same shared official bundle services and supported-window helpers from Phase 2.
- **US3**: No hard dependency on US1 or US2, but it extends the calendar, cache-refresh, and override flows touched by both.

### Within Each User Story

- Write or update the listed tests before implementation when possible.
- Finish shared helper or service logic before cubit wiring.
- Finish cubit wiring before UI integration.
- Verify each story independently before moving to the next priority.

### Parallel Opportunities

- `T006`, `T007`, `T009`, `T010`, and `T011` can run in parallel once `T005` is done.
- `T012`, `T013`, and `T014` can run in parallel for US1 verification.
- `T019` and `T020` can run in parallel for US2 verification.
- `T024` can run in parallel with `T025` once `T023` is stable.
- `T026`, `T027`, and `T028` can run in parallel for US3 verification.
- `T029` and `T030` can run in parallel before `T031` and `T032`.
- `T034`, `T035`, and `T036` can run in parallel at the end if different people own codegen, walkthrough, and verification.

---

## Parallel Example: User Story 1

```bash
# Launch US1 verification work together:
Task: "T012 [US1] Add same-day official hydration and source-token coverage in test/umm_al_qura_bundle_service_test.dart"
Task: "T013 [US1] Add offline city picker and saved bundleId restore coverage in test/select_location_offline_city_picker_test.dart"
Task: "T014 [US1] Add AppCubit offline startup and city restore coverage in test/app_cubit_offline_schedule_test.dart"
```

## Parallel Example: User Story 2

```bash
# Launch US2 verification together:
Task: "T019 [US2] Add mixed supported-window unit coverage in test/prayer_calendar_helper_test.dart and test/umm_al_qura_calendar_window_test.dart"
Task: "T020 [US2] Add Hijri-first calendar navigation and boundary widget coverage in test/hijri_prayer_calendar_window_test.dart"

# Split localization copy from screen refactor:
Task: "T024 [US2] Add localized supported-range labels and final-Hijri-year boundary hints in assets/translations/ar.json, assets/translations/en.json, and assets/translations/bn.json"
Task: "T025 [US2] Refactor lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart to use Hijri year and month navigation with Gregorian day context"
```

## Parallel Example: User Story 3

```bash
# Launch US3 verification together:
Task: "T026 [US3] Add bundle-refresh cache invalidation and override-merge coverage in test/prayer_calendar_hive_helper_test.dart and test/prayer_calendar_day_test.dart"
Task: "T027 [US3] Add out-of-range recovery, read-only past-date, and refresh messaging widget coverage in test/offline_calendar_guidance_test.dart"
Task: "T028 [US3] Add mixed-window completeness validation coverage in test/umm_al_qura_import_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Validate offline city selection, same-day hydration, and restart restore before expanding scope.

### Incremental Delivery

1. Ship US1 first to land the offline city-selection and today's-schedule promise.
2. Add US2 next to unlock Hijri-first long-range browsing without destabilizing the MVP setup flow.
3. Add US3 last to harden bundle-refresh behavior, unsupported-date UX, and override continuity.

### Parallel Team Strategy

1. One developer handles Phase 1 and Phase 2 shared infrastructure.
2. After Phase 2:
   - Developer A can own US1 flow wiring in `lib/views/select_location/` and `lib/controllers/cubits/appcubit/`
   - Developer B can own US2 calendar browsing in `lib/views/prayer_calendar/`
   - Developer C can own US3 validation and cache-refresh hardening in `tool/`, `lib/core/helpers/`, and `lib/core/models/`
