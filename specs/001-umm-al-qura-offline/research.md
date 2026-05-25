# Research: Offline Umm Al-Qura Prayer Times

## Decision 1: Import the external bundle into repo-local Flutter assets

**Decision**: Treat
`/Users/husseinabozina/Desktop/UmmAlQura_PDFs/server_bundle/v1` as a source
bundle only. Add an import/validation tool that copies the runtime payload into
`assets/data/umm_al_qura/v1/` and ships only repo-local assets with the app.

**Rationale**: The production app cannot depend on a desktop filesystem path.
The constitution also requires controlled assets and repeatable build inputs.
Keeping the runtime bundle inside the repo makes offline behavior testable and
portable across devices.

**Alternatives considered**:

- Read the desktop bundle path directly at runtime: rejected because mobile and
  production builds cannot access that path.
- Keep the bundle outside the repo and document a manual copy step only:
  rejected because it invites drift and makes CI or release validation brittle.

## Decision 2: Use the manifest as the authoritative schedule catalog, but
merge it with curated app display metadata

**Decision**: Make `manifest.json` the source of truth for supported bundle
city IDs, asset paths, and available years. Merge that catalog with app-owned
display metadata and aliases so the selection UI, cached city choice, and
weather/name compatibility remain stable.

**Rationale**: The current app ships 99 hard-coded `kSaudiCities`, while the
provided bundle advertises 118 cities and includes naming drift such as
`Ad Dawadimi` vs `Al Duwadimi`, `Diriyah` vs `Ad Diriyah`, and `Khobar` vs
`Al Khobar`. The manifest must drive schedule support, but the app still needs
Arabic display names, alias matching, and coordinates where available.

**Alternatives considered**:

- Keep `kSaudiCities` as the authoritative picker list: rejected because it
  omits bundle cities and would crash or misroute unsupported names.
- Trust bundle English names alone for UI: rejected because the app requires
  Arabic/English localization and existing selection cache compatibility.

## Decision 3: Replace generated calendar hydration with lazy official bundle
loading plus Hive caching

**Decision**: Introduce an offline schedule service that lazily loads a
selected city's compressed bundle file, parses only the needed date slices,
maps them to `PrayerCalendarDay.generated(...)`, and stores or reuses them via
`PrayerCalendarHiveHelper`.

**Rationale**: The current `AppCubit._ensureHijriYearCalendar()` loops over
date ranges and calls `azanDataSource.fetchPrayerTimes(...)` per day. That
approach is not official, not offline-safe, and does unnecessary work once the
bundle already contains exact day data. Lazy per-city loading keeps startup and
storage costs lower than pre-importing all days into Hive on first launch.

**Alternatives considered**:

- Keep `azanDataSource` as the primary source and only use the bundle as a
  fallback: rejected because the feature requires the bundle to be
  authoritative.
- Preload all 118-city / 10-year records into Hive at first launch: rejected
  because it would increase startup time and local storage churn unnecessarily.

## Decision 4: Use a stable bundle city key instead of coordinate-derived
calendar keys

**Decision**: Extend the selected-city model with a stable `bundleId` and make
prayer-calendar persistence prefer that bundle identifier when building day
storage keys.

**Rationale**: The current `PrayerCalendarHelper.cityKeyFor()` prefers rounded
coordinates or falls back to lowercase English names. The official bundle
already exposes stable city IDs, and those IDs avoid alias collisions, name
drift, and weather-coordinate coupling.

**Alternatives considered**:

- Keep coordinate/name-based keys only: rejected because newly added bundle
  cities may lack preloaded coordinates and may not match legacy English names.
- Introduce a separate selection object outside `CityOption`: rejected because
  the app already persists `CityOption` via `CacheHelper`, so extending it is a
  smaller change footprint.

## Decision 5: The user-facing browsing window is Gregorian and fixed, while
the underlying schedule data remains Hijri-indexed

**Decision**: The runtime window will expose the full current Gregorian year
plus the next 5 full Gregorian years. Dates earlier than today inside the
current Gregorian year remain visible but read-only. The screen may still show
Hijri labels per day and per month.

**Rationale**: This matches the clarified product behavior exactly and allows
the existing `HijriPrayerCalendarScreen` to keep Hijri presentation without
forcing the user-facing range logic to depend on Hijri-year selection.

**Alternatives considered**:

- Keep a rolling 5-year window from today: rejected by clarification.
- Keep a Hijri-year-based browsing model: rejected because the spec now defines
  a Gregorian window and past-day disabling rule.

## Decision 6: Preserve manual adhan and iqama overrides by reusing
`PrayerCalendarDay`

**Decision**: Continue storing official day minutes in
`PrayerCalendarDay.generatedAdhanMinutes` and keep all current manual adhan and
iqama override fields intact.

**Rationale**: The existing editor dialog and override persistence already work
against `PrayerCalendarDay`. Reusing that model avoids re-implementing
date-level overrides while still allowing the official bundle to become the new
base schedule source.

**Alternatives considered**:

- Create a separate override store for the official bundle: rejected because it
  duplicates existing behavior and would increase migration risk.
- Flatten official bundle data into a separate runtime model tree: rejected
  because the rest of the app already expects `PrayerCalendarDay`.

## Decision 7: Validate bundle completeness before shipping any all-city
coverage promise

**Decision**: Add import-time validation that checks the shipped asset pack
against the clarified product promise. The import step must fail loudly if the
repo-local bundle cannot satisfy the selected city/date coverage rules.

**Rationale**: The provided manifest currently reports 118 cities but also
shows incomplete `year_summary` entries for some Hijri years. The spec now says
all bundle cities are fully supported, so implementation cannot silently ship a
bundle that contradicts that promise.

**Alternatives considered**:

- Ignore manifest warnings and trust the input blindly: rejected because it
  risks incorrect schedule claims.
- Downgrade the spec at runtime without validating the bundle: rejected because
  the clarified requirement is an all-city promise, not a best-effort fallback.
