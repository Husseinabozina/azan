# Research: Display Rotation Direction Picker

## Decision: Keep the existing quarter-turn integer as the source of truth

**Rationale**: The app already represents display direction as normalized quarter turns with values `0`, `1`, `2`, and `3`, and the root app already derives effective landscape/portrait layout from that value. Keeping this model avoids introducing a parallel setting and preserves existing persistence behavior.

**Alternatives considered**:

- Add a new enum-backed preference separate from quarter turns. Rejected because it duplicates an existing persisted concept and creates migration risk.
- Return to boolean landscape/portrait state. Rejected because it cannot represent upside-down portrait or reverse landscape.

## Decision: Add direct selection behavior instead of cycle-only behavior

**Rationale**: The user problem is not the ability to rotate; it is the need to choose a known mounted-display direction without overshooting. Direct selection lets users move from any current direction to any target direction in one explicit choice.

**Alternatives considered**:

- Keep only the current cycle button. Rejected because users must tap repeatedly and infer the current state.
- Add separate "flip 180" and "rotate 90" controls. Rejected because it increases mental load and still requires users to reason about combined actions.

## Decision: Use the current drawer rotation entry point for the first version

**Rationale**: The existing "Rotate screen" action is already where administrators expect display orientation control. Replacing that action with a picker keeps discoverability stable while improving precision.

**Alternatives considered**:

- Move the control to a new display setup screen. Deferred because the current request is scoped to choosing direction, and moving the control could broaden navigation and testing scope.
- Show the picker during first-run setup. Deferred because first-run location setup is a separate flow and this feature must not alter selected location or prayer data setup.

## Decision: Use clear localized direction labels plus selected-state feedback

**Rationale**: Mosque display setup is often done quickly and sometimes from a distance. Labels should be understandable without relying only on numeric degrees. A visible selected state prevents the user from guessing the current direction.

**Alternatives considered**:

- Degree-only labels such as `0°`, `90°`, `180°`, `270°`. Rejected as the only wording because it is less friendly for non-technical users, though degree hints can be used as secondary text if helpful.
- Icon-only options. Rejected because icons alone can be ambiguous across languages and mounted-screen situations.

## Decision: Preserve app-level UI rotation, not platform orientation forcing

**Rationale**: The app-level rotation approach avoids the black-window and letterboxing problems previously associated with platform orientation forcing on large displays. The feature should only change how the user chooses the existing rotation state.

**Alternatives considered**:

- Use platform orientation APIs for each option. Rejected because it can reintroduce letterboxing and varies by device/OS.
- Rotate only individual home screens. Rejected because settings, drawer, display-board, and navigation surfaces must remain consistently oriented.
