---
description: "Task list for Display Board Announcement Improvements & Schedule Fix"
---

# Tasks: Display Board Announcement Improvements & Schedule Fix

**Input**: Design documents from `specs/003-announcement-display-fixes/`

**Note**: `plan.md` was not generated before task generation. Tasks are derived
directly from `spec.md` and codebase reading of the key files:
- `lib/views/display_board/components/display_board_runtime_widgets.dart`
- `lib/views/home/display_board_landscape.dart`
- `lib/views/home/display_board_portrait.dart`
- `lib/views/home/components/display_board_runtime_base.dart`
- `lib/views/home/home_screen.dart`
- `lib/views/home/home_screen_landscape_2.dart`
- `lib/views/display_board/display_board_settings_screen.dart`
- `lib/core/helpers/display_board_hive_helper.dart`
- `lib/core/helpers/display_board_schedule_helper.dart`
- `lib/core/models/display_announcement.dart`

**Prerequisites**: spec.md ✅, clarifications (2026-06-01) ✅

**Tests**: Include verification tasks for every user story as the changes touch
display logic, scheduling state, and navigation. Logic changes require unit
tests; UI changes require manual screenshot verification.

**Organization**: Tasks are grouped by user story (priority order P1 → P2).

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to

## Path Conventions

- Flutter app root: `lib/`, `test/`, `assets/`
- Display board views: `lib/views/display_board/`
- Display board components: `lib/views/display_board/components/`
- Home screens: `lib/views/home/`
- Home components: `lib/views/home/components/`
- Core helpers: `lib/core/helpers/`
- Core models: `lib/core/models/`
- Translations: `assets/translations/`

---

## Phase 1: Setup

**Purpose**: Confirm environment and add the one missing package for image
compression.

- [X] T001 Run `flutter pub get` and confirm zero errors
- [X] T002 Add `flutter_image_compress` to `pubspec.yaml` dependencies (needed
  for US3 image storage ≤ 2 MB requirement); run `flutter pub get` again

---

## Phase 2: Foundational (Shared Infrastructure for US3)

**Purpose**: Extend the data model and storage layer. US1, US4, US5, US2 do not
depend on this phase and can start immediately after Phase 1.

**⚠️ CRITICAL**: US3 implementation tasks cannot begin until this phase is
complete. US1, US4, US5, and US2 are independent and can proceed in parallel
with this phase.

- [X] T003 [P] Extend `DisplayAnnouncement` model in
  `lib/core/models/display_announcement.dart`: add optional `String? imagePath`
  field; update `toMap()` to include `'imagePath': imagePath`; update
  `fromMap()` to read `map['imagePath'] as String?` with null default so
  existing saved announcements without the field load correctly; update
  `copyWith()` to accept and propagate `imagePath` with an explicit
  `clearImagePath` flag (analogous to the existing `clearSchedule` flag)

- [X] T004 [P] Create `lib/core/helpers/display_board_image_helper.dart` with
  two static methods:
  (1) `copyImageToPrivateStorage(XFile file) → Future<String>` — reads the
  picked file, compresses it to ≤ 2 MB using `flutter_image_compress`, writes
  it to `path_provider.getApplicationDocumentsDirectory()` under a
  `display_board_images/` subfolder with a timestamp filename, and returns the
  absolute path;
  (2) `deleteImageFile(String? path) → Future<void>` — deletes the file at
  `path` if it exists, silently no-ops if path is null or file is missing

- [X] T005 Update `DisplayBoardHiveHelper` in
  `lib/core/helpers/display_board_hive_helper.dart`:
  (a) Add optional `String? imagePath` parameter to `addAnnouncement` and
  thread it through to the `DisplayAnnouncement` constructor;
  (b) Ensure `updateAnnouncement` persists `imagePath` as-is (the editor
  passes the final path after any image swap);
  (c) In `deleteAnnouncement`, after removing the record, call
  `DisplayBoardImageHelper.deleteImageFile(item.imagePath)` using the
  `imagePath` of the deleted item (fetch item before removing)

**Checkpoint**: Model, storage helper, and Hive helper updated. US3 UI work can now begin.

---

## Phase 3: User Story 1 — Announcement Content Starts from Top (Priority: P1)

**Goal**: Announcement title and body render flush to the top of the content
zone, not vertically centered.

