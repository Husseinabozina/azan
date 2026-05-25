# Data Model: Offline Umm Al-Qura Prayer Times

## 1. `CityOption` (existing, extended)

**Purpose**: Persist and pass the currently selected city through the existing
app flows.

**Fields**:

| Field | Type | Notes |
|------|------|-------|
| `countryCode` | `String?` | Existing country marker, remains `SA` for bundle cities |
| `nameAr` | `String` | Arabic display name used in localized UI |
| `nameEn` | `String` | English display name |
| `lat` | `double?` | Optional coordinate for weather or legacy flows |
| `lon` | `double?` | Optional coordinate for weather or legacy flows |
| `bundleId` | `String?` | New stable Umm Al-Qura city identifier, e.g. `abha` |
| `regionEn` | `String?` | Optional region label from the bundle manifest |
| `nameAliases` | `List<String>` | Optional normalized aliases for legacy name matching |

**Validation**:

- `bundleId` is required for any city selected from the official offline
  catalog.
- `nameAr` and `nameEn` must always be non-empty.
- `nameAliases` must be normalized and deduplicated.

**Relationships**:

- Maps 1:1 to an `OfficialCityCatalogEntry`.
- Is persisted by `CacheHelper` and consumed by `AppCubit`, selection UI, and
  shared footer/city labels.

## 2. `UmmAlQuraBundleManifest`

**Purpose**: Represent the shipped root `manifest.json` and drive supported
catalog loading.

**Fields**:

| Field | Type | Notes |
|------|------|-------|
| `schemaVersion` | `int` | Bundle schema gate |
| `generatedAt` | `DateTime` | Bundle generation timestamp |
| `countryCode` | `String` | Expected to be `SA` |
| `timezone` | `String` | Expected to be `Asia/Riyadh` |
| `cityCount` | `int` | Total cities advertised by the bundle |
| `availableHijriYears` | `List<int>` | Underlying bundle coverage years |
| `yearSummary` | `List<UmmAlQuraYearSummary>` | Completeness report for validation |
| `cities` | `List<UmmAlQuraManifestCity>` | Per-city runtime asset metadata |

**Validation**:

- `cityCount` must equal `cities.length`.
- Every `cities[].file` must resolve to a bundled asset path.
- Completeness checks must run before the assets are accepted for shipping.

## 3. `OfficialCityCatalogEntry`

**Purpose**: Provide the app-facing merged city catalog entry used by the city
picker and schedule services.

**Fields**:

| Field | Type | Notes |
|------|------|-------|
| `bundleId` | `String` | Stable schedule key |
| `nameEn` | `String` | Official English city name |
| `nameAr` | `String` | Curated Arabic display name |
| `regionEn` | `String?` | Region label from the bundle |
| `countryCode` | `String` | `SA` |
| `timezone` | `String` | Usually `Asia/Riyadh` |
| `lat` | `double?` | Optional mapped coordinate |
| `lon` | `double?` | Optional mapped coordinate |
| `scheduleAssetPath` | `String` | Bundled `.json.gz` runtime file |
| `debugJsonPath` | `String?` | Optional raw review path, not required at runtime |
| `availableHijriYears` | `List<int>` | Years carried by the underlying bundle |
| `aliases` | `List<String>` | Legacy or normalized names for matching/search |

**Validation**:

- `bundleId`, `nameEn`, `nameAr`, and `scheduleAssetPath` are mandatory.
- `aliases` must include at least one normalized English lookup token.
- If coordinates are missing, weather features must degrade gracefully.

**Relationships**:

- Created from `UmmAlQuraBundleManifest` + existing `kSaudiCities` metadata +
  curated manual mappings.
- Converts into persisted `CityOption`.

## 4. `UmmAlQuraScheduleDay`

**Purpose**: Represent a day decoded directly from a city bundle file before it
is converted into the runtime persistence model.

**Fields**:

| Field | Type | Notes |
|------|------|-------|
| `bundleId` | `String` | Owning city |
| `hijriYmd` | `String` | e.g. `1447-01-01` |
| `gregorianYmd` | `String` | e.g. `2025-06-26` |
| `weekdayEn` | `String` | Source weekday label |
| `fajr` | `String` | `HH:mm` official source time |
| `sunrise` | `String` | `HH:mm` official source time |
| `dhuhr` | `String` | `HH:mm` official source time |
| `asr` | `String` | `HH:mm` official source time |
| `maghrib` | `String` | `HH:mm` official source time |
| `isha` | `String` | `HH:mm` official source time |
| `sourceHijriYear` | `int` | The bundle year bucket that produced the day |

**Validation**:

- `gregorianYmd` must parse cleanly into a `DateTime`.
- All six prayer values must match `HH:mm`.
- Duplicate `gregorianYmd` entries for the same `bundleId` are invalid.

## 5. `PrayerCalendarDay` (existing runtime persistence model)

**Purpose**: Continue serving the rest of the app with the same runtime shape
used by UI rendering and manual overrides.

**Existing key fields**:

| Field | Type | Notes |
|------|------|-------|
| `cityKey` | `String` | Will prefer bundle-based keying for official cities |
| `gregorianYmd` | `String` | Primary date key |
| `generatedAdhanMinutes` | `List<int>` | Now sourced from official bundle minutes |
| `manualAdhanMinutesByPrayerId` | `Map<int, int>` | Preserved override behavior |
| `manualIqamaMinutesByPrayerId` | `Map<int, int>` | Preserved override behavior |
| `generatedAtMs` | `int` | Initial hydrate timestamp |
| `updatedAtMs` | `int` | Last override update timestamp |

**Validation**:

- `generatedAdhanMinutes.length` must stay at 6.
- `cityKey` for official bundle cities must be deterministic and derived from
  `bundleId`, not transient alias text.

**State transitions**:

1. `official_decoded` -> official day read from bundle
2. `cached` -> day saved into Hive
3. `overridden` -> any manual adhan or iqama map becomes non-empty
4. `reset` -> overrides cleared, official generated minutes preserved

## 6. `GregorianCoverageWindow`

**Purpose**: Centralize the user-facing date-range logic used by calendar UI,
selection blocking, and validation.

**Fields**:

| Field | Type | Notes |
|------|------|-------|
| `startInclusive` | `DateTime` | January 1 of the current Gregorian year |
| `today` | `DateTime` | Normalized current date |
| `endInclusive` | `DateTime` | December 31 of Gregorian year `today.year + 5` |

**Rules**:

- Any date `< startInclusive` is out of range.
- Any date `> endInclusive` is out of range.
- Any date inside the current Gregorian year but `< today` is visible but
  read-only.
- Any date from `today` through `endInclusive` is selectable/editable subject
  to existing override rules.

## 7. `DateAvailabilityState`

**Purpose**: Give the calendar UI an explicit state instead of ad-hoc
comparisons.

**Enum values**:

- `pastReadOnly`
- `selectable`
- `outOfRange`

**Consumers**:

- `HijriPrayerCalendarScreen`
- Day editor entry points
- Any future date picker or summary badge that needs the same behavior
