# Feature Specification: Offline Umm Al-Qura Prayer Times

**Feature Branch**: `001-umm-al-qura-offline`

**Created**: 2026-05-23

**Status**: Draft

**Input**: User description: "Integrate an approved Umm Al-Qura prayer
timetable package into azan so the app can serve multiple Saudi cities fully
offline with Hijri-first calendar browsing, clear city selection and support
visibility, and long-range schedule use across the full current Hijri year
plus forward coverage through the end of the Hijri year that contains the end
of the fifth upcoming Gregorian year."

## Clarifications

### Session 2026-05-23

- Q: How should the city picker treat cities that exist in the bundle but do
  not meet the full 5-year support promise? → A: Treat all bundle cities as
  fully supported; all cities have full 10-year data.

### Session 2026-05-25

- Correction: The calendar must be Hijri-first in user-facing navigation and
  wording; the earlier Gregorian-first interpretation was not the intended
  requirement.
- Q: How should the supported browsing window be defined? → A: Show the full
  current Hijri year, keep past dates inside that Hijri year visible but not
  selectable, and continue supported forward coverage through the end of the
  Hijri year that contains the end of the fifth upcoming Gregorian year.
- Q: If the 5-Gregorian-year forward horizon ends in the middle of a Hijri
  year, where should support stop? → A: Extend support to the end of that
  final covered Hijri year rather than stopping mid-year.
- Q: When the app updates to a newer approved timetable bundle, what happens
  to saved official day cache and user configuration? → A: Keep the selected
  city and local adjustments, but refresh or replace cached official day
  records from the newer bundle.
- Update: The prayer-time management calendar must be large-screen-friendly in
  its browsing controls. Hijri month navigation cannot remain a tiny,
  low-emphasis strip that is hard to see or operate on a mosque display.
- Q: What should the large-screen Hijri month-navigation layout be? → A: Use a
  large persistent side panel for month navigation, with clear emphasis for
  the active month.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Guided Offline City Setup (Priority: P1)

As a mosque operator, I want to choose my city once and continue seeing the
official daily prayer times even when the device has no internet, so the app
remains dependable during normal daily use.

This story affects the current city-selection flow, the setup and selection UI,
home prayer-time surfaces, and persisted schedule behavior across supported
locales and orientations.

**Why this priority**: The feature has no value if the app cannot reliably show
today's times offline for a chosen city.

**Independent Test**: Disconnect the device from the internet, select a
supported city, and verify that today's prayer times appear and remain
available after restarting the app.

**Acceptance Scenarios**:

1. **Given** the app includes an approved official timetable for a supported
   city and the device has no internet, **When** the user selects that city,
   **Then** the app shows today's prayer times without requiring a network
   connection.
2. **Given** a supported city has already been selected, **When** the user
   closes and reopens the app while offline, **Then** the same city and its
   current-day prayer schedule are restored automatically.
3. **Given** the user is choosing a city, **When** the city list is shown,
   **Then** the UI presents every city from the approved official bundle as an
   available offline choice without partial-support restrictions.

---

### User Story 2 - Browse Fixed Multi-Year Official Schedule (Priority: P2)

As a planner or administrator, I want to browse the official schedule for my
selected city across the supported fixed window of the full current Hijri year
plus forward coverage through the end of the Hijri year that contains the end
of the fifth upcoming Gregorian year, using Hijri month and year navigation
while still seeing Gregorian date context, so I can confirm upcoming prayer
times and calendar dates well in advance.

This story affects the prayer-calendar experience, Hijri date browsing, and
localized presentation of city and prayer-time content across shared mobile and
large-screen surfaces, including the UI state that communicates the current
date range and support boundary in a Hijri-first way, with special emphasis on
large-screen month navigation visibility and ease of operation.

**Why this priority**: Long-range access is the main reason to adopt the
prepared official timetable instead of relying only on generated daily times.

**Independent Test**: With internet disabled, open the schedule for a supported
city on both a normal screen and a large mosque-oriented screen, browse
several future dates, and confirm month-to-month navigation remains obvious,
readable, and easy to operate near the start, middle, and end of the published
coverage window, with a persistent large-screen month-navigation panel.

**Acceptance Scenarios**:

1. **Given** a selected city is supported by the official bundle, **When** the
   user browses any date inside the full current Hijri year or inside the
   forward coverage that continues through the end of the Hijri year
   containing the end of the fifth upcoming Gregorian year while offline,
   **Then** the app shows the official prayer times for that date.
2. **Given** the user changes the app language, **When** the same future date
   is viewed again, **Then** city names, prayer labels, and schedule context
   remain understandable with no missing text placeholders.
3. **Given** the user is looking at past dates inside the current Hijri year,
   **When** the date picker or calendar is shown, **Then** those older dates
   appear but are not selectable.
4. **Given** the user is browsing the calendar, **When** month and year
   controls are shown, **Then** the UI presents Hijri month and year choices as
   the primary browsing structure while still showing the Gregorian date for
   each day.