**Root cause (confirmed)**: `DisplayBoardAnnouncementStage.build()` in
`lib/views/display_board/components/display_board_runtime_widgets.dart` line 149
uses `mainAxisAlignment: MainAxisAlignment.center` on the text `Column`. The
column is inside a `SizedBox.expand` so it fills the full height and centers
its children.

**Independent Test**: Enable display board mode → open display board screen →
confirm announcement title appears in the top ~10% of the content zone with
no gap above it.

- [X] T006 [US1] In `lib/views/display_board/components/display_board_runtime_widgets.dart`,
  in `DisplayBoardAnnouncementStage.build()`: change `mainAxisAlignment:
  MainAxisAlignment.center` (line ~149, the `hasAnnouncement` branch `Column`)
  to `mainAxisAlignment: MainAxisAlignment.start`; wrap the content `Column`
  in a `SingleChildScrollView` so long announcements remain scrollable and do
  not overflow

- [X] T007 [US1] Verify the empty-board state `Column` (line ~193, the
  `!hasAnnouncement` branch) retains `MainAxisAlignment.center` so the
  "no announcements" placeholder icon stays centered when no content exists

**Checkpoint**: Title and body start from the top in both landscape and portrait
display board modes.

---

## Phase 4: User Story 4 — Scheduled Announcements Appear at the Correct Time (Priority: P1)

**Goal**: The home screen evaluates the schedule every ≤30 s and automatically
switches to the display board when a window opens — without requiring user
interaction.

**Root cause (confirmed)**:
- `HomeScreen` is a `BlocBuilder<AppCubit, AppState>` that calls
  `effectiveDisplayMode()` on every rebuild. It does NOT set up its own
  periodic timer to drive rebuilds when no cubit state change occurs.
- `HomeScreenLandscape2._syncDisplayBoardMode` runs every second (via tick
  timer) and detects the schedule correctly, but its response is to call
  `AppNavigator.pushAndRemoveUntil(context, const HomeScreen())`. This is a
  navigation event; it does NOT trigger the existing `BlocBuilder` inside the
  same `HomeScreen` route to rebuild — instead, it discards the entire
  navigation stack and replaces it.
- `home_screen_landscape.dart` (the other landscape variant) has NO call to
  any display-board mode check in its tick timer (confirmed absent).

**Fix approach**: Add a lightweight periodic timer directly to
`_HomeScreenState` that calls `setState(() {})` every 30 seconds. This forces
`BlocBuilder` to re-evaluate `effectiveDisplayMode(DateTime.now())`. Because
`effectiveDisplayMode` reads `DateTime.now()` at call time, it will detect
schedule windows without needing a cubit state change.

**Independent Test**: Create an announcement with a schedule starting 2 minutes
from now. Wait without touching the app. Display board MUST appear within 30 s
of the start time.

- [X] T008 [US4] In `lib/views/home/home_screen.dart`, convert
  `_HomeScreenState` from `State<HomeScreen>` to a `State<HomeScreen> with
  WidgetsBindingObserver`; in `initState` start a
  `Timer.periodic(const Duration(seconds: 30), (_) { if (mounted) setState(() {}); })`
  and store it as `Timer? _scheduleTimer`; cancel it in `dispose()`; also call
  `cubit.assignDisplayAnnouncements()` in `didChangeAppLifecycleState` when the
  app resumes (`AppLifecycleState.resumed`) so stale announcements are
  refreshed after the device wakes

- [X] T009 [P] [US4] In `lib/views/home/home_screen_landscape_2.dart`,
  simplify `_syncDisplayBoardMode`: remove the `AppNavigator.pushAndRemoveUntil`
  call entirely; replace it with `cubit.assignDisplayAnnouncements()` followed
  by `if (mounted) setState(() {})` so the `HomeScreen` BlocBuilder re-evaluates
  naturally without navigation side-effects; keep the `_isRoutingByDisplayMode`
  guard but reset it to `false` when `effectiveMode` is no longer `displayBoard`

- [X] T010 [P] [US4] In `lib/views/home/home_screen.dart` `_HomeScreenState.build`:
  pass `items: cubit.displayAnnouncementList ?? const []` with a fallback
  assignment — if the list is null on first build, call
  `cubit.assignDisplayAnnouncements()` as a side-effect in a
  `WidgetsBinding.addPostFrameCallback` so the next frame has the list populated

**Checkpoint**: A scheduled announcement that starts while the app is open
triggers the display board within 30 seconds. App-resume also re-checks.

---

## Phase 5: User Story 5 — Stay on Announcements Page After Save (Priority: P1)

