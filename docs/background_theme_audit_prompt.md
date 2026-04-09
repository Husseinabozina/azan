# Background Theme Audit Prompt

This document captures two things for this repo:

1. The practical method for extracting dominant background colors and detecting color conflicts.
2. A ready-to-use prompt for a coding agent to audit and selectively fix background theme colors.

## Method Used In This Repo

### 1. How to identify dominant background colors
- Enumerate the real background set from:
  - `lib/views/change_ background_settings/change_background_settings_screen.dart` via `BackgroundThemes.all`
  - `lib/core/theme/app_theme.dart` via `AppTheme._packs`
- Resolve each background to its real asset path, then analyze the actual image file instead of guessing from the UI.
- For each image:
  - Downscale to a small working size such as `96x96` or `128x128`
  - Sample the whole image and also split it into `top`, `center`, and `bottom` zones
  - Extract the top `3-5` dominant color families
  - Ignore tiny outliers and noise colors that are not visually meaningful
- Prefer a practical palette, not a mathematically noisy one:
  - Merge near-identical shades
  - Keep visually dominant families with their approximate share
  - Report them as hex colors plus percentages

### 2. How to detect color conflicts
- Test color relationships against the real rendering paths in this project:
  - Raw background image against `primaryText`, `secondaryText`, and `accent`
  - Dialog surfaces using `dialogBg`, `dialogTitleColor`, `dialogBodyTextColor`
  - Buttons using `primaryButtonBackground` and `primaryButtonTextColor`
  - Display-board layers after `DisplayBoardBackdropOverlay` and `DisplayBoardSurface`
- Use WCAG contrast as a hard baseline:
  - Primary text target: `>= 7:1` whenever practical
  - Secondary text target: `>= 4.5:1`
  - Button label on button fill: `>= 4.5:1`, prefer `>= 7:1` on critical labels
- Add a large-display safety rule:
  - Treat TVs and weak commercial panels as harsher than phones
  - Reject combinations that are fragile under glare, washout, aggressive brightness, or mediocre panel quality even if a minimum ratio barely passes
- Explicitly reject weak combinations such as:
  - White text on yellow or gold fills
  - Light text on light accent surfaces
  - Dark brown text on saturated blue backgrounds
  - Any pair with low luminance separation and weak hue separation
- Check visual harmony as well as readability:
  - Do not rely on hue difference alone
  - Evaluate luminance, saturation, and warm/cool compatibility together

### 3. How to decide whether to change a theme
- Preserve an existing palette if it is already safe and visually coherent.
- Change only backgrounds that fail readability, robustness, or harmony.
- Prefer updating `_ThemePack` values in `AppTheme` instead of adding new public APIs.
- Adjust display-board overlay/surface styling only if a background still fails after its actual display-board layers are considered.

## Repo-Specific References

- Background list: [lib/views/change_ background_settings/change_background_settings_screen.dart](/Users/husseinabozina/azan/lib/views/change_ background_settings/change_background_settings_screen.dart)
- Theme packs: [lib/core/theme/app_theme.dart](/Users/husseinabozina/azan/lib/core/theme/app_theme.dart)
- Display-board overlays and surfaces: [lib/views/display_board/components/display_board_runtime_widgets.dart](/Users/husseinabozina/azan/lib/views/display_board/components/display_board_runtime_widgets.dart)
- Dialog color usage: [lib/core/utils/dialoge_helper.dart](/Users/husseinabozina/azan/lib/core/utils/dialoge_helper.dart)

## Ready-To-Use Prompt

Copy the prompt below as-is when you want a coding agent to audit and selectively fix background theme colors in this repo.

```text
You are working inside the Azan Flutter repository.

Your task is to audit every background-driven theme and selectively fix only the failing ones.

Repo context:
- Background definitions are driven by `BackgroundThemes.all` in `lib/views/change_ background_settings/change_background_settings_screen.dart`.
- Theme packs are defined in `AppTheme._packs` in `lib/core/theme/app_theme.dart`.
- Derived colors that must also be audited include:
  - `AppTheme.primaryTextColor`
  - `AppTheme.secondaryTextColor`
  - `AppTheme.accentColor`
  - `AppTheme.dialogBackgroundColor`
  - `AppTheme.dialogTitleColor`
  - `AppTheme.dialogBodyTextColor`
  - `AppTheme.primaryButtonBackground`
  - `AppTheme.primaryButtonTextColor`
- Large display-board rendering uses overlay/surface layers in `lib/views/display_board/components/display_board_runtime_widgets.dart`, especially `DisplayBoardBackdropOverlay` and `DisplayBoardSurface`.

Rules for background color extraction:
1. Discover the real background set from `BackgroundThemes.all` and `AppTheme._packs`.
2. Resolve every background to its real asset file.
3. Analyze the image itself, not a guessed visual description.
4. Downscale each image to a small working size such as `96x96` or `128x128`.
5. Extract the top `3-5` dominant color families from:
   - the whole image
   - the top zone
   - the center zone
   - the bottom zone
6. Ignore tiny outlier colors that are not visually dominant.
7. Merge near-identical shades into practical dominant families and report them as hex values with approximate percentages.

Rules for color-conflict detection:
1. Compute WCAG contrast for:
   - `primaryText` on the raw background
   - `secondaryText` on the raw background
   - `accent` when used as text or highlight against the raw background
   - button text on button fill
   - dialog title/body text on dialog background
   - display-board text after the effective overlay/surface layers are applied
2. Use a large-display-safe standard:
   - Primary text target: `>= 7:1` whenever practical
   - Secondary text target: `>= 4.5:1`
   - Button label on button fill: `>= 4.5:1`, with preference for `>= 7:1` on critical labels
3. Do not stop at minimum math only:
   - Penalize combinations that are fragile under glare, high brightness, poor panel quality, washout, or cheap display hardware
   - Assume this app is used on large mosque display screens where delicate combinations often fail in real life
4. Explicitly reject combinations such as:
   - white text on yellow or gold buttons
   - light text on light accent surfaces
   - dark brown text on saturated blue backgrounds
   - any low-separation pair that is technically passable but visually weak
5. Evaluate color harmony as well:
   - check luminance separation
   - check hue compatibility
   - check saturation balance
   - do not rely on hue difference alone

Change policy:
1. Preserve existing colors if they are already good.
2. Change only the backgrounds that fail readability, robustness, or harmony.
3. Default to updating only `_ThemePack` values in `AppTheme`.
4. Do not introduce public API changes unless absolutely necessary.
5. Only adjust display-board overlays/surfaces if the current display-board treatment causes a failing result that cannot be fixed safely by `_ThemePack` updates alone.

Required output before and after edits:
1. Produce a short audit summary that lists:
   - every failing background
   - extracted dominant palette
   - why the current colors fail
   - what replacement colors you chose
2. Then apply the code edits.
3. Report the exact files changed and the exact theme entries updated.
4. Leave backgrounds that already pass unchanged.

Minimum manual spot-checks:
- `hr19`
- one very light background
- one dark blue background
- one gold-accent-heavy background
- one display-board case with strong overlay and large text

Acceptance criteria:
- Backgrounds that already pass remain unchanged.
- Failing backgrounds are corrected with a brief rationale.
- Button text and dialog text remain readable after the final edits.
- Display-board text remains robust on large bright screens.

When you finish, provide:
- a concise audit summary
- the list of changed backgrounds
- the new color values
- the exact code edits applied
```