5. **Given** the calendar is shown on a large-screen layout, **When** the user
   looks for month navigation, **Then** the current Hijri month and available
   month choices are visually prominent, easy to read from the normal
   operating position, and are presented in a large persistent side panel
   rather than a tiny low-emphasis strip below the main summary area.
6. **Given** the user wants to move to another visible month on a large
   screen, **When** the browsing controls are used, **Then** the current month
   is clearly distinguished inside that side panel and the user can change
   months without precision tapping or hunting through miniature controls.
7. **Given** the user reaches the end of the supported fixed window,
   **When** the next date is requested, **Then** the UI explains that official
   offline coverage stops there instead of appearing broken or empty.

---

### User Story 3 - Trust Coverage and Keep Existing Operations (Priority: P3)

As a mosque administrator, I want the app to tell me clearly which dates are
inside the supported browsing window and to preserve my local prayer-time
adjustments, so moving to the official offline timetable does not break
existing operations.

This story affects supported-range visibility, disabled past-date handling,
unsupported-date messaging, and the continuity of existing local schedule
adjustments layered on top of official times, with Hijri-first calendar
navigation.

**Why this priority**: Operators need confidence that the app is showing
official supported data and not silently inventing or losing schedule behavior.

**Independent Test**: Try a date outside the approved browsing range and
verify that the app explains the limitation clearly, while existing local
adjustments remain available for supported city/date views.

**Acceptance Scenarios**:

1. **Given** a future date is outside the approved official browsing range,
   **When** the user attempts to view it, **Then** the app shows a clear
   unsupported-data message instead of presenting it as a valid official
   schedule.
2. **Given** a user already depends on local azan or iqama adjustments,
   **When** the official offline timetable is enabled for a supported city,
   **Then** those adjustments still apply and do not require reconfiguration.
3. **Given** the user is browsing beyond the supported range, **When** the app
   shows an out-of-range date state, **Then** the UI clearly guides the user
   back to a supported date range.
4. **Given** the user sees dates earlier than today within the current
   Hijri year, **When** the user attempts to select one, **Then** the UI
   prevents the selection without hiding the historical dates from view.
5. **Given** the app ships a newer approved timetable bundle, **When** the
   user reopens a previously selected supported city, **Then** the app keeps
   the selected city and local adjustments while refreshing official cached
   day records from the newer bundle.

---

### Edge Cases

- What happens when the app is opened offline for the first time before any
  city has been selected?
- What happens if the user switches cities close to midnight or across a Hijri
  date boundary?
- How does the app present past dates from the current Hijri year that are
  visible but not selectable?
- How does the app present unsupported dates near the end of the coverage
  window that starts with the full current Hijri year and ends at the close of
  the final covered Hijri year?
- How does the app keep the supported range understandable when the current
  Hijri year spans parts of two Gregorian years?
- How does the calendar keep month navigation readable and easy to operate on
  large mosque screens when Hijri month names are long or the user is standing
  away from the display?
- How does the large-screen side panel remain readable and clearly dominant
  when the selected month changes or the user switches Hijri years?
- How does the app refresh official cached day records after an app update
  while preserving the saved city and local adjustments?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow users to select from the cities that are
  approved for official offline prayer-time support through a clear selection
  UI.
- **FR-002**: The system MUST persist the selected city so the user does not
  need to repeat setup after restarting the app.
- **FR-003**: The system MUST display the selected city's current-day prayer
  times without requiring an internet connection once the app is installed.
- **FR-004**: The system MUST present all cities from the approved official
  bundle as supported offline choices in the selection UI.
- **FR-005**: The system MUST present the approved official prayer times for
  every covered city/date combination exactly as published in the timetable
  package.
- **FR-006**: The system MUST support browsing and using official prayer times
  across a fixed user-facing window consisting of the full current Hijri year
  plus forward coverage through the end of the Hijri year that contains the
  end of the fifth upcoming Gregorian year for cities it marks as supported.
- **FR-007**: The system MUST show dates earlier than today within the current
  Hijri year as visible but not selectable.
- **FR-008**: The system MUST NOT present dates outside the user-facing current
  Hijri year plus forward coverage through the end of the Hijri year that
  contains the end of the fifth upcoming Gregorian year as part of the
  supported schedule range.
- **FR-009**: The system MUST show a clear user-facing explanation when a date
  falls outside the supported browsing range.
- **FR-010**: The system MUST show the selected city's supported date range in
  the schedule-browsing UI whenever the user is navigating dates.
- **FR-011**: The system MUST use one authoritative official schedule for the
  selected city across home, calendar, and display-oriented prayer-time views
  so users do not see conflicting times.
- **FR-012**: Users MUST be able to continue using existing local azan and
  iqama adjustments alongside the official offline timetable for supported
  city/date views.
- **FR-013**: The system MUST provide city names, prayer labels, and
  coverage-related messages in the app's supported languages without missing
  placeholders on affected surfaces.
- **FR-014**: The system MUST provide a recovery path in the UI when the user
  reaches a date outside the supported browsing range, including a clear way
  back to supported dates.
