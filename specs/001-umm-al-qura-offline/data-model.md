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
| `bundleId` | `String?` | Stable Umm Al-Qura city identifier, e.g. `abha` |
| `regionEn` | `String?` | Optional region label from the bundle manifest |
| `nameAliases` | `List<String>` | Normalized aliases for legacy name matching |

**Validation**:

- `bundleId` is required for any city selected from the official offline
  catalog.
- `nameAr` and `nameEn` must always be non-empty.
- `nameAliases` must be normalized and deduplicated.

**Relationships**:

- Maps 1:1 to an `OfficialCityCatalogEntry`.
- Is persisted by `CacheHelper` and consumed by `AppCubit`, selection UI, and
  shared city labels.

## 2. `UmmAlQuraBundleManifest`

**Purpose**: Represent the shipped root `manifest.json` and drive catalog,
coverage validation, and cache-refresh tokening.

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
| `officialSourceToken` | `String` | Derived runtime token, e.g. `1@2026-05-23T12:14:23+00:00` |

**Validation**:

- `cityCount` must equal `cities.length`.
- Every `cities[].file` must resolve to a bundled asset path.
- Completeness checks must pass for the mixed Hijri/Gregorian support promise
  before the assets are accepted for shipping.

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
| `availableHijriYears` | `List<int>` | Years carried by the underlying bundle |
| `aliases` | `List<String>` | Legacy or normalized names for matching or search |

**Validation**:

- `bundleId`, `nameEn`, `nameAr`, and `scheduleAssetPath` are mandatory.
- `aliases` must include at least one normalized English lookup token.
- If coordinates are missing, weather features must degrade gracefully.

**Relationships**:

- Created from `UmmAlQuraBundleManifest` plus existing app metadata and
  curated alias mappings.
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

## 5. `SupportedScheduleWindow` (design concept replacing the old
Gregorian-only mental model)

**Purpose**: Centralize the mixed support-window logic used by Hijri
navigation, date availability, supported-range messaging, and import
validation.

**Fields**:

| Field | Type | Notes |
|------|------|-------|
| `todayGregorian` | `DateTime` | Normalized current date |
| `currentHijriYear` | `int` | Display Hijri year for `todayGregorian` after offset application |
| `startInclusive` | `DateTime` | First Gregorian date belonging to the current Hijri year |
| `gregorianForwardAnchorInclusive` | `DateTime` | December 31 of the fifth upcoming Gregorian year |
| `finalSupportedHijriYear` | `int` | Hijri year containing the Gregorian forward anchor |
| `endInclusive` | `DateTime` | Last Gregorian date belonging to `finalSupportedHijriYear` |
| `supportedHijriYears` | `List<int>` | Inclusive list from `currentHijriYear` through `finalSupportedHijriYear` |

**Rules**:

- Any date `< startInclusive` is out of range.
- Any date `> endInclusive` is out of range.
- Any date inside the current Hijri year but earlier than `todayGregorian` is
  visible but read-only.
- Any date from `todayGregorian` through `endInclusive` is selectable and
  editable subject to existing override rules.
- The Gregorian forward anchor is an internal calculation input, not the final
  user-facing support end.

## 6. `PrayerCalendarDay` (existing runtime persistence model, extended)

**Purpose**: Continue serving the rest of the app with the same runtime shape
used by UI rendering and manual overrides while tracking official cache
freshness.

**Key fields**:

| Field | Type | Notes |
|------|------|-------|
| `cityKey` | `String` | Prefers bundle-based keying for official cities |
| `gregorianYmd` | `String` | Primary date key |
| `generatedAdhanMinutes` | `List<int>` | Official base minutes from the bundle |
| `manualAdhanMinutesByPrayerId` | `Map<int, int>` | Preserved adhan override behavior |
| `manualIqamaMinutesByPrayerId` | `Map<int, int>` | Preserved iqama override behavior |
| `generatedAtMs` | `int` | Initial hydrate timestamp |
| `updatedAtMs` | `int` | Last override or refresh update timestamp |
| `officialSourceToken` | `String?` | Manifest-derived token used to detect stale official cache |

