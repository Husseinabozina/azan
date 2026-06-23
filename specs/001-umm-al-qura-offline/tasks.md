---

description: "Task list for Offline Umm Al-Qura Prayer Times"
---

# Tasks: Offline Umm Al-Qura Prayer Times

**Input**: Design documents from `/specs/001-umm-al-qura-offline/`

**Prerequisites**: [plan.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/plan.md) (required), [spec.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/spec.md) (required for user stories), [research.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/research.md), [data-model.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/data-model.md), [contracts/](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/contracts/), [quickstart.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/quickstart.md)

**Tests**: This feature changes offline prayer-time logic, persistence, cache refresh, and large-screen calendar UI, so every story needs targeted unit, cubit, widget, or golden coverage plus final `flutter analyze`, targeted `flutter test`, and codegen verification from [quickstart.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/quickstart.md).

**Organization**: Tasks are grouped by user story so each story remains independently implementable and testable after the shared foundation lands.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel when it touches different files and has no dependency on incomplete work
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- Every task includes the exact file path to change

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Keep the approved bundle, repo inputs, and generated asset references aligned before feature work begins.

- [X] T001 Maintain the approved bundle import and validation workflow in `tool/umm_al_qura_import.dart`
- [X] T002 Synchronize the shipped offline bundle assets in `assets/data/umm_al_qura/v1/manifest.json` and `assets/data/umm_al_qura/v1/cities/gz/`
- [X] T003 Declare the shipped manifest and gzip city assets in `pubspec.yaml`
- [X] T004 [P] Refresh generated asset references for the bundle in `lib/gen/assets.gen.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the shared bundle, persistence, navigation, and localization plumbing that every story relies on.

**⚠️ CRITICAL**: Do not begin user-story work until this phase is complete.

- [X] T005 Extend persisted selected-city and official-source-token metadata in `lib/core/models/city_option.dart` and `lib/core/utils/cache_helper.dart`
- [X] T006 [P] Refactor official bundle manifest, city-catalog, and decoded-day models in `lib/core/models/official_city_catalog_entry.dart`, `lib/core/models/umm_al_qura_bundle_manifest.dart`, and `lib/core/models/umm_al_qura_schedule_day.dart`
- [X] T007 [P] Add Hijri-first supported-window, date-availability, and month-navigation helper logic in `lib/core/helpers/prayer_calendar_helper.dart` and `lib/core/models/gregorian_coverage_window.dart`
- [X] T008 [P] Update official catalog loading and gzip day decoding in `lib/core/services/official_city_catalog_service.dart` and `lib/core/services/umm_al_qura_bundle_service.dart`
- [X] T009 [P] Update official prayer-day persistence and stale-cache merge support in `lib/core/helpers/prayer_calendar_hive_helper.dart` and `lib/core/models/prayer_calendar_day.dart`
- [X] T010 [P] Expose shared supported-window, month-navigation, and recovery interfaces in `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/controllers/cubits/appcubit/app_state.dart`
- [X] T011 [P] Add shared localized copy for supported-range, read-only, refresh, and large-screen calendar guidance in `assets/translations/ar.json`, `assets/translations/en.json`, and `assets/translations/bn.json`
- [X] T012 [P] Update curated Saudi city metadata and alias resolution for bundle-backed cities in `lib/data/data/city_country_data.dart` and `lib/core/helpers/location_helper.dart`

**Checkpoint**: The app can parse the shipped bundle, derive the supported Hijri window, expose month-navigation state, and persist official bundle-backed days with refresh metadata.

---

## Phase 3: User Story 1 - Guided Offline City Setup (Priority: P1) 🎯 MVP

**Goal**: Let the operator choose any shipped bundle city once and keep seeing today's official prayer times offline after restart.

**Independent Test**: Disable internet, select a city from the offline catalog, confirm today's schedule appears, restart the app offline, and verify the city plus today's official times are restored automatically.

### Tests for User Story 1

- [X] T013 [P] [US1] Add same-day official hydration and source-token coverage in `test/umm_al_qura_bundle_service_test.dart`
- [X] T014 [P] [US1] Add offline city picker and saved `bundleId` restore coverage in `test/select_location_offline_city_picker_test.dart`
- [X] T015 [P] [US1] Add AppCubit offline startup and selected-city restore coverage in `test/app_cubit_offline_schedule_test.dart`

### Implementation for User Story 1

- [X] T016 [US1] Wire selected-city persistence and startup hydration through the official bundle path in `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/controllers/cubits/appcubit/app_state.dart`
- [X] T017 [US1] Update the offline city selection flow and recoverable selection errors in `lib/core/utils/selection_dialoge.dart` and `lib/views/select_location/select_location_screen.dart`
- [X] T018 [US1] Route home and same-day official prayer-time reads through the manifest-token-aware cache in `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/core/helpers/prayer_calendar_hive_helper.dart`
- [X] T019 [US1] Preserve saved `bundleId` resolution across shipped bundle updates in `lib/core/services/official_city_catalog_service.dart` and `lib/core/utils/cache_helper.dart`

**Checkpoint**: User Story 1 is complete when offline city selection and same-day schedule restore work without any network dependency.

---

## Phase 4: User Story 2 - Browse Fixed Multi-Year Official Schedule (Priority: P2)

**Goal**: Let the user browse the supported Hijri-first schedule window offline with clear Gregorian day context and a persistent large-screen month side panel.

**Independent Test**: With internet disabled, open the calendar for a selected city on both compact and large-screen layouts, browse dates near the start, middle, and end of the supported window, and confirm the month navigation stays obvious, readable, and easy to operate.

### Tests for User Story 2

- [X] T020 [P] [US2] Add mixed supported-window and date-availability unit coverage in `test/prayer_calendar_helper_test.dart` and `test/umm_al_qura_calendar_window_test.dart`
- [X] T021 [P] [US2] Add Hijri-first calendar navigation and boundary widget coverage in `test/hijri_prayer_calendar_window_test.dart`
- [X] T022 [P] [US2] Add large-screen side-panel golden coverage in `test/hijri_prayer_calendar_large_screen_test.dart` and `test/goldens/hijri_prayer_calendar_large_screen_panel.png`

### Implementation for User Story 2

- [X] T023 [US2] Implement the Hijri-first supported-window and date-availability rules in `lib/core/helpers/prayer_calendar_helper.dart` and `lib/core/models/gregorian_coverage_window.dart`
- [X] T024 [US2] Teach official range loading to hydrate supported Hijri-year windows in `lib/core/services/umm_al_qura_bundle_service.dart` and `lib/controllers/cubits/appcubit/app_cubit.dart`
- [X] T025 [P] [US2] Expose supported Hijri years, month navigation options, and supported-range labels from `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/controllers/cubits/appcubit/app_state.dart`
- [X] T026 [P] [US2] Add localized supported-range labels and large-screen month-navigation copy in `assets/translations/ar.json`, `assets/translations/en.json`, and `assets/translations/bn.json`
- [X] T027 [US2] Refactor the compact Hijri calendar navigation and day presentation in `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart`
- [X] T028 [US2] Implement the persistent large-screen Hijri month side panel, active-month emphasis, and auto-scroll synchronization in `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart`

**Checkpoint**: User Story 2 is complete when the supported multi-year schedule loads offline with Hijri-first browsing on small screens and a clearly readable side panel on large screens.

---

## Phase 5: User Story 3 - Trust Coverage and Keep Existing Operations (Priority: P3)

**Goal**: Preserve manual adjustments, refresh stale official cache safely, and make unsupported or read-only dates obvious without breaking saved city state.

**Independent Test**: Try unsupported future dates and past dates inside the current Hijri year, then simulate a newer bundle token and verify manual adhan or iqama overrides still apply after official days refresh.

### Tests for User Story 3

- [X] T029 [P] [US3] Add bundle-refresh cache invalidation and override-merge coverage in `test/prayer_calendar_hive_helper_test.dart` and `test/prayer_calendar_day_test.dart`
- [X] T030 [P] [US3] Add out-of-range recovery, read-only past-date, and refresh messaging widget coverage in `test/offline_calendar_guidance_test.dart`
- [X] T031 [P] [US3] Add mixed-window completeness validation coverage in `test/umm_al_qura_import_test.dart`

### Implementation for User Story 3

- [X] T032 [US3] Align import-time completeness validation with the final supported Hijri-year rule in `tool/umm_al_qura_import.dart` and `lib/core/models/umm_al_qura_bundle_manifest.dart`
- [X] T033 [P] [US3] Preserve manual adhan and iqama overrides while refreshing stale official days in `lib/core/models/prayer_calendar_day.dart`, `lib/core/helpers/prayer_calendar_hive_helper.dart`, and `lib/controllers/cubits/appcubit/app_cubit.dart`
- [X] T034 [US3] Implement manifest-token comparison and lazy official cache-refresh orchestration in `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/core/utils/cache_helper.dart`
- [X] T035 [P] [US3] Expose out-of-range recovery and stale-city fallback state in `lib/controllers/cubits/appcubit/app_state.dart` and `lib/controllers/cubits/appcubit/app_cubit.dart`
- [X] T036 [US3] Implement read-only past-date guidance, out-of-range recovery, and refresh-safe messaging in `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart` and `lib/views/select_location/select_location_screen.dart`

**Checkpoint**: User Story 3 is complete when unsupported dates are explained clearly and newer shipped bundles refresh official base data without breaking overrides or saved city state.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Refresh generated outputs and run the final targeted verification sweep.

- [X] T037 [P] Regenerate asset and localization outputs in `lib/gen/assets.gen.dart`, `lib/generated/locale_keys.g.dart`, and `lib/generated/codegen_loader.g.dart`
- [X] T038 [P] Validate the offline walkthrough in `specs/001-umm-al-qura-offline/quickstart.md` against `test/app_cubit_offline_schedule_test.dart`, `test/select_location_offline_city_picker_test.dart`, `test/hijri_prayer_calendar_window_test.dart`, `test/hijri_prayer_calendar_large_screen_test.dart`, and `test/offline_calendar_guidance_test.dart`
- [X] T039 [P] Run `flutter analyze`, targeted `flutter test`, `dart run build_runner build --delete-conflicting-outputs`, and `git diff --check` for touched files under `lib/`, `test/`, and `tool/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup** has no dependencies and starts immediately.
- **Phase 2: Foundational** depends on Phase 1 and blocks every user story.
- **Phase 3: US1** depends on Phase 2 and is the MVP slice.
- **Phase 4: US2** depends on Phase 2 and can proceed independently once the shared bundle and navigation model exist.
- **Phase 5: US3** depends on Phase 2; if one developer owns the calendar surface, sequence its UI work after US2 to reduce churn in `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart`.
- **Phase 6: Polish** depends on every story you choose to ship.