- **FR-015**: The system MUST present calendar month and year navigation in
  Hijri terms as the primary browsing model while preserving Gregorian date
  context for each day.
- **FR-016**: When the app ships a newer approved timetable bundle, the system
  MUST preserve the saved city and existing local azan or iqama adjustments
  while refreshing or replacing cached official day records from the newer
  bundle before presenting supported dates.
- **FR-017**: The system MUST give the active Hijri month and year strong
  visual prominence within the schedule-browsing UI so the current browsing
  context is immediately understandable.
- **FR-018**: On large-screen layouts, the system MUST provide month
  navigation that is easy to read and easy to operate from the normal mosque
  control position without relying on tiny controls or precision tapping.
- **FR-019**: On large-screen layouts, the system MUST place Hijri month
  navigation in a large persistent side panel instead of compressing that
  navigation into a minor secondary strip.
- **FR-020**: The system MUST clearly distinguish the currently selected Hijri
  month from adjacent month choices whenever the user is browsing the prayer
  calendar.

### Constitution Alignment *(mandatory)*

- **CA-001 Localization**: Offline prayer-time content, city names, and
  coverage messages must be understandable in the app's supported locales.
- **CA-002 Readability**: Replacing the schedule source must preserve clear,
  legible prayer-time presentation across portrait, landscape, and large-screen
  display surfaces, including setup, selection, Hijri calendar navigation, and
  unsupported-state UI. Large-screen navigation controls must remain readable
  and visually balanced with the rest of the page, using a persistent side
  panel instead of shrinking into a low-emphasis secondary strip.
- **CA-003 Architecture**: The feature must extend the existing city-selection
  and prayer-calendar user journey rather than creating a separate schedule
  experience.
- **CA-004 Verification**: Acceptance validation must prove offline startup,
  city selection, fixed-window browsing, disabled past-date handling, exact
  timetable fidelity, unsupported coverage handling, UI guidance, and retained
  local adjustments.

### Key Entities *(include if feature involves data)*

- **Approved Schedule Package**: The published official prayer-time dataset
  used to support offline city and date coverage.
- **Supported City**: A city the app may present for official offline use,
  including its display names and inclusion in the approved official bundle.
- **Schedule Day**: A single dated record of official prayer times for one city.
- **Coverage Window**: The date range the app is allowed to present as approved
  official schedule coverage for a city, starting with the full current Hijri
  year and continuing through the end of the Hijri year that contains the end
  of the fifth upcoming Gregorian year, with past dates in the current Hijri
  year visible but not selectable.
- **Local Prayer Configuration**: The saved city choice and any user-maintained
  azan or iqama adjustments that remain active in daily use.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of city/date combinations shown to users as officially
  supported can be opened offline without requiring internet access.
- **SC-002**: In acceptance validation, displayed prayer times match the
  approved official timetable exactly for all sampled supported cities and
  boundary dates.
- **SC-003**: A user can select a supported city and reach today's prayer-time
  view in under 5 seconds on a representative device, even with internet
  disabled.
- **SC-004**: Users can browse any date inside the full current Hijri year and
  the forward coverage that continues through the end of the Hijri year that
  contains the end of the fifth upcoming Gregorian year for a supported city
  without unavailable-state errors, and 100% of out-of-range date attempts
  show a clear guidance message.
- **SC-005**: During acceptance review, 100% of tested past dates in the
  current Hijri year are visible but blocked from selection.
- **SC-006**: During acceptance review, 100% of tested setup and out-of-range
  date UI states make the next valid user action clear without requiring
  external instructions.
- **SC-007**: No missing-translation placeholders appear on affected
  prayer-time surfaces in supported locales during acceptance review.
- **SC-008**: During large-screen acceptance review, operators can identify
  the active Hijri month and year and move to another visible month in under 3
  seconds without repeated mis-taps.
- **SC-009**: In 100% of tested large-screen calendar states, month navigation
  remains clearly visible and discoverable without requiring the operator to
  move unusually close to the display to understand the controls.

## Assumptions

- The scope of this feature is limited to the Saudi cities contained in the
  approved official timetable set.
- The approved official timetable set becomes the authoritative source for
  covered city/date prayer times.
- Weather and other auxiliary online experiences may remain internet-dependent;
  this feature guarantees offline support for core prayer-time schedule access.
- Every city included in the approved official bundle has full 10-year
  timetable coverage available for use inside the app.
- Even if the approved timetable package contains additional years, the user
  promise for this feature is limited to the full current Hijri year plus
  forward coverage through the end of the Hijri year that contains the end of
  the fifth upcoming Gregorian year that the UI presents.
- The schedule UI may still show Gregorian day-level context, but the primary
  browsing structure for month and year navigation is Hijri.
- The prayer-time management page is expected to be used on large mosque
  screens, so visibility, clear hierarchy, and low-precision interaction are
  more important than compact dense month-navigation UI.
- On large-screen layouts, a persistent side panel for Hijri month navigation
  is preferred over compact bottom or inline month-strip patterns.
- Existing azan and iqama adjustment behavior remains part of the expected user
  experience and is preserved rather than redesigned by this feature.