**Goal**: After tapping Save in the announcement editor, the settings screen
remains visible — the home screen MUST NOT appear.

**Root cause (confirmed)**: When the user saves an announcement whose schedule
is immediately active, `cubit.assignDisplayAnnouncements()` (called by
`_reloadAnnouncements`) emits a new cubit state → `HomeScreen`'s BlocBuilder
rebuilds → shows `DisplayBoardLandscapeScreen` instead of
`HomeScreenLandscape2`. Meanwhile, `HomeScreenLandscape2._syncDisplayBoardMode`
(still running via tick timer while it is still mounted for a brief frame) calls
`AppNavigator.pushAndRemoveUntil(context, const HomeScreen())`, which removes
the settings screen from the navigation stack.

**Fix**: The T009 fix (removing `pushAndRemoveUntil` from `_syncDisplayBoardMode`)
is the primary fix. After T009, the BlocBuilder widget-swap happens inside
the `HomeScreen` route (no navigation occurs), and the settings screen pushed
on top of `HomeScreen` remains unaffected. This task adds a defensive guard
to prevent any residual navigation from firing while settings is open.

**Independent Test**: Open display board settings. Create a new announcement
with a schedule starting at the current minute. Tap Save. Dialog MUST close
and the announcements list MUST be visible — home screen MUST NOT appear.

- [X] T011 [US5] In `lib/views/display_board/display_board_settings_screen.dart`,
  in the `BlocConsumer.listener`, add a guard that prevents navigation away
  from the settings screen when display mode changes: only navigate if
  `ModalRoute.of(context)?.isCurrent == true` resolves to a condition
  where navigation is appropriate, or leave the listener as a no-op (since
  the BlocBuilder inside `HomeScreen` handles mode switching automatically
  after T009)

- [X] T012 [US5] Verify in `display_board_settings_screen.dart` that the Save
  button's `onPressed` in `_showAnnouncementEditor` only calls `navigator.pop()`
  and `_reloadAnnouncements()` — confirm no code path after save calls
  `_goHome()` or `AppNavigator.pushAndRemoveUntil`; add a comment explaining
  that navigation back to home from this screen is only triggered by the
  explicit close button, not by schedule activation

**Checkpoint**: Saving any announcement (including one with an immediately-active
schedule) keeps the user on the settings screen.

---

## Phase 6: User Story 2 — Prayer Section Height Increased (Priority: P2)

**Goal**: The prayer times block on the display board is visibly taller,
legible from a distance.

**Root cause**: Both `display_board_landscape.dart` and
`display_board_portrait.dart` use `flex: 8` (announcement) and `flex: 2`
(prayer rail). The prayer rail gets only 20% of the expanded area.

**Independent Test**: Enable display board mode, open in landscape. Prayer
names and times MUST be noticeably larger/taller than in the previous build.

- [X] T013 [US2] In `lib/views/home/display_board_landscape.dart`, change the
  prayer rail `Expanded(flex: 2, ...)` to `Expanded(flex: 3, ...)` and the
  announcement stage `Expanded(flex: 8, ...)` to `Expanded(flex: 7, ...)`
  so the prayer section grows from 20% to ~30% of the expanded area

- [X] T014 [US2] Apply the same flex ratio change in
  `lib/views/home/display_board_portrait.dart`: announcement `flex: 8 → 7`,
  prayer rail `flex: 2 → 3`

- [ ] T015 [US2] Visually verify in both landscape and portrait that prayer
  names and times are readable and that the announcement zone still has
  sufficient space; adjust flex values if the visual balance is off (target:
  prayer section clearly readable from 3+ meters)

**Checkpoint**: Prayer section visibly taller in both orientations.

---

## Phase 7: User Story 3 — Image Announcements for Ministry Notices (Priority: P2)

**Goal**: Administrators can attach an image to an announcement. On the display
board the image fills the announcement zone; if text is also present it overlays
the image with a dark scrim.

**Prerequisites**: Phase 2 (T003–T005) must be complete.

**Independent Test**: Add announcement with image only → enable display board
→ image fills content zone, prayer section visible. Add announcement with image
+ text → text overlays image with visible dark scrim.

### Implementation for User Story 3

