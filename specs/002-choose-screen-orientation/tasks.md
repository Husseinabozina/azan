# Tasks: Display Rotation Direction Picker

**Input**: Design documents from `/specs/002-choose-screen-orientation/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/display-direction-picker.md](./contracts/display-direction-picker.md), [quickstart.md](./quickstart.md)

**Tests**: Required by the feature specification and plan because this change affects app-level state, persistence, localization, and user interaction.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested as an independent increment.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the active feature context and the existing rotation entry points before implementation.

- [X] T001 Verify `.specify/feature.json` points to `specs/002-choose-screen-orientation` and keep it aligned with `specs/002-choose-screen-orientation/plan.md`
- [X] T002 Review current app-level rotation flow in `lib/controllers/cubits/rotation_cubit/rotation_cubit.dart`, `lib/main.dart`, and `lib/views/home/components/cusotm_drawer.dart`
- [X] T003 [P] Review existing translation and generated localization structure in `assets/translations/ar.json`, `assets/translations/en.json`, `assets/translations/bn.json`, `lib/generated/codegen_loader.g.dart`, and `lib/generated/locale_keys.g.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Prepare shared state and copy foundations that all stories depend on.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Add an intention-revealing direct selection method for normalized display direction in `lib/controllers/cubits/rotation_cubit/rotation_cubit.dart`
- [X] T005 [P] Add base localization keys for the picker title, current-selection label, and four direction option labels in `assets/translations/ar.json`, `assets/translations/en.json`, and `assets/translations/bn.json`
- [X] T006 Refresh generated localization outputs for the new direction keys in `lib/generated/codegen_loader.g.dart` and `lib/generated/locale_keys.g.dart`
- [X] T007 [P] Add or update state coverage for direct display direction selection and no-op same-direction selection in `test/ui_rotation_cubit_test.dart`

**Checkpoint**: The app has shared state and localized copy ready for a direct direction picker.

---

## Phase 3: User Story 1 - Choose Exact Display Direction (Priority: P1) MVP

**Goal**: Users can open the rotation control and select normal, rotated right, upside down, or rotated left directly.

**Independent Test**: Open the direction control, confirm all four choices are visible, select each direction, and confirm the exact quarter-turn is applied without cycling through intermediate states.

### Tests for User Story 1

- [X] T008 [P] [US1] Add widget test coverage that opens the direction picker and finds all four choices in `test/display_direction_picker_test.dart`
- [X] T009 [P] [US1] Add widget test coverage that selecting each picker option calls the exact target direction in `test/display_direction_picker_test.dart`
- [X] T010 [P] [US1] Add widget test coverage that the active direction is visibly marked when the picker opens in `test/display_direction_picker_test.dart`

### Implementation for User Story 1

- [X] T011 [P] [US1] Create a reusable display direction picker component in `lib/views/home/components/display_direction_picker.dart`
- [X] T012 [US1] Replace the drawer's cycle-only rotate action with opening the direction picker in `lib/views/home/components/cusotm_drawer.dart`
- [X] T013 [US1] Wire picker option selection to the direct rotation cubit method in `lib/views/home/components/display_direction_picker.dart`
- [X] T014 [US1] Ensure the picker dismissal lets users see the newly applied direction instead of hiding it behind the drawer or dialog in `lib/views/home/components/cusotm_drawer.dart`

**Checkpoint**: User Story 1 is independently usable as the MVP; users can choose any direction directly.

---

## Phase 4: User Story 2 - Preserve Chosen Direction (Priority: P2)

**Goal**: The selected direction remains active after closing menus, navigating across app surfaces, and reopening the app.

**Independent Test**: Select a direction, reopen the picker, navigate away and back, restart app state in tests, and confirm the same direction remains active and marked.

### Tests for User Story 2

- [X] T015 [P] [US2] Add persistence restore coverage for all four direction values in `test/ui_rotation_cubit_test.dart`
- [X] T016 [P] [US2] Add widget coverage that reopening the picker marks the previously selected direction in `test/display_direction_picker_test.dart`
- [X] T017 [P] [US2] Add widget or state coverage that changing direction does not alter display-board mode assumptions in `test/display_direction_picker_test.dart`

### Implementation for User Story 2

- [X] T018 [US2] Verify direct selection persists through existing cache helpers in `lib/controllers/cubits/rotation_cubit/rotation_cubit.dart` and `lib/core/utils/cache_helper.dart`
- [X] T019 [US2] Ensure app-level restoration continues to read the saved direction at startup in `lib/main.dart` and `lib/controllers/cubits/rotation_cubit/rotation_cubit.dart`
- [X] T020 [US2] Ensure the picker reads current state from the provided `UiRotationCubit` instead of keeping separate local direction state in `lib/views/home/components/display_direction_picker.dart`

**Checkpoint**: User Stories 1 and 2 both work; chosen direction is direct, visible, saved, and restored.

---

## Phase 5: User Story 3 - Understand Choices in Supported Languages (Priority: P3)

**Goal**: Arabic, English, and Bengali users can understand the direction choices and selected state without relying on technical degree-only labels.

**Independent Test**: Switch each supported locale, open the picker, and confirm option labels and selected-state text are readable and meaningful in compact and large layouts.

### Tests for User Story 3

- [X] T021 [P] [US3] Add localization assertions for Arabic direction picker labels in `test/display_direction_picker_test.dart`
- [X] T022 [P] [US3] Add localization assertions for English direction picker labels in `test/display_direction_picker_test.dart`
- [X] T023 [P] [US3] Add localization assertions for Bengali direction picker labels in `test/display_direction_picker_test.dart`
- [X] T024 [P] [US3] Add compact/large constraint readability coverage for picker labels and selected state in `test/display_direction_picker_test.dart`

