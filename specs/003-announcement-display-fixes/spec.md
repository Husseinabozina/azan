# Feature Specification: Display Board Announcement Improvements & Schedule Fix

**Feature Branch**: `003-announcement-display-fixes`

**Created**: 2026-06-01

**Status**: Draft

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Announcement Content Starts from Top (Priority: P1)

When a display board is active and showing announcements, the announcement text
currently does not align to the top of the content area. The mosque administrator
expects the title and body to start from the top of the announcement surface,
so that the full content is visible without scrolling on a large-display screen.

Note: affects all locales (`ar`, `en`, `bn`), both portrait and landscape orientations.

**Why this priority**: This is a visible regression on every single display board
session and the simplest fix — users notice it immediately.

**Independent Test**: Enable display board mode, create one announcement, open the
display board screen. The announcement title MUST appear flush to the top of the
content container, not centered or bottom-aligned.

**Acceptance Scenarios**:

1. **Given** display board mode is active with at least one announcement,
   **When** the display board screen renders,
   **Then** announcement text starts from the top of the content area with no
   unexplained vertical offset.

2. **Given** a long announcement body that fills most of the content area,
   **When** the display board screen renders,
   **Then** the title is at the top and remaining space is below the body, not
   split above and below.

3. **Given** the device is in landscape orientation,
   **When** the display board screen renders,
   **Then** the top-alignment is preserved and the layout does not revert to
   centered alignment.

---

### User Story 2 - Prayer Section Height Increased on Display Board (Priority: P2)

On the display board screen, the prayer times section appears too short relative
to the overall screen. The mosque administrator needs the prayer times block to
occupy more vertical space so prayer names and times are legible from a distance
on large displays.

**Why this priority**: The display board is typically viewed from several meters
away; an undersized prayer section is hard to read and defeats the purpose of the
display board.

**Independent Test**: Enable display board mode, open the display board screen in
landscape. The prayer times section MUST be visibly taller than in the current
build, with prayer names and times rendered at a comfortable reading size from
a distance.

**Acceptance Scenarios**:

1. **Given** the display board is active in landscape orientation,
   **When** the prayer section renders,
   **Then** the prayer times block is taller than before and each prayer row is
   clearly readable.

2. **Given** the device switches between portrait and landscape,
   **When** the prayer section re-renders,
   **Then** the increased height is preserved in both orientations.

---

### User Story 3 - Image Announcements for Ministry Notices (Priority: P2)

The Ministry of Religious Affairs sends official announcements as images
(posters, notices). The mosque administrator must be able to attach an image to
an announcement so that it displays full-screen or full-content-area on the
display board, replacing or supplementing the text content.

Note: affects all locales. Image announcements MUST respect the same scheduling,
active/inactive, and pinning behavior as text announcements.

**Why this priority**: Without this, ministry image announcements cannot be
displayed at all, forcing the mosque to use separate display hardware.

**Independent Test**: Create an announcement with only an image (no title or
body text). Enable display board mode. The image MUST fill the announcement
content area with correct aspect-ratio fitting, no cropping of critical content,
and no distortion.

**Acceptance Scenarios**:

1. **Given** the announcement editor is open,
   **When** the administrator taps "Add Image",
   **Then** the device image picker opens and a selected image is attached and
   previewed inside the editor.

2. **Given** an announcement has an image and no text,
   **When** it appears on the display board,
   **Then** the image fills the available content area using a cover or contain
   fit (appropriate for the aspect ratio) with no blank space or distortion.

3. **Given** an announcement has both an image and text (title and/or body),
   **When** it appears on the display board,
   **Then** the image fills the announcement zone and the text is overlaid on
   top of the image with a semi-transparent dark scrim behind it to ensure
   legibility against any image background.

4. **Given** an image announcement has a schedule set,
   **When** the scheduled time arrives,
   **Then** the image announcement appears on the display board automatically,
   exactly as text announcements do.

5. **Given** multiple announcements exist (some text-only, some image),
   **When** the display board rotates through them,
   **Then** image and text announcements rotate in the configured order without
   visual glitches.

6. **Given** an image announcement exists,
   **When** the administrator edits it,
   **Then** the current image is shown and can be replaced or removed.

---

### User Story 4 - Scheduled Announcements Appear at the Correct Time (Priority: P1)

When an administrator saves an announcement with a scheduled start and end
time and marks it active, the display board MUST switch to that announcement
automatically when the scheduled window begins — even if the app was already
open on the home screen before the schedule window started.

