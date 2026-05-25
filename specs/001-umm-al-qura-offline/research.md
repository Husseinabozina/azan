# Research: Offline Umm Al-Qura Prayer Times

## Decision 1: Import the external bundle into repo-local Flutter assets

**Decision**: Treat
`/Users/husseinabozina/Desktop/UmmAlQura_PDFs/server_bundle/v1` as a source
bundle only. Keep using an import or validation tool that copies the runtime
payload into `assets/data/umm_al_qura/v1/` and ships only repo-local assets
with the app.

**Rationale**: The production app cannot depend on a desktop filesystem path.
The constitution also requires controlled assets and repeatable build inputs.
Keeping the runtime bundle inside the repo makes offline behavior portable,
testable, and release-safe.

**Alternatives considered**:

- Read the desktop bundle path directly at runtime: rejected because mobile and
  production builds cannot access that path.
- Keep the bundle outside the repo and rely on a manual copy step only:
  rejected because it invites drift and weakens release validation.

## Decision 2: Use the manifest as the authoritative city catalog, merged with
app-owned display metadata

**Decision**: Keep `manifest.json` as the source of truth for supported city
IDs, runtime asset paths, and available years. Merge that catalog with
app-owned display metadata, aliases, and coordinates so selection UI, saved
city state, and weather compatibility remain stable.

**Rationale**: The bundle defines the supported cities, but the app still needs
Arabic display names, legacy alias matching, and graceful reuse of existing
city and weather behavior.

**Alternatives considered**:

- Keep the legacy `kSaudiCities` list as the authoritative picker: rejected
  because it does not fully describe the shipped official bundle.
- Trust bundle English names alone for UI and saved state: rejected because the
  app requires localization and backward-compatible name matching.

## Decision 3: Keep lazy city-file loading with in-memory and Hive caching

**Decision**: Continue using a lazy bundle service that loads a selected city's
compressed asset on demand, expands it in memory, resolves only the requested
days or ranges, and persists runtime `PrayerCalendarDay` objects through Hive.

**Rationale**: The bundle already contains exact official day data. Loading a
city lazily keeps startup cost lower than preloading all cities into Hive, and
it keeps the authoritative source clearly separated from the runtime cache.

**Alternatives considered**:

- Preload all city and day records into Hive on first launch: rejected because
  it increases startup time and local storage churn.
- Fall back to generated `adhan` days as the primary source: rejected because
  the approved bundle must remain authoritative for supported cities.

## Decision 4: Use stable bundle IDs for prayer-calendar persistence

**Decision**: Continue deriving official prayer-calendar storage keys from a
stable `bundleId` stored on `CityOption`, instead of relying on coordinates or
legacy English names.

**Rationale**: Bundle IDs avoid alias collisions and keep official schedule
cache keys stable even when display names differ from older app metadata.

**Alternatives considered**:

- Keep coordinate or name-derived keys only: rejected because that weakens
  consistency for newly added or aliased bundle cities.
- Introduce a second saved-city object outside `CityOption`: rejected because
  extending the existing persisted model is the smaller and safer footprint.

## Decision 5: Model the support window as Hijri-first with a Gregorian anchor

**Decision**: The user-facing window starts at the first day of the current
Hijri year, keeps dates earlier than today inside that Hijri year visible but
read-only, computes a Gregorian forward anchor at the end of the fifth upcoming
Gregorian year, then extends support through the end of the Hijri year that
contains that anchor.

**Rationale**: This matches the clarified product behavior exactly. It keeps
calendar navigation honestly Hijri-first while avoiding a confusing partial
final Hijri year.

**Alternatives considered**:

- Keep a purely Gregorian window: rejected by clarification.
- Stop exactly at the Gregorian anchor even if it lands mid-Hijri-year:
  rejected because the user explicitly wants support to continue through the
  end of the containing Hijri year.
- Keep a rolling multi-year window from today's date: rejected by earlier
  clarification.

## Decision 6: Replace the misleading Gregorian-only window concept with a
neutral supported-window model

