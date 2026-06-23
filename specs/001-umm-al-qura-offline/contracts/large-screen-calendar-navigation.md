# Contract: Large-Screen Calendar Navigation

## Purpose

Define the Hijri month-navigation behavior for the prayer calendar when the app
is presented on wide mosque-oriented layouts where the month controls must stay
readable and visually important.

## Inputs

| Input | Type | Notes |
|------|------|-------|
| `layoutMode` | `CalendarNavigationLayoutMode` | Must resolve to `largeScreenSidePanel` for qualifying wide layouts |
| `selectedHijriYear` | `int` | Current supported Hijri year being browsed |
| `selectedHijriMonth` | `int` | Active Hijri month |
| `monthOptions` | `List<HijriMonthNavigationOption>` | Visible month set for the selected year |
| `localeCode` | `String` | Affects month-label length and numeral rendering |
| `textScale` | `double` | Must not collapse the panel into unreadable controls |

## Layout Rules

1. The month list must remain visible as a persistent side panel while the
   calendar content is displayed.
2. The side panel must not require opening a modal, drawer, or overflow menu
   to access month choices.
3. The active Hijri month must have stronger visual emphasis than inactive
   months through contrast, weight, fill, border, or a combination of those.
4. Month controls must remain readable from the normal mosque operating
   position and must not rely on miniature chips or precision tapping.
5. If the month list requires scrolling, the active month must auto-scroll into
   view when the selected month changes.
6. When the selected Hijri year changes, the side panel must rebuild against
   that year's visible months and keep the new active month obvious.

## Interaction Rules

1. Tapping or selecting a month changes the calendar content without navigating
   away from the screen.
2. Adjacent-month actions, if present, must stay synchronized with the selected
   side-panel month.
3. The side panel must keep working in all supported locales, including Arabic
   month labels and localized numerals where enabled.
4. If a month contains only visible read-only past dates, it is still shown as
   a valid month choice but must not mislead the user into thinking those days
   are editable.

## Failure Behavior

1. If the selected Hijri year has no months to render, the screen must show a
   localized recoverable empty or error state instead of an empty side panel.
2. If layout constraints shrink below the large-screen threshold, the UI may
   fall back to compact navigation but must preserve the same selected month and
   supported-date rules.

## Validation Expectations

- A large-screen widget or golden test proves that the side panel remains
  visible beside the calendar content.
- The active month remains clearly distinguished after changing month or year.
- Arabic and English month labels remain legible without clipping in the panel.