**Why this priority**: This is a blocking bug: the feature is advertised but
does not work reliably, breaking trust with mosque administrators who depend
on automated scheduling for Friday prayers, Ramadan announcements, etc.

**Independent Test**: Set a schedule window starting 2 minutes from now. Wait.
Without touching the app, the display board screen MUST replace the home screen
at the scheduled start time (within ±30 seconds).

**Acceptance Scenarios**:

1. **Given** an active announcement has a schedule whose start time is in the
   past and end time is in the future,
   **When** the home screen timer next fires,
   **Then** the display board screen appears automatically without any user
   interaction.

2. **Given** the home screen has been open for several minutes before a
   schedule window begins,
   **When** the schedule window start time passes,
   **Then** the display board appears within 30 seconds without requiring the
   user to leave and re-enter the home screen.

3. **Given** a schedule window ends while the display board is visible,
   **When** the end time passes,
   **Then** the home screen is restored automatically within 30 seconds.

4. **Given** the app is launched after a schedule window has already started,
   **When** the home screen initializes,
   **Then** the display board appears immediately without waiting for a timer
   tick.

---

### User Story 5 - Stay on Announcements Page After Save (Priority: P1)

When an administrator saves an announcement with a scheduled time, the app MUST
remain on the display board settings screen (announcements list) after the save
dialog closes. It MUST NOT navigate back to the home screen automatically.

**Why this priority**: This bug disrupts the configuration workflow — after
saving, the administrator has no way to verify the saved announcement without
reopening the settings from the home screen.

**Independent Test**: Open display board settings. Create or edit an announcement
with a schedule. Tap Save. The dialog MUST close and return to the announcements
list. The home screen MUST NOT appear.

**Acceptance Scenarios**:

1. **Given** the announcement editor dialog is open with a valid schedule,
   **When** the administrator taps Save,
   **Then** the dialog closes and the announcements list is visible and updated,
   with the home screen never having appeared.

2. **Given** the saved announcement has a schedule that happens to be active
   at the exact moment of saving,
   **When** the dialog closes,
   **Then** the announcements list is still shown (no automatic navigation away
   from settings).

---

### Edge Cases

- What happens when an image file is very large (e.g., > 10 MB)?
  The system MUST compress or downsample the image before storing it, so that
  storage and rendering remain performant.
- What if the image picker is denied permission?
  The app MUST surface a clear message and allow the administrator to retry or
  continue without an image.
- What if an image file is deleted from device storage after being attached?
  The announcement MUST degrade gracefully, showing a broken-image placeholder
  rather than crashing.
- What happens if the schedule start and end are on the same minute?
  The system MUST reject the schedule as invalid (end must be strictly after
  start), consistent with the existing `isValidWindow` check.
- What if the device time zone changes while a schedule is active?
  Schedules MUST be evaluated using device local time at the moment of each
  check; no stored UTC offset is required.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The display board announcement content area MUST render announcement
  text starting from the top of the available space, not centered or
  bottom-aligned.
- **FR-002**: The prayer times section on the display board screen MUST be
  displayed with increased height compared to the current build, sufficient for
  legibility from a large-display distance.
- **FR-003**: The announcement editor MUST provide an "Add Image" control that
  opens the device image library.
- **FR-004**: A `DisplayAnnouncement` MUST store an optional `imagePath` field
  pointing to a file copied into app-private storage at attachment time. Storing
  raw bytes in the persistence layer is explicitly out of scope.
- **FR-005**: When a display board announcement has an image, the display board
  screen MUST render that image filling the announcement content zone (the rotating
  announcement area) using an appropriate fit mode (cover or contain). The prayer
  times section MUST remain visible at all times, even when an image announcement
  is active.
- **FR-006**: Image-type announcements MUST participate in the rotation cycle,
  scheduling, active/inactive state, and pinning behavior identically to
  text announcements.
- **FR-007**: The home screen schedule checker MUST evaluate scheduled
  announcements at a polling interval short enough that the display board
  appears within 30 seconds of the schedule window opening.
- **FR-008**: The home screen MUST check for active scheduled announcements
  at initialization (on first build), not only on periodic timer ticks.
- **FR-009**: After the Save button in the announcement editor dialog is tapped
  and the save completes successfully, the app MUST remain on the display board
  settings screen.
- **FR-010**: Image files attached to announcements MUST be stored in
  app-accessible local storage, compressed if necessary to stay within a
  reasonable size limit (target ≤ 2 MB per image after compression).
- **FR-011**: The announcement list tile MUST show a small image thumbnail badge
  when the announcement has an attached image, so the administrator can
  distinguish image announcements at a glance.

### Constitution Alignment *(mandatory)*

