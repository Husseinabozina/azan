---

description: "Task list for Offline Umm Al-Qura Prayer Times"
---

# Tasks: Offline Umm Al-Qura Prayer Times

**Input**: Design documents from `/specs/001-umm-al-qura-offline/`

**Prerequisites**: [plan.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/plan.md) (required), [spec.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/spec.md) (required for user stories), [research.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/research.md), [data-model.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/data-model.md), [contracts/](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/contracts/)

**Tests**: Include verification tasks for every story. This feature changes offline schedule logic, persistence, and UI, so it requires unit, state, and widget coverage plus final `flutter analyze` and targeted `flutter test` runs from [quickstart.md](/Users/husseinabozina/azan/specs/001-umm-al-qura-offline/quickstart.md).

**Organization**: Tasks are grouped by user story so each story can be implemented and tested independently after the shared foundation lands.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on incomplete tasks)
- **[Story]**: Which user story this task belongs to (`[US1]`, `[US2]`, `[US3]`)
- Every task includes the exact file path to change

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Bring the approved bundle into the repo and enable the Flutter app to load it.

- [X] T001 Update dependency and asset declarations in `pubspec.yaml` for `archive` support and `assets/data/umm_al_qura/v1/`
- [X] T002 Create the repo import/validation entry point in `tool/umm_al_qura_import.dart`
- [X] T003 Import the approved bundle into `assets/data/umm_al_qura/v1/manifest.json` and `assets/data/umm_al_qura/v1/cities/gz/`
- [X] T004 Refresh generated asset references in `lib/gen/assets.gen.dart` after the bundle assets are added

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the shared domain, caching, localization, and catalog plumbing that all user stories depend on.

**⚠️ CRITICAL**: Do not begin story work until this phase is complete.

- [X] T005 Extend persisted city serialization in `lib/core/models/city_option.dart` and `lib/core/utils/cache_helper.dart` for `bundleId`, `regionEn`, and alias-aware fields
- [X] T006 [P] Create bundle domain models in `lib/core/models/umm_al_qura_bundle_manifest.dart`, `lib/core/models/official_city_catalog_entry.dart`, `lib/core/models/umm_al_qura_schedule_day.dart`, and `lib/core/models/gregorian_coverage_window.dart`
- [X] T007 Implement shared manifest parsing, catalog loading, and day decoding in `lib/core/services/official_city_catalog_service.dart` and `lib/core/services/umm_al_qura_bundle_service.dart`
- [X] T008 Update shared schedule persistence helpers in `lib/core/helpers/prayer_calendar_helper.dart`, `lib/core/helpers/prayer_calendar_hive_helper.dart`, and `lib/core/models/prayer_calendar_day.dart` for bundle-based keys and official day hydration
- [X] T009 [P] Add shared localized copy for offline-city, support-window, read-only, and out-of-range states in `assets/translations/ar.json`, `assets/translations/en.json`, and `assets/translations/bn.json`
- [X] T010 [P] Add curated Saudi city metadata and alias mappings in `lib/data/data/city_country_data.dart` and `lib/core/helpers/location_helper.dart`

**Checkpoint**: The app can parse the shipped bundle, resolve a stable city catalog, and persist bundle-based day records.

---

## Phase 3: User Story 1 - Guided Offline City Setup (Priority: P1) 🎯 MVP

**Goal**: Let the operator pick any shipped bundle city once and reliably see today's official prayer times offline after restart.

**Independent Test**: Disable internet, select a city from the offline catalog, confirm today's schedule appears, restart the app offline, and verify the city plus today's official times are restored.

### Tests for User Story 1

- [X] T011 [P] [US1] Add catalog loading and same-day hydration coverage in `test/umm_al_qura_bundle_service_test.dart`
- [X] T012 [P] [US1] Add offline city picker widget coverage in `test/select_location_offline_city_picker_test.dart`
- [ ] T013 [P] [US1] Add AppCubit offline startup and city restore coverage in `test/app_cubit_offline_schedule_test.dart`

### Implementation for User Story 1

