# Feature Specification: Display Rotation Direction Picker

**Feature Branch**: `002-choose-screen-orientation`

**Created**: 2026-06-01

**Status**: Draft

**Input**: User description: "Instead of only rotating through four directions one tap at a time, let the user choose the exact display direction they want, such as through selectable options."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Choose Exact Display Direction (Priority: P1)

As a mosque display installer or administrator, I want to open the screen direction control and choose the exact display direction directly, so I can correct a mounted screen without repeatedly pressing a rotate button and guessing which state comes next.

Impacted locales: `ar`, `en`, and `bn`. Impacted screen classes: phone, tablet, TV, desktop, portrait, landscape, display-board, and regular home surfaces. Persistence is affected because the selected direction must remain the active display preference.

**Why this priority**: This is the main user problem. Mounted screens can be physically installed in different directions, and direct selection is faster and less error-prone than cycling through rotations.

**Independent Test**: Can be fully tested by opening the existing screen direction control, selecting each available direction, and confirming that the displayed interface changes to the selected direction without needing multiple trial taps.

**Acceptance Scenarios**:

1. **Given** the app is open and the screen direction control is available, **When** the user opens it, **Then** the user sees four direct choices for normal, right-rotated, upside-down, and left-rotated display directions.
2. **Given** the current display is upside down, **When** the user selects the upside-down correction direction, **Then** the interface updates to the selected direction immediately and the user does not need to cycle through intermediate directions.
3. **Given** a direction is already selected, **When** the user opens the direction control again, **Then** the current direction is visibly marked as selected.

---

### User Story 2 - Preserve Chosen Direction (Priority: P2)

As an administrator, I want the chosen display direction to stay active after closing the menu, navigating between app surfaces, or reopening the app, so the physical screen setup only needs to be corrected once.

Impacted locales: `ar`, `en`, and `bn`. Impacted screen classes: all surfaces that rely on the app-level display direction preference. Persistence must use the existing app settings storage behavior.

**Why this priority**: The feature is only useful for mounted displays if the selected direction remains stable across normal app usage and restarts.

**Independent Test**: Can be tested by selecting a direction, leaving the control, navigating to another affected surface, restarting the app, and confirming the same direction remains active and selected.

**Acceptance Scenarios**:

1. **Given** the user selects a display direction, **When** the user navigates away from home and returns, **Then** the selected direction remains active.
2. **Given** the user selects a display direction, **When** the app is closed and reopened, **Then** the selected direction is restored and marked in the direction control.

---

### User Story 3 - Understand Choices in Supported Languages (Priority: P3)

As a localized user, I want the direction choices to be understandable in my selected language, so I can confidently choose the correct display direction without needing technical knowledge of degrees.

Impacted locales: `ar`, `en`, and `bn`. The UI must remain readable over existing backgrounds and across compact and large-screen layouts.

**Why this priority**: The feature is visible to administrators in multilingual environments. Clear labels reduce setup mistakes.

**Independent Test**: Can be tested by switching to each supported language, opening the direction control, and verifying that all direction choices and selected-state text are readable and understandable.

**Acceptance Scenarios**:

1. **Given** the app language is Arabic, English, or Bengali, **When** the user opens the direction control, **Then** every direction option is displayed in the selected language or a clear fallback language.
2. **Given** the direction control appears on a compact or large display, **When** labels are longer in the selected language, **Then** the choices remain readable and do not overlap or truncate important meaning.

---

### Edge Cases

- If the user selects the direction that is already active, the app keeps the current direction and gives a stable selected state instead of applying an unnecessary visual jump.
- If the direction control is opened from a drawer, menu, or settings surface, selecting a direction must not leave the user trapped behind an overlay that hides the result.
- If no prior direction is saved, the app defaults to the normal device-following direction and marks that option as selected.
- If the physical display changes between portrait and landscape while a manual direction is selected, the app preserves the selected direction preference and keeps layout readability.
- If the selected language changes after a direction has been saved, the saved direction remains unchanged while the option labels update to the new language.
- If the app is in display-board mode, the selected direction applies consistently without switching the display mode back to the normal home screen.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST replace the single cycle-only rotation interaction with a direct display direction selection experience.
- **FR-002**: The system MUST provide exactly four selectable display directions: normal, rotated right, upside down, and rotated left.
- **FR-003**: The system MUST show which direction is currently active before the user makes a new selection.
- **FR-004**: Users MUST be able to change from any direction to any other direction with one explicit selection after opening the direction control.
- **FR-005**: The selected direction MUST be applied immediately after selection so the user can visually verify the result.
- **FR-006**: The selected direction MUST be saved and restored after app restart.
- **FR-007**: The selected direction MUST apply across regular home, display-board, and settings/navigation surfaces affected by app-level display direction.
- **FR-008**: The direction selection control MUST be available from the same user-facing area where screen rotation is currently managed, unless a later design decision intentionally moves all display setup controls together.
- **FR-009**: The direction labels MUST be localized for Arabic, English, and Bengali, with a readable fallback if a locale entry is missing.
- **FR-010**: The default state MUST preserve normal device-following behavior until the user explicitly chooses a manual display direction.
- **FR-011**: The interaction MUST avoid requiring users to cycle through intermediate directions to reach the desired one.
- **FR-012**: The system MUST keep the user's current app mode, selected location, prayer data, and display-board schedule unchanged when the display direction is changed.

### Constitution Alignment *(mandatory)*

- **CA-001 Localization**: Arabic, English, and Bengali copy are affected. New user-facing labels for the direction control and four direction choices must come from localization sources, with generated locale keys refreshed when required.
- **CA-002 Readability**: The direction control must remain readable across portrait, landscape, large-screen, and rotated display flows. Selected-state indicators must maintain contrast over existing themed and background-heavy surfaces.
- **CA-003 Architecture**: Display direction state must remain owned by the existing rotation state owner and persisted through the existing settings persistence abstraction. UI surfaces should only present choices and request a direction change, while state normalization and saved preference behavior stay outside presentation widgets.
- **CA-004 Verification**: Validation must include targeted state tests for selecting and restoring all four directions, widget coverage for the direction selection UI, localization checks for `ar`, `en`, and `bn`, `flutter analyze`, and the smallest relevant `flutter test` set. If localization inputs change, generated localization outputs must be refreshed.

### Key Entities *(include if feature involves data)*

- **Display Direction Preference**: The user's saved app-level direction choice. Key attributes are the active direction, selected-state label, and default normal state.
- **Direction Option**: A selectable choice shown to the user. Key attributes are user-facing label, visual selected state, and the direction it represents.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: After opening the direction control, users can choose the desired display direction in one selection, without cycling through other directions.
- **SC-002**: All four display directions can be selected and visually confirmed within 1 second of user selection on supported display classes.
- **SC-003**: In verification runs, the selected direction is restored correctly after app restart in 100% of tested direction cases.
- **SC-004**: In supported languages, every direction option remains readable without losing essential meaning on compact and large-screen layouts.
- **SC-005**: Setup mistakes caused by overshooting the desired rotation are eliminated because the interaction no longer depends on repeated sequential taps.

## Assumptions

- The feature changes the app-level display direction, not individual images, slides, prayer rows, or background assets independently.
- The existing normal direction remains the default for new users and for users with no saved direction preference.
- The first version should expose four clear choices rather than advanced custom angles.
- The current rotation entry point is an acceptable place to expose the direct picker unless planning identifies a better display setup grouping.
- The feature should preserve the existing mounted-display goal of avoiding platform-level letterboxing or black-window behavior.
