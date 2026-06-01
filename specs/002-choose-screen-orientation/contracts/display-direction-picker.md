# UI Contract: Display Direction Picker

## Purpose

Define the user-visible contract for replacing cycle-only screen rotation with a direct direction picker.

## Entry Point

- The existing user-facing screen rotation action remains discoverable from the current drawer/settings area.
- Activating the entry point opens a picker instead of immediately cycling to the next direction.
- The entry point label should communicate choice, such as "Screen direction" or equivalent localized wording.

## Options

The picker must present exactly four choices:

| Direction | Meaning | Required behavior |
|-----------|---------|-------------------|
| Normal | Use the app's normal device-following direction | Sets preference to `0` |
| Rotated right | Rotate the app UI one quarter turn clockwise | Sets preference to `1` |
| Upside down | Rotate the app UI half a turn | Sets preference to `2` |
| Rotated left | Rotate the app UI one quarter turn counter-clockwise | Sets preference to `3` |

## Selected State

- The current direction is marked when the picker opens.
- The selected state must be visible in Arabic, English, and Bengali layouts.
- The selected state must not depend on color alone; text, iconography, checkmark, border, or weight may be used.

## Selection Behavior

- Selecting any option applies that exact direction immediately.
- Selecting the currently active option keeps the same state and closes or leaves the picker stable according to the chosen UI pattern.
- Selecting a new option must not navigate away from the current app mode, reset display-board scheduling, or reload prayer setup.
- The user must not need to pass through intermediate directions.

## Dismissal Behavior

- If the picker is cancelled or dismissed without choosing an option, the display direction remains unchanged.
- If the picker is opened from a drawer or menu, the result must not be hidden behind an overlay after selection.

## Localization

- User-facing copy must be available for `ar`, `en`, and `bn`.
- Labels should be friendly and understandable; numeric degree hints may be secondary but must not be the only explanation.
- Longer localized labels must remain readable in compact and large-screen layouts.

## Accessibility and Readability

- Tap targets must be large enough for display setup use.
- Text must remain legible over existing backgrounds and within drawer/settings constraints.
- The picker must remain usable in portrait, landscape, and already-rotated app states.

## Persistence

- The chosen direction is saved immediately.
- Reopening the app restores the saved direction.
- Missing saved values default to Normal.
