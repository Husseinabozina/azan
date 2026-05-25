# Contract: Offline Calendar Window

## Purpose

Define the date availability, Hijri navigation, and official schedule lookup
behavior for the prayer calendar UI once the approved Umm Al-Qura bundle is the
authoritative source.

## Inputs

| Input | Type | Notes |
|------|------|-------|
| `selectedCity.bundleId` | `String` | Required official city key |
| `currentDate` | `DateTime` | Normalized runtime today |
| `hijriOffsetDays` | `int` | Existing app-controlled Hijri display offset |
| `requestedDate` | `DateTime` | Date being browsed or edited |
| `supportedWindow` | `SupportedScheduleWindow` | Mixed Hijri/Gregorian support model |
| `officialScheduleDay` | `PrayerCalendarDay?` | Cached or freshly hydrated official day |

## Window Rules

1. Supported browsing starts on the first Gregorian date belonging to the
   current Hijri year.
2. The app computes a Gregorian forward anchor at December 31 of the fifth
   upcoming Gregorian year.
3. The final supported Hijri year is the Hijri year containing that Gregorian
   forward anchor.
4. Supported browsing ends on the last Gregorian date belonging to that final
   supported Hijri year.
5. Dates earlier than `currentDate` but still inside the current Hijri year are
   visible and readable, but not selectable for editing.
6. Dates from `currentDate` through the supported end date are selectable and
   editable under existing override rules.
7. Dates before the supported start or after the supported end are out of range
   and must not be presented as valid official schedule dates.

## Hijri Navigation Contract

1. The year picker lists every supported Hijri year from the current Hijri year
   through the final supported Hijri year.
2. Month navigation is Hijri-first and reflects the months present within the
   selected supported Hijri year.
3. Day cards and detail surfaces continue to show Gregorian day context for
   each rendered official schedule day.
4. Supported-range messaging explains the mixed rule clearly without exposing
   raw implementation jargon.
5. On compact layouts, month navigation may stay inline with the calendar
   content as long as the active month remains obvious and tap targets remain
   readable.
6. On large-screen layouts, month navigation must stay visible in a persistent
   side panel rather than collapsing behind a modal, drawer, or tiny strip.
7. The active Hijri month must remain clearly distinguished whenever the user
   changes month or year.

## UI States

| State | Condition | Required UI Behavior |
|------|-----------|----------------------|
| `pastReadOnly` | `requestedDate < currentDate` and the date still belongs to the current supported Hijri year | Show the day, suppress edit affordance, and label it read-only |
| `selectable` | `currentDate <= requestedDate <= endInclusive` | Show the day normally with edit access where applicable |
| `outOfRange` | `requestedDate < startInclusive` or `requestedDate > endInclusive` | Show localized guidance and a route back to supported dates |

## Official Schedule Lookup Contract

1. Runtime lookup uses `selectedCity.bundleId` plus `requestedDate`.
2. If the requested day is already in Hive and its `officialSourceToken`
   matches the currently shipped manifest token, return the cached
   `PrayerCalendarDay`.
3. Otherwise, load the owning city asset, parse the requested day or range,
   convert it to `PrayerCalendarDay.generated(...)`, merge any preserved manual
   overrides from stale cache, persist it with the current official source
   token, and return it.
4. Manual adhan and iqama overrides always layer on top of the official
   generated minutes.

## Validation Expectations

- The first supported day of the current Hijri year loads offline for every
  shipped city.
- Past days inside the current Hijri year are blocked consistently.
- The final supported day of the final supported Hijri year resolves normally.
- The first day after the supported end range always resolves to `outOfRange`.
- Large-screen calendar layouts keep the month panel visible, readable, and
  synchronized when the selected Hijri year or month changes.