- **CA-001 Localization**: The "Add Image" label, permission-denied message, and
  broken-image placeholder text MUST be localized in `ar`, `en`, and `bn`.
  No hard-coded user-visible strings are permitted.
- **CA-002 Readability**: Image fitting on the display board MUST preserve legibility
  across portrait and landscape orientations. The prayer section height increase
  MUST be validated in both orientations and on large-screen (tablet) targets.
  Theme contrast must be maintained for any new overlaid text on images.
- **CA-003 Architecture**: Image storage and path resolution MUST live in
  `DisplayBoardHiveHelper` or a new helper in `lib/core/`. The `DisplayAnnouncement`
  model MUST be updated to carry the image reference. All scheduling logic changes
  MUST remain in `DisplayBoardScheduleResolver` (`lib/core/helpers/`). Navigation
  behavior after save MUST be corrected in the announcement editor dialog within
  `display_board_settings_screen.dart`. Widget layout changes (top-alignment,
  prayer height) MUST stay in their respective view files
  (`lib/views/display_board/` and `lib/views/home/`).
- **CA-004 Verification**: Required verification steps before merge:
  1. `flutter analyze` — zero errors and warnings introduced by this feature.
  2. `flutter test` — all existing tests pass; new unit tests for
     `DisplayBoardScheduleResolver` schedule-timing behavior added.
  3. Widget/golden tests for display board announcement top-alignment (before/after).
  4. Manual smoke test: schedule window, wait, confirm auto-switch within 30 s.
  5. Manual smoke test: save announcement → confirm settings screen remains visible.
  6. Manual smoke test: attach image, enable display board → confirm image fills area.
  7. `dart run tool/background_theme_audit.dart --fail-on-issues` if any theme
     or background asset changes are introduced.

### Key Entities

- **DisplayAnnouncement**: Extended with an optional `imagePath` (String?) field
  pointing to a file in app-private storage. Serialization MUST be
  backward-compatible so existing announcements without images load correctly
  with `imagePath` defaulting to `null`.
- **Image file**: A copy of the original image stored in app-private storage,
  compressed to ≤ 2 MB at attachment time. The file MUST be deleted when the
  announcement is deleted.
- **DisplayBoardSchedule**: No changes required to the schedule model itself;
  the fix is in how often and how early the resolver is called.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a display board screen with at least one active announcement,
  the announcement title appears within the top 10% of the content area height,
  measured visually before and after (golden/screenshot comparison).
- **SC-002**: The prayer section on the display board is visibly taller — a
  measurable increase in the section's allocated height compared to the previous
  build, confirmed by golden or screenshot diff.
- **SC-003**: An administrator can attach, save, and display an image announcement
  in under 3 minutes from opening the editor to seeing the image on the display
  board.
- **SC-004**: A scheduled announcement appears on the display board within
  30 seconds of its configured start time, under continuous app usage without
  any user interaction.
- **SC-005**: After saving any announcement (with or without a schedule), the
  display board settings screen remains visible 100% of the time — zero
  occurrences of unintended home screen navigation after save.
- **SC-006**: Attached images are stored at ≤ 2 MB per announcement and render
  without visible lag (appear within 1 second) on the display board.

## Clarifications

### Session 2026-06-01

- Q: When an image announcement is showing on the display board, does the image take over the full screen or appear only in the announcement content zone? → A: Image fills the announcement content zone only; the prayer times section remains visible at all times.
- Q: When an announcement has both an image and text, how are they laid out? → A: Image fills the announcement zone; title/body text overlays on top of the image with a semi-transparent dark scrim behind the text for legibility.
- Q: How should attached images be stored — file path, bytes in Hive, or device URI? → A: Copy the image into app-private storage on attachment and store the file path in the announcement record.

## Assumptions

- Image source is the device photo library only (no camera, no URL); this covers
  the primary ministry announcement use case where images are forwarded via
  messaging apps and saved to the device.
- Images are copied into app-private storage at attachment time; the original
  device gallery file is not modified or tracked.
- Image compression and resizing are handled at the time of attachment (before
  storage), not at render time.
- The display board polling interval fix applies to both landscape home screen
  variants (`home_screen_landscape.dart` and `home_screen_landscape_2.dart`)
  and the standard portrait home screen.
- Existing announcements without images MUST load without errors after the
  `DisplayAnnouncement` model is extended (backward-compatible deserialization).
- The increased prayer section height is a configuration-level change in the
  display board runtime widget, not a user-adjustable setting in this feature.
- Supported locales remain `ar`, `en`, and `bn`; no new locale is added.
