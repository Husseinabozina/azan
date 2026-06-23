---

description: "Task list template for feature implementation"
---

# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include verification tasks for every feature unless the change is
documentation-only. Logic and state changes normally require unit tests; UI,
layout, or theme changes normally require widget or golden coverage and any
applicable audit runs.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter app**: `lib/`, `test/`, `assets/`, and `tool/` at repository root
- **Platform folders**: `android/`, `ios/`, `linux/`, `macos/`, `web/`,
  `windows/`
- Paths shown below assume the current Flutter repository structure - adjust
  based on plan.md when a feature is scoped more narrowly

<!--
  ============================================================================
  IMPORTANT: The tasks below are SAMPLE TASKS for illustration purposes only.

  The /speckit-tasks command MUST replace these with actual tasks based on:
  - User stories from spec.md (with their priorities P1, P2, P3...)
  - Feature requirements from plan.md
  - Entities from data-model.md
  - Endpoints from contracts/

  Tasks MUST be organized by user story so each story can be:
  - Implemented independently
  - Tested independently
  - Delivered as an MVP increment

  DO NOT keep these sample tasks in the generated tasks.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [ ] T001 Create project structure per implementation plan
- [ ] T002 Update `pubspec.yaml`, assets, or package dependencies required by
  the feature
- [ ] T003 [P] Refresh generated assets, localization outputs, or fixtures
  required before implementation

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational tasks (adjust based on your project):

- [ ] T004 Create or update shared cubit, state, or controller foundations in
  `lib/controllers/`
- [ ] T005 [P] Extend shared helpers, services, or repositories in `lib/core/`
  or `lib/data/`
- [ ] T006 [P] Define persistence, caching, or serialization support needed
  across stories
- [ ] T007 Add localization, theme, or shared asset plumbing required by all
  stories
- [ ] T008 Define golden baselines, test fixtures, or audit inputs used by the
  feature
- [ ] T009 Setup any required configuration or platform permissions

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 1 ⚠️

> **NOTE**: Write these tests or audits first when feasible, and ensure at
> least one relevant check fails before implementation for behavioral changes.

- [ ] T010 [P] [US1] Add or update unit/state test in `test/[feature]_test.dart`
- [ ] T011 [P] [US1] Add or update widget or golden coverage in
  `test/[feature]_screen_test.dart`
- [ ] T012 [US1] Run any required audit command or screenshot capture for the
  changed surface

### Implementation for User Story 1

- [ ] T013 [P] [US1] Implement or update data/model logic in
  `lib/core/` or `lib/data/`
- [ ] T014 [P] [US1] Implement or update cubit/state behavior in
  `lib/controllers/`
- [ ] T015 [US1] Implement the user-facing screen or component in `lib/views/`
- [ ] T016 [US1] Wire persistence, localization, and error handling
- [ ] T017 [US1] Refresh generated outputs or assets touched by the story

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 2 ⚠️

- [ ] T018 [P] [US2] Add or update unit/state test in `test/[feature]_test.dart`
- [ ] T019 [P] [US2] Add or update widget or golden coverage in
  `test/[feature]_screen_test.dart`

### Implementation for User Story 2

- [ ] T020 [P] [US2] Implement or update supporting logic in
  `lib/core/`, `lib/data/`, or `lib/controllers/`
- [ ] T021 [US2] Implement the user-facing screen or component in `lib/views/`
- [ ] T022 [US2] Integrate persistence, assets, or localization changes
- [ ] T023 [US2] Integrate with User Story 1 components if needed

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Tests for User Story 3 ⚠️

- [ ] T024 [P] [US3] Add or update unit/state test in `test/[feature]_test.dart`
- [ ] T025 [P] [US3] Add or update widget or golden coverage in
  `test/[feature]_screen_test.dart`

### Implementation for User Story 3

- [ ] T026 [P] [US3] Implement or update supporting logic in
  `lib/core/`, `lib/data/`, or `lib/controllers/`
- [ ] T027 [US3] Implement the user-facing screen or component in `lib/views/`
- [ ] T028 [US3] Integrate persistence, assets, or localization changes

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] TXXX [P] Documentation updates in docs/
- [ ] TXXX Code cleanup and refactoring
- [ ] TXXX Performance optimization across all stories
- [ ] TXXX [P] Regenerate code or localization outputs and verify diffs
- [ ] TXXX [P] Run `flutter analyze`, `flutter test`, and any required audit
  commands
- [ ] TXXX Capture screenshots or refresh goldens for changed UI surfaces
- [ ] TXXX Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests and audits MUST be created or updated before implementation when they
  protect behavior changed by the story
- Shared logic before cubit wiring
- Cubit or service updates before UI integration
- Core implementation before persistence and presentation polish
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all verification work for User Story 1 together:
Task: "Add or update unit/state test in test/[feature]_test.dart"
Task: "Add or update widget or golden coverage in test/[feature]_screen_test.dart"

# Launch implementation tasks that touch different layers together:
Task: "Implement or update data/model logic in lib/core/ or lib/data/"
Task: "Implement or update cubit/state behavior in lib/controllers/"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify relevant tests or audits fail before implementing behavior changes
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
