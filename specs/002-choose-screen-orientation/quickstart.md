# Quickstart: Display Rotation Direction Picker

## Goal

Implement a direct picker for app display direction so users can choose normal, rotated right, upside down, or rotated left without cycling through intermediate directions.

## Implementation Walkthrough

1. Confirm the current feature context:

   ```bash
   cat .specify/feature.json
   ```

2. Review the relevant files:

   ```bash
   sed -n '1,120p' lib/controllers/cubits/rotation_cubit/rotation_cubit.dart
   sed -n '80,150p' lib/main.dart
   sed -n '60,90p' lib/views/home/components/cusotm_drawer.dart
   ```

3. Keep `UiRotationCubit` as the state owner. Add a direct, intention-revealing method if needed, but keep normalization and persistence in the cubit/cache layer.

4. Replace the drawer's cycle-only action with a direction picker. The picker must show all four options and the current selected state.

5. Add localized copy to:

   ```text
   assets/translations/ar.json
   assets/translations/en.json
   assets/translations/bn.json
   ```

6. Refresh generated localization outputs if the project generation workflow requires it.

7. Add or update tests:

   ```bash
   flutter test test/ui_rotation_cubit_test.dart
   flutter test test/display_direction_picker_test.dart
   ```

8. Run targeted analysis:

   ```bash
   flutter analyze \
     lib/controllers/cubits/rotation_cubit/rotation_cubit.dart \
     lib/main.dart \
     lib/views/home/components/cusotm_drawer.dart \
     test/ui_rotation_cubit_test.dart \
     test/display_direction_picker_test.dart
   ```

9. Run whitespace validation:

   ```bash
   git diff --check
   ```

## Manual Verification

- Open the app with no saved direction and confirm Normal is selected.
- Open the direction picker and select each option.
- Confirm each selected option applies immediately.
- Reopen the picker and confirm the active option is marked.
- Restart the app and confirm the saved direction restores.
- Repeat enough checks in Arabic, English, and Bengali to verify labels are readable.
- Verify display-board mode remains display-board mode after changing direction.

## Expected Files

```text
lib/controllers/cubits/rotation_cubit/rotation_cubit.dart
lib/views/home/components/cusotm_drawer.dart
assets/translations/ar.json
assets/translations/en.json
assets/translations/bn.json
lib/generated/codegen_loader.g.dart
lib/generated/locale_keys.g.dart
test/ui_rotation_cubit_test.dart
test/display_direction_picker_test.dart
```
