# Feature Specification: Offline Umm Al-Qura Prayer Times

**Feature Branch**: `001-umm-al-qura-offline`

**Created**: 2026-05-23

**Status**: Draft

**Input**: User description: "Integrate an approved Umm Al-Qura prayer
timetable package into azan so the app can serve multiple Saudi cities fully
offline for the next 5 years, with clear UI for city selection, support
visibility, and offline schedule use."

## Clarifications

### Session 2026-05-23

- Q: How should the city picker treat cities that exist in the bundle but do
  not meet the full 5-year support promise? → A: Treat all bundle cities as
  fully supported; all cities have full 10-year data.
- Q: Should the 5-year user-facing window be rolling or fixed? → A: Show the
  full current year plus the next 5 full years; past dates in the current year
  are visible but not selectable.
- Q: Does "current year" mean Gregorian or Hijri? → A: Gregorian current year.

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
selected city across the supported fixed window of the current Gregorian year
plus the next 5 full Gregorian years, so I can confirm upcoming prayer times
and calendar dates well in advance.

This story affects the prayer-calendar experience, date browsing, and localized
presentation of city and prayer-time content across shared mobile and
large-screen surfaces, including the UI state that communicates the current
date range and support boundary.

**Why this priority**: Long-range access is the main reason to adopt the
prepared official timetable instead of relying only on generated daily times.

**Independent Test**: With internet disabled, open the schedule for a supported
city and browse several future dates, including boundary dates near the start
and end of the published coverage window.

**Acceptance Scenarios**:

1. **Given** a selected city is supported by the official bundle, **When** the
   user browses any date inside the current Gregorian year or the next 5 full
   Gregorian years while offline, **Then** the app shows the official prayer
   times for that date.
2. **Given** the user changes the app language, **When** the same future date
   is viewed again, **Then** city names, prayer labels, and schedule context
   remain understandable with no missing text placeholders.
3. **Given** the user is looking at past dates inside the current Gregorian
   year,
   **When** the date picker or calendar is shown, **Then** those older dates
   appear but are not selectable.
4. **Given** the user reaches the end of the supported fixed window,
   **When** the next date is requested, **Then** the UI explains that official
   offline coverage stops there instead of appearing broken or empty.

---

### User Story 3 - Trust Coverage and Keep Existing Operations (Priority: P3)

As a mosque administrator, I want the app to tell me clearly which dates are
inside the supported browsing window and to preserve my local prayer-time
adjustments, so moving to the official offline timetable does not break
existing operations.

This story affects Gregorian date-range visibility, disabled past-date
handling,
unsupported-date messaging, and the continuity of existing local schedule
adjustments layered on top of official times.

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
   Gregorian year, **When** the user attempts to select one, **Then** the UI
   prevents the selection without hiding the historical dates from view.

---

### Edge Cases

- What happens when the app is opened offline for the first time before any
  city has been selected?
- What happens if the user switches cities close to midnight or across a Hijri
  date boundary?
- How does the app present past dates from the current Gregorian year that are
  visible but not selectable?
- How does the app present unsupported dates near the end of the current
  Gregorian year plus next-5-years coverage window?
- What happens to the saved city and local adjustments after an app update that
  includes a newer official timetable set?

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
  across a fixed user-facing window consisting of the full current Gregorian
  year plus the next 5 full Gregorian years for cities it marks as supported.
- **FR-007**: The system MUST show dates earlier than today within the current
  Gregorian year as visible but not selectable.
- **FR-008**: The system MUST NOT present dates outside the user-facing current
  Gregorian year plus next-5-full-Gregorian-years browsing promise as part of
  the supported schedule range.
- **FR-009**: The system MUST show a clear user-facing explanation when a date
  falls outside the supported browsing range.
- **FR-010**: The system MUST show the selected city's supported date range in
  the schedule-browsing UI whenever the user is navigating future dates.
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

### Constitution Alignment *(mandatory)*

- **CA-001 Localization**: Offline prayer-time content, city names, and
  coverage messages must be understandable in the app's supported locales.
- **CA-002 Readability**: Replacing the schedule source must preserve clear,
  legible prayer-time presentation across portrait, landscape, and large-screen
  display surfaces, including setup, selection, and unsupported-state UI.
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
  official schedule coverage for a city, limited to the full current Gregorian
  year plus the next 5 full Gregorian years, with past dates in the current
  Gregorian year visible but not selectable.
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
- **SC-004**: Users can browse any date inside the current Gregorian year plus
  the next 5 full Gregorian years for a supported city without
  unavailable-state errors, and 100% of out-of-range date attempts show a
  clear guidance message.
- **SC-005**: During acceptance review, 100% of tested past dates in the
  current Gregorian year are visible but blocked from selection.
- **SC-006**: During acceptance review, 100% of tested setup and out-of-range
  date UI states make the next valid user action clear without requiring
  external instructions.
- **SC-007**: No missing-translation placeholders appear on affected
  prayer-time surfaces in supported locales during acceptance review.

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
  promise for this feature is limited to the full current Gregorian year plus
  the next 5 full Gregorian years that the UI presents.
- Existing azan and iqama adjustment behavior remains part of the expected user
  experience and is preserved rather than redesigned by this feature.