### User Story Dependencies

- **US1**: No dependency on other user stories after the foundational phase is complete.
- **US2**: No hard dependency on US1 behavior, but it reuses the same official bundle services and supported-window helpers from Phase 2.
- **US3**: No hard dependency on US1 or US2, but it extends the shared cache-refresh, override, and calendar messaging flows touched by both.

### Within Each User Story

- Update the listed tests before implementation when feasible.
- Finish shared helper or service logic before cubit wiring.
- Finish cubit wiring before UI integration.
- Verify each story independently before moving to the next priority.

### Parallel Opportunities

- `T006`, `T007`, `T008`, `T009`, `T010`, `T011`, and `T012` can run in parallel once `T005` is done.
- `T013`, `T014`, and `T015` can run in parallel for US1 verification.
- `T020`, `T021`, and `T022` can run in parallel for US2 verification.
- `T025` and `T026` can run in parallel once `T024` stabilizes.
- `T029`, `T030`, and `T031` can run in parallel for US3 verification.
- `T032` and `T033` can run in parallel before `T034`, `T035`, and `T036`.
- `T037`, `T038`, and `T039` can run in parallel at the end if different people own codegen, walkthrough, and verification.

---

## Parallel Example: User Story 1

```bash
# Launch US1 verification work together:
Task: "T013 [US1] Add same-day official hydration and source-token coverage in test/umm_al_qura_bundle_service_test.dart"
Task: "T014 [US1] Add offline city picker and saved bundleId restore coverage in test/select_location_offline_city_picker_test.dart"
Task: "T015 [US1] Add AppCubit offline startup and selected-city restore coverage in test/app_cubit_offline_schedule_test.dart"
```

