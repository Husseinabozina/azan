# Contract: Offline Bundle Refresh

## Purpose

Define how the app reacts when a newer approved Umm Al-Qura bundle ships inside
the app while a user already has saved city state and cached official prayer
days.

## Inputs

| Input | Type | Notes |
|------|------|-------|
| `currentManifestToken` | `String` | Derived from the shipped manifest version and generation time |
| `storedManifestToken` | `String?` | Previously acknowledged bundle token from local app data |
| `selectedCity.bundleId` | `String?` | Previously saved official city selection |
| `cachedPrayerDay` | `PrayerCalendarDay?` | Existing Hive entry for a requested supported date |
| `manualOverrides` | `Map` | Existing adhan and iqama override maps already attached to the day |

## Refresh Rules

1. The app derives a single authoritative `currentManifestToken` from the
   shipped bundle manifest.
2. If `storedManifestToken == currentManifestToken`, no bundle-refresh action
   is required.
3. If `storedManifestToken != currentManifestToken`, official cached day
   records are considered stale.
4. A stale official day must reload its generated bundle minutes from the newer
   bundle before the app presents that supported date.
5. The selected city and local adhan or iqama overrides are preserved during
   refresh.
6. The refreshed day replaces the stale official base minutes and persists the
   new manifest token.
7. Refresh may happen lazily per requested day or range; a full eager migration
   of every cached day is not required.

## Failure Behavior

1. If the saved city no longer resolves to a shipped bundle entry, the app must
   block official schedule hydration and route the user back to a recoverable
   city-selection state.
2. If the newer bundle cannot provide the requested supported date, the app
   must show a localized recoverable error instead of silently serving stale
   official data as if it were current.

## Validation Expectations

- After a bundle update, the saved city remains selected when still shipped.
- Existing manual adhan and iqama overrides remain intact after refresh.
- Official generated minutes come from the newer bundle after refresh, not the
  older cached base record.