- [X] T016 [US3] In `lib/views/display_board/display_board_settings_screen.dart`,
  in `_showAnnouncementEditor`: add `String? imagePath` state variable;
  add an "Add Image" `_BoardActionButton` (below the body field) that calls
  `ImagePicker().pickImage(source: ImageSource.gallery)` and, on selection,
  calls `DisplayBoardImageHelper.copyImageToPrivateStorage(file)` and stores
  the returned path in `imagePath`; add a "Remove Image" control that calls
  `DisplayBoardImageHelper.deleteImageFile(imagePath)` and clears the variable

- [X] T017 [US3] In the same editor dialog, add an image preview widget:
  when `imagePath != null`, show a `ClipRRect`-wrapped `Image.file` thumbnail
  (height ~120.h, fit: BoxFit.cover) with a corner "×" remove button;
  when null, show nothing

- [X] T018 [US3] In the Save button `onPressed` of `_showAnnouncementEditor`:
  when editing an existing announcement that previously had a different image,
  call `DisplayBoardImageHelper.deleteImageFile(initial!.imagePath)` before
  saving; pass `imagePath: imagePath` to `DisplayBoardHiveHelper.addAnnouncement`
  and include it in the `copyWith` call for `DisplayBoardHiveHelper.updateAnnouncement`

- [X] T019 [US3] In `lib/views/display_board/components/display_board_runtime_widgets.dart`,
  update `DisplayBoardAnnouncementStage.build()` to handle the image case:
  - Read `announcement?.imagePath` — if non-null and the file exists, show
    `Image.file` with `fit: BoxFit.cover` and `SizedBox.expand`
  - If text (title or body) is non-empty alongside the image, overlay text
    using a `Stack`: bottom layer is the image, top layer is a `Column`
    aligned to `MainAxisAlignment.start` inside a `Container` with a
    semi-transparent dark gradient scrim (`Colors.black.withValues(alpha: 0.54)`)
    at the bottom or full area; the text style (font, color) MUST remain
    readable against any background
  - If image exists but title and body are both empty, show image alone
    (no text overlay, no scrim)
  - Graceful fallback: if the file at `imagePath` does not exist
    (`File(path).existsSync()` returns false), fall back to the existing
    text-only render path

- [X] T020 [US3] In `lib/views/display_board/display_board_settings_screen.dart`,
  update `_AnnouncementTile`: if `item.imagePath != null`, display a small
  `ClipRRect`-wrapped `Image.file` thumbnail badge (size ~40.r × 40.r,
  fit: BoxFit.cover) at the trailing side of the tile header row, so
  administrators can identify image announcements at a glance

- [X] T021 [P] [US3] Add localization keys to
  `assets/translations/ar.json`, `assets/translations/en.json`, and
  `assets/translations/bn.json`:
  - `display_board_add_image`: "أضف صورة" / "Add Image" / "ছবি যোগ করুন"
  - `display_board_remove_image`: "حذف الصورة" / "Remove Image" / "ছবি সরান"
  - `display_board_image_permission_denied`: "لا يمكن الوصول إلى مكتبة الصور" /
    "Cannot access photo library" / "ফটো লাইব্রেরিতে অ্যাক্সেস করা যাচ্ছে না"
  - Add corresponding keys to `lib/generated/locale_keys.g.dart` (or regenerate)

- [X] T022 [US3] Replace hard-coded label strings in the new image UI (T016,
  T017, T020) with the locale keys added in T021; show the permission-denied
  message in a `SnackBar` when `pickImage` returns null due to denied access

- [ ] T023 [US3] Run `dart run build_runner build --delete-conflicting-outputs`
  to regenerate `lib/generated/locale_keys.g.dart` if the project uses code
  generation for locale keys; verify the new keys appear in the generated file

**Checkpoint**: Image announcements appear correctly on the display board
with text overlay scrim; image thumbnails visible in the settings list.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Analysis, testing, and cleanup across all stories.

- [ ] T024 [P] Run `flutter analyze` from the repo root and fix any new
  warnings or errors introduced by this feature's changes

- [ ] T025 [P] Run `flutter test` and confirm all existing tests pass with no
  regressions

- [ ] T026 Add unit tests for `DisplayBoardScheduleResolver` in
  `test/display_board_schedule_test.dart` covering:
  (a) schedule window not yet started → `isAnnouncementScheduledNow` returns false;
  (b) schedule window active → returns true;
  (c) schedule window ended → returns false;
  (d) `dismissedUntilEndAt` set → `hasManualDismissForCurrentWindow` returns true;
  (e) cleared `dismissedUntilEndAt` → dismiss check returns false