**Decision**: The design treats the existing `GregorianCoverageWindow` logic as
an implementation detail that must be refactored into a neutral supported
window model representing both Hijri navigation boundaries and the Gregorian
forward anchor.

**Rationale**: The current name and behavior communicate the wrong mental
model. The clarified feature is not Gregorian-first, so the shared helper and
calendar UI need a neutral model that can drive Hijri year navigation, day
availability, and supported-range messaging consistently.

**Alternatives considered**:

- Keep the existing Gregorian-only helper and only relabel UI text: rejected
  because it bakes the wrong semantics into shared logic and tests.
- Push mixed-window calculations directly into the widget: rejected because the
  constitution requires date and schedule logic to stay outside the widget
  tree.

## Decision 7: Refresh official cached days lazily on bundle updates while
preserving overrides

**Decision**: Introduce a manifest-derived official source token, compare it to
cached official day records, and refresh stale official generated minutes from
the newer bundle before presenting supported dates. Preserve the selected city
and local adhan or iqama overrides during that refresh.

**Rationale**: The user explicitly wants newer shipped bundles to replace stale
official base times without forcing city reselection or erasing local
adjustments. A token-based lazy refresh keeps behavior correct without a full
eager migration of every stored day.

**Alternatives considered**:

- Keep stale official cached days forever after an app update: rejected because
  it violates the clarification.
- Wipe all prayer-day cache and user configuration on update: rejected because
  it creates unnecessary setup loss and discards valid overrides.
- Force an eager full-Hive rebuild on first launch after update: rejected
  because it increases startup cost and complexity when lazy refresh is enough.

## Decision 8: Validate the shipped bundle against the mixed-window promise

**Decision**: Keep import-time completeness validation, but align it with the
clarified mixed window so the import step fails if any shipped city cannot
cover the full current Hijri year through the end of the final supported Hijri
year implied by the Gregorian anchor.

**Rationale**: The feature promises all shipped bundle cities are supported
across the published window. Validation must enforce the exact promise rather
than a superseded Gregorian-only interpretation.

**Alternatives considered**:

- Trust the input bundle blindly: rejected because it risks shipping a promise
  the assets cannot satisfy.
- Downgrade support at runtime without validation: rejected because the product
  promise is explicit and all-city.

## Decision 9: Use responsive month navigation with a persistent large-screen
side panel

**Decision**: Keep compact month navigation lightweight on phone-sized layouts,
but switch to a large persistent Hijri month side panel on wide mosque-oriented
layouts so the active month and available months remain visible without extra
menus or precision tapping.

**Rationale**: The clarified UX requirement is not just "bigger controls"; it
is a stronger visual hierarchy for large screens. A side panel keeps browsing
context visible at all times, gives the active month a stable home, and works
better for operators who stand away from the display.

**Alternatives considered**:

- Simply enlarge the existing lower strip: rejected because it still leaves the
  navigation visually secondary beneath the summary content.
- Use only previous/next buttons around a single month label: rejected because
  it hides the available month set and weakens discoverability.
- Put month selection in a modal or drawer: rejected because it adds extra
  steps and is worse for quick repeated navigation on a display screen.

## Decision 10: Reuse current Flutter layout primitives instead of adding a new
responsive-layout dependency

**Decision**: Implement the large-screen side-panel pattern using existing
Flutter layout widgets plus the app's current scaling utilities (`ScreenUtil`
and `MQScale`) instead of adding a separate responsive-layout package.

**Rationale**: The project already has the primitives needed to detect layout
width, size readable tap targets, and preserve theme alignment. Avoiding a new
dependency keeps the implementation simpler, lowers regression risk, and stays
consistent with the constitution's dependency discipline.

**Alternatives considered**:

- Add a responsive framework package: rejected because it solves a problem the
  existing stack can already address and would increase maintenance surface.
- Hard-code large-screen sizes without shared scaling utilities: rejected
  because it is less adaptable across the mixed phone and mosque display
  surfaces the app already supports.
