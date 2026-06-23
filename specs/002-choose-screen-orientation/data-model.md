# Data Model: Display Rotation Direction Picker

## Entity: DisplayDirectionPreference

Represents the app-level display direction selected by the user.

### Fields

- `quarterTurns`: Integer value from `0` to `3`.
- `effectiveLayoutOrientation`: Derived display layout orientation after combining physical device orientation with the selected quarter turns.
- `isDefault`: True when `quarterTurns` is `0` and the app follows the normal physical device direction.

### Validation Rules

- `quarterTurns` must always normalize into `0`, `1`, `2`, or `3`.
- Missing or invalid saved values resolve to `0`.
- Saving a direction must not mutate selected mosque location, prayer schedule, display-board mode, language, or background settings.

### State Transitions

```text
normal (0)       -> rotated right (1) | upside down (2) | rotated left (3)
rotated right (1)-> normal (0) | upside down (2) | rotated left (3)
upside down (2)  -> normal (0) | rotated right (1) | rotated left (3)
rotated left (3) -> normal (0) | rotated right (1) | upside down (2)
```

Selecting the active state again is a no-op that keeps the selected-state indicator stable.

## Entity: DirectionOption

Represents one selectable choice in the direction picker.

### Fields

- `quarterTurns`: The preference value this option applies.
- `label`: Localized primary label, such as "Normal", "Rotate right", "Upside down", or "Rotate left".
- `description`: Optional localized helper text that explains the visual result in user-friendly wording.
- `isSelected`: Derived from whether the option's `quarterTurns` matches the current preference.

### Validation Rules

- Exactly four options must be available.
- Every option must map to a unique `quarterTurns` value.
- Every option must have localized copy for `ar`, `en`, and `bn`, or a readable fallback.
- The selected option must be visually distinguishable without relying on color alone.

## Entity: DirectionPickerSession

Represents a single user interaction with the picker.

### Fields

- `initialPreference`: The preference active when the picker opens.
- `selectedPreference`: The preference chosen by the user.
- `dismissalReason`: Whether the picker closed because the user selected an option or cancelled/dismissed the picker.

### Validation Rules

- Opening the picker must not change the active preference.
- Cancelling or dismissing the picker without selection must preserve `initialPreference`.
- Selecting an option must apply and save `selectedPreference` immediately.
- The user must be able to visually inspect the updated direction after selection, without an overlay permanently hiding the result.