- [ ] T027 Manual smoke test — US1: enable display board, create one
  announcement, confirm title appears in top ~10% of announcement zone (take
  screenshot before/after for comparison)

- [ ] T028 Manual smoke test — US4: set schedule 2 minutes from now, wait
  without touching app, confirm display board appears within 30 s of start
  time; wait for end time, confirm home screen restores

- [ ] T029 Manual smoke test — US5: open settings, create announcement with
  schedule starting at current minute, tap Save, confirm settings page remains;
  check display board switches in background (behind settings) without popping
  settings

- [ ] T030 Manual smoke test — US2: enable display board in landscape and
  portrait; confirm prayer section is visibly taller than before

- [ ] T031 Manual smoke test — US3: attach image to new announcement, enable
  display board, confirm image fills announcement zone with prayer section
  visible; add title + body to same announcement, confirm text overlays with
  dark scrim; delete the announcement and confirm the image file is deleted
  from app storage

- [ ] T032 [P] Run `dart run tool/background_theme_audit.dart --fail-on-issues`
  to confirm theme contrast is maintained for any overlay text changes
  introduced in T019

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1; BLOCKS US3 only
- **US1 (Phase 3)**: Depends only on Phase 1 — can run in parallel with Phase 2
- **US4 (Phase 4)**: Depends only on Phase 1 — can run in parallel with Phases 2 and 3
- **US5 (Phase 5)**: Depends on T009 (Phase 4, US4) — T009 is the primary fix
- **US2 (Phase 6)**: Depends only on Phase 1 — independent of all other phases
- **US3 (Phase 7)**: Depends on Phase 2 (T003–T005) completion
- **Polish (Phase 8)**: Depends on all implementation phases complete

### User Story Dependencies

- **US1 (P1)**: Independent — start after Phase 1
- **US4 (P1)**: Independent — start after Phase 1
- **US5 (P1)**: Depends on T009 from US4 (shared fix)
- **US2 (P2)**: Independent — start after Phase 1
- **US3 (P2)**: Depends on Phase 2 (model + storage foundation)

### Within Each User Story

- Foundational data model changes before UI changes (US3)
- Core logic fixes before defensive guards (US4 → US5)
- Implementation before localization wiring (US3)

### Parallel Opportunities

- T003 and T004 can run in parallel (different files)
- T003–T005 (Phase 2) can run in parallel with T006–T007 (US1), T008–T010 (US4), T013–T015 (US2)
- T021 (localization keys) can run in parallel with T016–T020
- T024, T025, T032 can run in parallel in Phase 8

---

## Parallel Example: US3

```bash
# Launch model + helper work together:
Task T003: Extend DisplayAnnouncement model in lib/core/models/display_announcement.dart
Task T004: Create DisplayBoardImageHelper in lib/core/helpers/display_board_image_helper.dart

# After T003 + T004 done, launch UI and localization together:
Task T016: Add image picker to announcement editor
Task T021: Add localization keys to translation files
```

---

## Implementation Strategy

### MVP First (P1 stories only — US1, US4, US5)

1. Complete Phase 1: Setup
2. Complete Phase 3: US1 (top alignment) — simplest fix, highest visibility
3. Complete Phase 4: US4 (schedule fix) — core reliability fix
4. Complete Phase 5: US5 (navigation fix) — consequence of US4 fix
5. **STOP and VALIDATE** with smoke tests T027, T028, T029
6. Ship P1 fixes

### Incremental Delivery

1. Setup (Phase 1) → Phase 3 (US1) → Phase 4 (US4) → Phase 5 (US5) → validate P1
2. Phase 2 (Foundational) → Phase 7 (US3) → validate US3
3. Phase 6 (US2) → validate US2
4. Phase 8 (Polish) → ship

---

## Notes

- [P] tasks = different files, no shared state dependencies
- US5 fix is a direct consequence of the US4 fix (T009); implement T009 first
- `home_screen_landscape.dart` is NOT used by `HomeScreen` (confirmed: HomeScreen
  uses `HomeScreenLandscape2`); its missing schedule check does not need fixing
- `image_picker` and `path_provider` are already in `pubspec.yaml`; only
  `flutter_image_compress` is new (T002)
- The `DisplayBoardRuntimeBase.cubit` getter (`AppCubit()`) uses a factory/singleton
  pattern; verify it returns the same instance as `AppCubit.get(context)` before
  touching the cubit references in US4 tasks
- Commit after each user story phase or logical group
- Stop at any checkpoint to validate the story independently
