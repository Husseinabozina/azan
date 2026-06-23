# Background Theme Audit Report

- Generated on: `2026-04-01`
- Final audit result: `97 / 97` active backgrounds pass
- Verification command:
  - `dart run tool/background_theme_audit.dart --fail-on-issues`

## What Was Implemented

This repo now contains a real audit tool at `tool/background_theme_audit.dart` that:

- reads the active background set from `BackgroundThemes.all`
- reads theme packs from `AppTheme._packs`
- extracts dominant colors from each image after downscaling
- samples `top`, `center`, and `bottom` zones
- checks contrast for primary text, secondary text, accent/highlight use, dialog colors, button colors, and display-board rendering
- accounts for the dark display-board surface and the per-background readability overlay

## Global Fixes

Two cross-cutting issues were corrected before selective theme changes:

1. Button text now follows the actual button fill color instead of assuming all dark themes need white button labels.
2. Display-board text now uses dedicated on-surface colors so light-theme text does not become unreadable on the board’s dark glass surface.

## Selective Theme Corrections

The audit identified weak light-theme accents and several clearly mismatched background/theme pairings. The following groups were corrected:

- Light/beige backgrounds:
  - strengthened secondary text
  - replaced weak gold-on-light accents with a darker bronze
  - applied to the shared light pack and related light backgrounds such as `background_light2`, `light_background_1`, `convinent_beige_background`, and `white_background_with_naqsh`

- Teal/mint light background:
  - `elegant_teal_arabesque_background` now uses stronger brown secondary text and a deeper teal accent

- Wrong-image/wrong-pack cases:
  - `hr1` and `hr19` were moved to a high-contrast blue pack
  - `hr3` was moved to a high-contrast red pack
  - `hr9`, `vr39`, and selected `VR-*` entries were adjusted toward higher-contrast text choices

- Medium-dark backgrounds:
  - `convinent_olive_green_background`, `light_brown_background`, and `teal_blue_background` were strengthened for readability

## Readability Overlays

Five `VR` backgrounds remained visually hostile even after palette correction because the image content itself contained bright or mixed-value regions. For those, a targeted black readability overlay is now applied only on the affected backgrounds:

- `VR-4.jpg`
- `VR-6.jpg`
- `VR-8.jpg`
- `VR-9.jpg`
- `VR-10.jpg`
- `VR-18.jpg`
- `convinent_olive_green_background.png`
- `light_brown_background.png`
- `teal_blue_background.png`

These overlays are defined centrally in `AppTheme` and are used by:

- `home_screen_mobile`
- `home_screen_landscape`
- `home_screen_landscape_2`
- `azan_prayer_screen`
- `display_board_runtime_base`

## Validation

The final state was validated with:

- `dart run tool/background_theme_audit.dart --fail-on-issues`
- `flutter test test/background_theme_coverage_test.dart`

`flutter analyze` was also run on the touched files. It still reports pre-existing warnings in the large home screen files, but no new blocking analyzer errors were introduced by this background-audit work.
