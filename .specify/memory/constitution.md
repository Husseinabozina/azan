<!--
Sync Impact Report
Version change: 1.0.0 -> 1.0.0 (validation-only pass, no substantive changes)
Review date: 2026-06-01
Context: spec-kit integration switched from codex to claude (v0.8.18). Constitution
         is agent-agnostic and required no amendments.
Modified principles:
- None
Added sections:
- None
Removed sections:
- None
Templates reviewed:
- ✅ .specify/templates/plan-template.md (Constitution Check aligns with all 5 principles)
- ✅ .specify/templates/spec-template.md (CA-001–CA-004 map correctly)
- ✅ .specify/templates/tasks-template.md (verification phases and audit runs align)
- ✅ README.md (stack, commands, and constitution reference are accurate)
- ✅ .specify/templates/commands/ (directory not present; skills live in .claude/skills/)
Follow-up TODOs:
- None
-->

# Azan Constitution

## Core Principles

### I. Correct Prayer-Time and Calendar Behavior

- Any change touching prayer times, iqama timing, Hijri or Gregorian calendar
  conversions, location lookup, timezone handling, or weather and date-driven
  display behavior MUST identify the authoritative calculation path and preserve
  deterministic results for the same inputs.
- Domain logic for time, date, schedule, and fallback resolution MUST live in
  helpers, services, models, or cubits that can be exercised outside the widget
  tree.
- Changes in this area MUST ship with automated tests covering the affected
  calculation or state transitions, including timezone or day-rollover cases
  when applicable.

Rationale: users rely on this app for time-sensitive devotional information, so
correctness must be deliberate and verifiable.

### II. Localized and Readable User Experience

- All user-visible copy MUST come from localization sources or generated locale
  keys. Hard-coded strings are allowed only for non-user-facing debug text.
- UI changes MUST preserve readability across supported locales (`ar`, `en`,
  `bn`), orientations, and large-screen rotation flows when the affected
  surface is shared.
- Changes to themed or background-heavy surfaces MUST maintain contrast and
  theme-pack alignment. Affected background work MUST run the theme audit and
  coverage checks.

Rationale: the product is multilingual and display-centric, so readability
regressions become immediate user-facing failures.

### III. Feature-Scoped Architecture and Persistence Boundaries

- Widgets in `lib/views/` MUST remain focused on composition and presentation.
  Business rules, I/O, and persistence MUST reside in `lib/controllers/`,
  `lib/core/`, or `lib/data/`.
- New persistent settings or cached content MUST use an existing repository or
  helper abstraction, such as `CacheHelper` or Hive helpers, unless a new
  abstraction is justified in the implementation plan.
- Generated artifacts in `lib/gen/` and `lib/generated/` MUST be regenerated
  from source inputs and MUST NOT be edited by hand.

Rationale: keeping stateful logic out of UI and respecting generation
boundaries limits regressions in a feature-rich Flutter app.

### IV. Verification Before Merge

- Every change set MUST pass `flutter analyze` and the smallest relevant
  automated test set before review or merge.
- Changes to domain logic or state management MUST add or update unit tests. UI
  behavior changes MUST add or update widget or golden tests when layout,
  theming, or interaction risk exists.
- Failing golden baselines, audit results, or pre-existing breakages in touched
  areas MUST be resolved or explicitly documented in the plan and review notes
  before merge.

Rationale: the repository already relies on automated checks to keep fast-moving
UI and timing logic safe.

### V. Controlled Assets, Dependencies, and Build Outputs

- New assets MUST be declared in `pubspec.yaml`, named consistently, and
  evaluated for app-size, readability, and platform impact before landing.
- New dependencies or plugins MUST solve a concrete need, fit the app's
  mobile-first and offline-tolerant constraints, and avoid duplicating behavior
  already present in the codebase.
- When localization, asset generation, or code generation inputs change, the
  corresponding generated outputs and developer documentation MUST be refreshed
  in the same change.

Rationale: this project carries a large asset surface and multiple generated
files, so drift becomes user-visible quickly.

## Technical Standards

- The canonical application stack is Dart 3 on Flutter stable with
  `flutter_bloc`, `easy_localization`, Hive-based local persistence, and
  generated asset and localization outputs.
- Feature plans MUST map changes onto the existing repository structure:
  `lib/views/` for screens and presentation widgets, `lib/controllers/` for
  cubits and state, `lib/core/` for shared helpers, models, services, and UI
  primitives, `lib/data/` for data sources, `assets/` for bundled content,
  `tool/` for repository automation, and `test/` for automated verification.
- UI work MUST account for phone and large-screen layouts, rotation behavior,
  and theme or background readability when those surfaces are affected.
- The approved regeneration and quality commands are `flutter pub get`,
  `flutter analyze`, `flutter test`,
  `dart run build_runner build --delete-conflicting-outputs`, and
  `dart run tool/background_theme_audit.dart --fail-on-issues` when
  theme-related work is in scope.

## Delivery Workflow

- Specifications MUST call out impacted locales, orientation or screen classes,
  persistence layers, generated artifacts, and verification strategy before
  implementation starts.
- Implementation plans MUST fail Constitution Check unless they identify how
  correctness, localization and readability, architectural boundaries, and
  automated verification will be preserved.
- Tasks MUST include the exact verification work needed for the changed
  surface, including unit, widget, or golden tests, audit runs, screenshot
  capture, or documentation and codegen refresh as applicable.
- Reviews for UI-facing changes MUST include evidence of the commands run and
  screenshots or goldens for materially changed surfaces.

## Governance

- This constitution overrides conflicting local conventions for product
  delivery, repository structure, and review gates.
- Amendments require a documented rationale, synchronized updates to affected
  Spec Kit templates or guidance files, and approval from project maintainers.
- Compliance review is mandatory during specification, planning,
  implementation, and code review. A feature that cannot meet a principle MUST
  record the exception and justification in the implementation plan's
  Complexity Tracking section before work proceeds.
- Semantic versioning for this constitution is mandatory: MAJOR for
  incompatible principle or governance changes, MINOR for new principles or
  materially expanded guidance, and PATCH for clarifications that do not change
  obligations.

**Version**: 1.0.0 | **Ratified**: 2026-05-23 | **Last Amended**: 2026-05-23