### Implementation for User Story 3

- [X] T025 [US3] Refine Arabic labels and helper text for friendly direction wording in `assets/translations/ar.json`
- [X] T026 [US3] Refine English labels and helper text for friendly direction wording in `assets/translations/en.json`
- [X] T027 [US3] Refine Bengali labels and helper text for friendly direction wording in `assets/translations/bn.json`
- [X] T028 [US3] Regenerate localization outputs after label refinements in `lib/generated/codegen_loader.g.dart` and `lib/generated/locale_keys.g.dart`
- [X] T029 [US3] Adjust picker layout for readable labels and non-color-only selected state in `lib/views/home/components/display_direction_picker.dart`

**Checkpoint**: All user stories are independently functional and localized.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and cleanup across all stories.

- [X] T030 [P] Run targeted state tests for rotation behavior in `test/ui_rotation_cubit_test.dart`
- [X] T031 [P] Run targeted widget tests for the picker in `test/display_direction_picker_test.dart`
- [X] T032 Run targeted analyzer on `lib/controllers/cubits/rotation_cubit/rotation_cubit.dart`, `lib/main.dart`, `lib/views/home/components/cusotm_drawer.dart`, `lib/views/home/components/display_direction_picker.dart`, `test/ui_rotation_cubit_test.dart`, and `test/display_direction_picker_test.dart`
- [X] T033 Run whitespace validation for `.specify/feature.json`, `AGENTS.md`, `specs/002-choose-screen-orientation/tasks.md`, `lib/controllers/cubits/rotation_cubit/rotation_cubit.dart`, `lib/views/home/components/cusotm_drawer.dart`, `lib/views/home/components/display_direction_picker.dart`, `assets/translations/ar.json`, `assets/translations/en.json`, `assets/translations/bn.json`, `lib/generated/codegen_loader.g.dart`, `lib/generated/locale_keys.g.dart`, `test/ui_rotation_cubit_test.dart`, and `test/display_direction_picker_test.dart`
- [X] T034 [P] Manually verify the quickstart checklist in `specs/002-choose-screen-orientation/quickstart.md`
- [X] T035 Update implementation notes or task completion status in `specs/002-choose-screen-orientation/tasks.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup; blocks all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational; MVP scope.
- **User Story 2 (Phase 4)**: Depends on Foundational and integrates naturally after US1 because it verifies the picker state remains saved and restored.
- **User Story 3 (Phase 5)**: Depends on Foundational and can proceed after US1 picker structure exists.
- **Polish (Phase 6)**: Depends on the desired user stories being complete.

### User Story Dependencies

- **US1 - Choose Exact Display Direction**: Can start after Foundational and is the recommended MVP.
- **US2 - Preserve Chosen Direction**: Can start after Foundational, but should validate against the picker produced by US1 for full user value.
- **US3 - Understand Choices in Supported Languages**: Can start after Foundational, but layout refinement depends on the picker component from US1.

### Parallel Opportunities

- T003 can run in parallel with T002.
- T005 and T007 can run in parallel after T004 is scoped.
- T008, T009, and T010 can be written in parallel because they target separate picker behaviors in the same test file but do not depend on each other conceptually.
- T015, T016, and T017 can be designed in parallel after US1 is complete.
- T021, T022, T023, and T024 can be designed in parallel for separate locale/readability concerns.
- T030, T031, and T034 can run in parallel during polish.

---

## Parallel Example: User Story 1

```bash
Task: "T008 Add widget test coverage that opens the direction picker and finds all four choices in test/display_direction_picker_test.dart"
Task: "T009 Add widget test coverage that selecting each picker option calls the exact target direction in test/display_direction_picker_test.dart"
Task: "T010 Add widget test coverage that the active direction is visibly marked when the picker opens in test/display_direction_picker_test.dart"
```

---

## Parallel Example: User Story 2

```bash
Task: "T015 Add persistence restore coverage for all four direction values in test/ui_rotation_cubit_test.dart"
Task: "T016 Add widget coverage that reopening the picker marks the previously selected direction in test/display_direction_picker_test.dart"
Task: "T017 Add widget or state coverage that changing direction does not alter display-board mode assumptions in test/display_direction_picker_test.dart"
```

---

## Parallel Example: User Story 3

```bash
Task: "T021 Add localization assertions for Arabic direction picker labels in test/display_direction_picker_test.dart"
Task: "T022 Add localization assertions for English direction picker labels in test/display_direction_picker_test.dart"
Task: "T023 Add localization assertions for Bengali direction picker labels in test/display_direction_picker_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 setup.
2. Complete Phase 2 foundation.
3. Complete Phase 3 User Story 1.
4. Stop and validate that users can choose exact display directions directly.
5. Demo the MVP before adding persistence/readability refinements if needed.

### Incremental Delivery

1. Deliver US1 so the cycle-only UX is replaced by direct choice.
2. Deliver US2 so direction choice remains stable across menus, navigation, and restart.
3. Deliver US3 so all supported locales and layout constraints are polished.
4. Run Phase 6 validation before merge.

### Validation Commands

```bash
flutter test test/ui_rotation_cubit_test.dart
flutter test test/display_direction_picker_test.dart
flutter analyze lib/controllers/cubits/rotation_cubit/rotation_cubit.dart lib/main.dart lib/views/home/components/cusotm_drawer.dart lib/views/home/components/display_direction_picker.dart test/ui_rotation_cubit_test.dart test/display_direction_picker_test.dart
git diff --check
```