- [X] T014 [US1] Wire selected-city persistence and offline startup hydration in `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/controllers/cubits/appcubit/app_state.dart`
- [X] T015 [US1] Replace the hard-coded Saudi city picker with the official offline catalog in `lib/core/utils/selection_dialoge.dart` and `lib/views/select_location/select_location_screen.dart`
- [X] T016 [US1] Route home and daily prayer-time reads through the official bundle cache in `lib/controllers/cubits/appcubit/app_cubit.dart` and `lib/core/helpers/prayer_calendar_hive_helper.dart`
- [X] T017 [US1] Add localized recoverable catalog-load and offline-selection error states in `lib/views/select_location/select_location_screen.dart` and `assets/translations/ar.json`, `assets/translations/en.json`, `assets/translations/bn.json`

**Checkpoint**: User Story 1 is complete when offline city selection and same-day schedule restore work without any network dependency.

---

## Phase 4: User Story 2 - Browse Fixed Multi-Year Official Schedule (Priority: P2)

**Goal**: Let the user browse the full current Gregorian year plus the next 5 full Gregorian years offline while still seeing Hijri context for each day.

**Independent Test**: With internet disabled, open the calendar for a selected city, browse supported dates at the start, middle, and end of the fixed window, and verify each date resolves to the official timetable.

### Tests for User Story 2

- [X] T018 [P] [US2] Add Gregorian coverage-window unit coverage in `test/umm_al_qura_calendar_window_test.dart`
- [ ] T019 [P] [US2] Add fixed-window calendar widget coverage in `test/hijri_prayer_calendar_window_test.dart`

### Implementation for User Story 2

- [X] T020 [US2] Implement Gregorian support-window and availability-state helpers in `lib/core/helpers/prayer_calendar_helper.dart` and `lib/core/models/gregorian_coverage_window.dart`
- [X] T021 [US2] Teach range-based official day loading to `lib/core/services/umm_al_qura_bundle_service.dart` and `lib/controllers/cubits/appcubit/app_cubit.dart`
- [X] T022 [US2] Refactor `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart` to browse the current Gregorian year plus next 5 years while preserving Hijri labels and grouping
- [X] T023 [P] [US2] Add localized support-window labels and boundary hints in `assets/translations/ar.json`, `assets/translations/en.json`, and `assets/translations/bn.json`

**Checkpoint**: User Story 2 is complete when supported future dates load offline across the fixed window with clear localized range context.

---

## Phase 5: User Story 3 - Trust Coverage and Keep Existing Operations (Priority: P3)

**Goal**: Keep manual adjustments intact, block unsupported dates clearly, and make the supported range obvious so the official bundle never feels ambiguous.

**Independent Test**: Try unsupported future dates and past dates in the current year, verify the UI blocks them clearly, and confirm existing adhan/iqama overrides still apply on supported official days.

### Tests for User Story 3

- [X] T024 [P] [US3] Add bundle-key override persistence regression coverage in `test/prayer_calendar_hive_helper_test.dart` and `test/prayer_calendar_day_test.dart`
- [ ] T025 [P] [US3] Add out-of-range recovery and read-only past-date widget coverage in `test/offline_calendar_guidance_test.dart`
- [X] T026 [P] [US3] Add import-time completeness validation coverage in `test/umm_al_qura_import_test.dart`

### Implementation for User Story 3

- [X] T027 [P] [US3] Enforce shipped-bundle completeness validation in `tool/umm_al_qura_import.dart` and `lib/core/models/umm_al_qura_bundle_manifest.dart`
- [X] T028 [P] [US3] Preserve manual adhan and iqama overrides for bundle-based days in `lib/core/models/prayer_calendar_day.dart`, `lib/core/helpers/prayer_calendar_hive_helper.dart`, and `lib/controllers/cubits/appcubit/app_cubit.dart`
- [X] T029 [US3] Expose supported-window, out-of-range, and jump-back state from `lib/controllers/cubits/appcubit/app_state.dart` and `lib/controllers/cubits/appcubit/app_cubit.dart`
- [X] T030 [US3] Implement read-only past-date affordances and out-of-range recovery UI in `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart`

**Checkpoint**: User Story 3 is complete when unsupported dates are handled clearly and existing override behavior still works on top of official bundle data.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Refresh generated outputs and run the full targeted verification sweep.

