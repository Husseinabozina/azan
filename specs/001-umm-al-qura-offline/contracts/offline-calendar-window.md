# Contract: Offline Calendar Window

## Purpose

Define the date availability and schedule lookup behavior for the prayer
calendar UI once the official Umm Al-Qura bundle is used.

## Inputs

| Input | Type | Notes |
|------|------|-------|
| `selectedCity.bundleId` | `String` | Required official city key |
| `currentDate` | `DateTime` | Normalized runtime today |
| `requestedDate` | `DateTime` | Date being browsed or edited |
| `officialScheduleDay` | `PrayerCalendarDay?` | Cached or hydrated official day |

## Window Rules

1. Supported browsing starts on January 1 of the current Gregorian year.
2. Supported browsing ends on December 31 of the fifth Gregorian year after the
   current one.
3. Dates earlier than `currentDate` but still inside the current Gregorian year
   are visible and readable, but not selectable for editing.
4. Dates from `currentDate` through the supported end date are selectable and
   editable under existing override rules.
5. Dates before the current Gregorian year or after the supported end date are
   out of range and must not be presented as valid official schedule dates.

## UI States

| State | Condition | Required UI Behavior |
|------|-----------|----------------------|
| `pastReadOnly` | `requestedDate < currentDate` and same Gregorian year | Show the day, suppress edit affordance, and label it read-only |
| `selectable` | `currentDate <= requestedDate <= endInclusive` | Show the day normally with edit access where applicable |
| `outOfRange` | before start or after end | Show localized guidance and a route back to supported dates |

## Official Schedule Lookup Contract

1. Runtime lookup uses `selectedCity.bundleId` plus `requestedDate`.
2. If the day is already in Hive, return the cached `PrayerCalendarDay`.
3. Otherwise, load the owning city asset, parse the requested day, convert it
   to `PrayerCalendarDay.generated(...)`, persist it, and return it.
4. Manual adhan and iqama overrides always layer on top of the official
   generated minutes.

## Validation Expectations

- Today loads offline for every shipped city.
- Past days inside the current Gregorian year are blocked consistently.
- The first date after the supported end range always resolves to `outOfRange`.
