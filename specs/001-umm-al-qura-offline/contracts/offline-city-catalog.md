# Contract: Offline City Catalog

## Purpose

Define the data and behavior required by the city selection flow once the
official Umm Al-Qura bundle becomes the authoritative schedule source.

## Input Sources

- Repo-local `assets/data/umm_al_qura/v1/manifest.json`
- Repo-local `assets/data/umm_al_qura/v1/cities/gz/*.json.gz`
- Existing `kSaudiCities` metadata for Arabic names and coordinates where
  available
- Curated alias and mapping table for bundle cities that do not match current
  app names 1:1

## App-Facing Catalog Shape

| Field | Type | Required | Notes |
|------|------|----------|-------|
| `bundleId` | `String` | Yes | Stable city identifier |
| `nameEn` | `String` | Yes | English display and lookup name |
| `nameAr` | `String` | Yes | Arabic display name |
| `regionEn` | `String?` | No | Optional side label |
| `countryCode` | `String` | Yes | `SA` |
| `lat` | `double?` | No | Weather compatibility when available |
| `lon` | `double?` | No | Weather compatibility when available |
| `scheduleAssetPath` | `String` | Yes | `.json.gz` runtime asset path |
| `aliases` | `List<String>` | Yes | Normalized legacy and bundle-name aliases |
| `selectable` | `bool` | Yes | Must be `true` for every shipped bundle city |

## Behavioral Rules

1. Every shipped bundle city appears in the selection UI as a selectable
   offline option.
2. The selection UI persists the chosen city together with its `bundleId`.
3. Search and name matching honor both localized display names and alias
   matches so legacy names continue to resolve.
4. If catalog loading fails, the app blocks selection completion and shows a
   localized recoverable error.
5. If a newer approved bundle ships and the saved `bundleId` still exists, the
   app preserves that city selection instead of forcing re-selection.

## Non-Goals

- This contract does not define weather sourcing.
- This contract does not promise runtime access to raw review JSON files.

## Validation Expectations

- Catalog count matches the shipped manifest city count.
- Every catalog entry points to an existing asset.
- Every selected city can hydrate at least today's official schedule offline.
- A previously saved shipped `bundleId` still resolves after a bundle update.
