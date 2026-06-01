# Implementation Plan: Display Rotation Direction Picker

**Branch**: `002-choose-screen-orientation` | **Date**: 2026-06-01 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-choose-screen-orientation/spec.md`

## Summary

Replace the current cycle-only "Rotate screen" action with a direct display direction picker so installers can choose the exact UI direction: normal, rotated right, upside down, or rotated left. The implementation will keep the existing app-level quarter-turn model and persistence, move the user interaction from repeated tapping to explicit selection, localize all visible copy, and verify both state transitions and the picker UI across supported locales.

## Technical Context

**Language/Version**: Dart `^3.9.2` / Flutter stable

**Primary Dependencies**: Flutter, `flutter_bloc`, `easy_localization`, `shared_preferences` through `CacheHelper`, existing responsive helpers in `lib/core/utils/mqscale.dart`

**Storage**: Existing `CacheHelper` / `SharedPreferences` key for UI rotation quarter turns; no new storage backend

**Testing**: `flutter_test` unit and widget tests, `flutter analyze`, targeted localization/generated-output verification when locale inputs change

**Target Platform**: Flutter app surfaces on Android/iOS phones and tablets plus mosque-oriented large-screen display workflows, including portrait, landscape, display-board, and rotated UI states

**Project Type**: Flutter application with shared app-level rotation state and localized settings/drawer surfaces

**Performance Goals**: Selecting a direction must update the visible UI within 1 second, avoid platform-level orientation changes that can cause letterboxing, and preserve smooth navigation/drawer interactions

**Constraints**: Preserve existing prayer-time, iqama, display-board, location, and schedule behavior; keep business/state logic out of presentation widgets; do not add dependencies; keep all user-facing copy localized for `ar`, `en`, and `bn`

**Scale/Scope**: Affects `UiRotationCubit`, app-level rotation application in `main.dart` only if picker semantics require helper additions, the drawer or equivalent rotation entry point, locale sources/generated keys, and targeted rotation tests. Does not change prayer calculations, screen assets, background selection, or platform orientation channels.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Prayer-time correctness**: PASS. The feature does not change prayer times, iqama timing, Hijri/Gregorian calendar logic, location lookup, timezone handling, or date-driven schedule behavior. Verification still includes smoke coverage that changing direction preserves current home/display-board mode rather than reloading prayer data.
- **Localized readability**: PASS. Impacted locales are `ar`, `en`, and `bn`. Impacted screen classes are phone, tablet, TV/desktop/web-style large screens, portrait, landscape, and rotated UI flows. The picker must use localized labels and a clear selected state that remains readable in compact drawer/settings constraints.
- **Architecture boundaries**: PASS. `UiRotationCubit` remains the owner of normalized quarter-turn state, while `CacheHelper` remains the persistence boundary. UI code presents direction options and calls cubit methods only; normalization, persistence, and effective layout orientation stay outside widgets.
- **Verification plan**: PASS. Required checks: `flutter analyze` on touched files; targeted `flutter test test/ui_rotation_cubit_test.dart`; widget coverage for the direction picker; localization/generated-key verification after editing `assets/translations/*.json`; and `git diff --check`.
- **Asset and dependency discipline**: PASS. No new assets or runtime dependencies are planned. Localization source changes may require generated localization output updates, but generated files must be refreshed from source rather than edited as standalone business logic.

## Project Structure

### Documentation (this feature)

```text
specs/002-choose-screen-orientation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── display-direction-picker.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── controllers/cubits/rotation_cubit/
│   └── rotation_cubit.dart
├── core/utils/
│   ├── cache_helper.dart
│   └── mqscale.dart
├── generated/
│   ├── codegen_loader.g.dart
│   └── locale_keys.g.dart
├── views/home/components/
│   └── cusotm_drawer.dart
└── main.dart

assets/
└── translations/
    ├── ar.json
    ├── en.json
    └── bn.json

test/
├── ui_rotation_cubit_test.dart
└── display_direction_picker_test.dart
```

**Structure Decision**: Keep the feature inside the existing rotation and drawer/settings boundaries. State and persistence stay in `lib/controllers/cubits/rotation_cubit/` and `lib/core/utils/cache_helper.dart`; presentation stays in `lib/views/home/components/`; localized copy starts in `assets/translations/` and generated locale outputs are refreshed through the existing generation workflow.

## Phase 0: Research

Research is captured in [research.md](./research.md) and resolves the implementation choices that matter for this UI change:

- keep the existing normalized quarter-turn integer model
- expose direct set-by-option behavior instead of adding a second rotation state
- use the current drawer rotation entry point for the first version
- use text-forward localized options with a selected-state indicator
- preserve app-level UI rotation instead of platform orientation forcing

## Phase 1: Design Artifacts

- [data-model.md](./data-model.md): defines display direction preference and direction option semantics, validation rules, and state transitions
- [contracts/display-direction-picker.md](./contracts/display-direction-picker.md): defines user-facing picker behavior, option labels, selected state, dismissal, persistence, and localization expectations
- [quickstart.md](./quickstart.md): lists implementation and verification steps for the picker, localization regeneration, and targeted tests
- `AGENTS.md`: updated to point future agents at this plan file for the active feature context

## Post-Design Constitution Check

- **Prayer-time correctness**: PASS. The design explicitly preserves all prayer, iqama, schedule, display-board mode, and selected-location data while changing only app-level display direction preference.
- **Localized readability**: PASS. The UI contract requires localized `ar`, `en`, and `bn` labels, a visible current selection, compact/large-screen readability, and no reliance on degree-only technical wording.
- **Architecture boundaries**: PASS. The data model keeps state transitions in the rotation cubit and persistence in the existing cache helper. Widgets remain selection surfaces and do not own normalization or saved-state rules.
- **Verification plan**: PASS. The quickstart identifies state tests, picker widget tests, analyzer, diff whitespace checks, and localization generation checks for all affected files.
- **Asset and dependency discipline**: PASS. No new dependency or image/font asset is introduced. Generated localization files are the only expected generated outputs if new translation keys are added.

## Complexity Tracking

No constitution violations or complexity exceptions are planned.