## Parallel Example: User Story 2

```bash
# Launch US2 verification work together:
Task: "T020 [US2] Add mixed supported-window and date-availability unit coverage in test/prayer_calendar_helper_test.dart and test/umm_al_qura_calendar_window_test.dart"
Task: "T021 [US2] Add Hijri-first calendar navigation and boundary widget coverage in test/hijri_prayer_calendar_window_test.dart"
Task: "T022 [US2] Add large-screen side-panel golden coverage in test/hijri_prayer_calendar_large_screen_test.dart and test/goldens/hijri_prayer_calendar_large_screen_panel.png"
```

## Parallel Example: User Story 3

```bash
# Launch US3 verification work together:
Task: "T029 [US3] Add bundle-refresh cache invalidation and override-merge coverage in test/prayer_calendar_hive_helper_test.dart and test/prayer_calendar_day_test.dart"
Task: "T030 [US3] Add out-of-range recovery, read-only past-date, and refresh messaging widget coverage in test/offline_calendar_guidance_test.dart"
Task: "T031 [US3] Add mixed-window completeness validation coverage in test/umm_al_qura_import_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Validate offline city selection, same-day hydration, and restart restore before expanding scope.

### Incremental Delivery

1. Ship US1 first to land offline city selection and today's official schedule.
2. Add US2 next to unlock Hijri-first long-range browsing and the large-screen side panel without destabilizing the MVP setup flow.
3. Add US3 last to harden unsupported-date UX, bundle-refresh behavior, and override continuity.

### Parallel Team Strategy

1. One developer handles Phase 1 and Phase 2 shared infrastructure.
2. After Phase 2:
   - Developer A can own US1 flow wiring in `lib/views/select_location/` and `lib/controllers/cubits/appcubit/`
   - Developer B can own US2 calendar browsing and side-panel UX in `lib/views/prayer_calendar/`
   - Developer C can own US3 validation and cache-refresh hardening in `tool/`, `lib/core/helpers/`, and `lib/core/models/`