- [X] T031 [P] Regenerate asset and localization outputs in `lib/gen/assets.gen.dart`, `lib/generated/locale_keys.g.dart`, and `lib/generated/codegen_loader.g.dart`
- [ ] T032 [P] Validate the offline walkthrough in `specs/001-umm-al-qura-offline/quickstart.md` against `test/umm_al_qura_bundle_service_test.dart`, `test/select_location_offline_city_picker_test.dart`, and `test/hijri_prayer_calendar_window_test.dart`
- [X] T033 [P] Run the `flutter analyze` and targeted `flutter test` commands documented in `specs/001-umm-al-qura-offline/quickstart.md` for the touched files under `lib/` and `test/`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1: Setup** has no dependencies and starts immediately.
- **Phase 2: Foundational** depends on Phase 1 and blocks every user story.
- **Phase 3: US1** depends on Phase 2 and is the MVP slice.
- **Phase 4: US2** depends on Phase 2 and can proceed independently once the shared bundle services exist.
- **Phase 5: US3** depends on Phase 2; if one developer owns the calendar screen, sequence its UI work after US2 to avoid churn in `lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart`.
- **Phase 6: Polish** depends on every story you choose to ship.

### User Story Dependencies

- **US1**: No dependency on other user stories after the foundational phase is done.
- **US2**: No dependency on US1 behavior, but it reuses the same shared bundle services and cached official days from Phase 2.
- **US3**: No hard dependency on US1 or US2, but it extends the calendar and override flows touched by both.

### Within Each User Story

- Write or update the listed tests before implementation when possible.
- Finish data/service logic before cubit wiring.
- Finish cubit wiring before screen integration.
- Verify each story independently before moving to the next priority.

### Parallel Opportunities

- `T006`, `T009`, and `T010` can run in parallel once `T005` is done.
- `T011`, `T012`, and `T013` can run in parallel for US1 verification.
- `T018` and `T019` can run in parallel for US2 verification.
- `T023` can run in parallel with `T022` once the window rules in `T020` are stable.
- `T024`, `T025`, and `T026` can run in parallel for US3 verification.
- `T027` and `T028` can run in parallel before `T029` and `T030`.
- `T031`, `T032`, and `T033` can run in parallel at the end if different people own codegen, walkthrough, and verification.

---

## Parallel Example: User Story 1

```bash
# Launch US1 verification work together:
Task: "T011 [US1] Add catalog loading and same-day hydration coverage in test/umm_al_qura_bundle_service_test.dart"
Task: "T012 [US1] Add offline city picker widget coverage in test/select_location_offline_city_picker_test.dart"
Task: "T013 [US1] Add AppCubit offline startup and city restore coverage in test/app_cubit_offline_schedule_test.dart"
```

## Parallel Example: User Story 2

```bash
# Launch US2 verification together:
Task: "T018 [US2] Add Gregorian coverage-window unit coverage in test/umm_al_qura_calendar_window_test.dart"
Task: "T019 [US2] Add fixed-window calendar widget coverage in test/hijri_prayer_calendar_window_test.dart"

# Split UI copy from calendar implementation:
Task: "T022 [US2] Refactor lib/views/prayer_calendar/hijri_prayer_calendar_screen.dart to browse the fixed window"
Task: "T023 [US2] Add localized support-window labels and boundary hints in assets/translations/ar.json, assets/translations/en.json, and assets/translations/bn.json"
```

## Parallel Example: User Story 3

```bash
# Launch US3 verification together:
Task: "T024 [US3] Add bundle-key override persistence regression coverage in test/prayer_calendar_hive_helper_test.dart and test/prayer_calendar_day_test.dart"
Task: "T025 [US3] Add out-of-range recovery and read-only past-date widget coverage in test/offline_calendar_guidance_test.dart"
Task: "T026 [US3] Add import-time completeness validation coverage in test/umm_al_qura_import_test.dart"
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
2. Add US2 next to unlock full fixed-window browsing without destabilizing the MVP setup flow.
3. Add US3 last to harden unsupported-date UX, import validation, and override continuity.

### Parallel Team Strategy

1. One developer handles Phase 1 and Phase 2 shared infrastructure.
2. After Phase 2:
   - Developer A can own US1 flow wiring in `lib/views/select_location/` and `lib/controllers/cubits/appcubit/`
   - Developer B can own US2 calendar browsing in `lib/views/prayer_calendar/`
   - Developer C can own US3 validation and override hardening in `tool/` plus `lib/core/helpers/`