**Validation**:

- `generatedAdhanMinutes.length` must stay at 6.
- `cityKey` for official bundle cities must be deterministic and derived from
  `bundleId`, not transient alias text.
- Official bundle-backed days must persist the active `officialSourceToken`.

**State transitions**:

1. `official_decoded` -> day read from bundle
2. `cached_current` -> day saved into Hive with the active official source token
3. `stale_after_bundle_update` -> stored token no longer matches the shipped
   manifest token
4. `refreshed` -> generated minutes replaced from the newer bundle while manual
   overrides are preserved
5. `overridden` -> any manual adhan or iqama map becomes non-empty

## 7. `OfficialBundleCacheMetadata`

**Purpose**: Track which shipped official bundle token the runtime has already
acknowledged for lazy cache refresh decisions.

**Fields**:

| Field | Type | Notes |
|------|------|-------|
| `currentOfficialSourceToken` | `String` | Token derived from the shipped manifest |
| `lastSeenOfficialSourceToken` | `String?` | Previously applied token from local app data |
| `lastRefreshCheckAtMs` | `int` | Timestamp of the last bundle freshness check |

**Validation**:

- If `lastSeenOfficialSourceToken != currentOfficialSourceToken`, official
  cached days must be treated as stale until refreshed or replaced.

**Relationships**:

- Stored through `CacheHelper` or a lightweight equivalent.
- Consumed by `AppCubit`, `UmmAlQuraBundleService`, and Hive-backed refresh
  logic.

## 8. `DateAvailabilityState`

**Purpose**: Give the calendar UI an explicit supported-state contract instead
of ad-hoc comparisons.

**Enum values**:

- `pastReadOnly`
- `selectable`
- `outOfRange`

**Consumers**:

- `HijriPrayerCalendarScreen`
- Day editor entry points
- Any future schedule summary or badge that needs the same behavior

## 9. `HijriMonthNavigationOption`

**Purpose**: Represent a single month choice in the Hijri-first calendar
navigation UI for both compact and large-screen layouts.

**Fields**:

| Field | Type | Notes |
|------|------|-------|
| `hijriYear` | `int` | Owning supported Hijri year |
| `monthNumber` | `int` | `1..12` Hijri month index |
| `monthName` | `String` | Localized visible month label |
| `firstGregorianDate` | `DateTime` | First rendered Gregorian day in that Hijri month |
| `lastGregorianDate` | `DateTime` | Last rendered Gregorian day in that Hijri month |
| `containsToday` | `bool` | Helps emphasize the current month when applicable |
| `hasSelectableDays` | `bool` | `true` if the month includes at least one selectable supported day |
| `hasReadOnlyPastDays` | `bool` | `true` if the month includes visible but locked past days |
| `isSelected` | `bool` | Current active month in the UI |

**Validation**:

- `monthNumber` must be between `1` and `12`.
- `firstGregorianDate <= lastGregorianDate`.
- At least one of `hasSelectableDays` or `hasReadOnlyPastDays` must be `true`
  for every rendered month option.

**Relationships**:

- Derived from the loaded `PrayerCalendarDay` list for a supported Hijri year.
- Consumed by `HijriPrayerCalendarScreen` and large-screen navigation tests.

## 10. `CalendarNavigationLayoutMode`

**Purpose**: Explicitly distinguish the compact and large-screen navigation
patterns so layout behavior can be tested rather than inferred ad hoc.

**Enum values**:

- `compactBottomStrip`
- `largeScreenSidePanel`

**Rules**:

- Compact layouts may keep navigation in a horizontal strip near the content.
- Large-screen layouts must render the month navigation as a persistent side
  panel with strong active-month emphasis.
- Layout mode is derived from screen constraints; it must not change the
  supported-date rules themselves.

**Consumers**:

- `HijriPrayerCalendarScreen`
- Calendar widget or golden tests
- Any future shared calendar navigation builder
