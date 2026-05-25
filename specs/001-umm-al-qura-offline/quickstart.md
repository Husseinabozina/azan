# Quickstart: Offline Umm Al-Qura Prayer Times

## 1. Import the source bundle into repo-local assets

After implementation lands, import the approved source bundle into the repo:

```bash
dart run tool/umm_al_qura_import.dart \
  --source /Users/husseinabozina/Desktop/UmmAlQura_PDFs/server_bundle/v1 \
  --dest assets/data/umm_al_qura/v1 \
  --validate-all-cities
```

Expected outcome:

- `assets/data/umm_al_qura/v1/manifest.json` exists
- `assets/data/umm_al_qura/v1/cities/gz/` exists
- the import step fails fast if bundle coverage cannot satisfy the shipped
  mixed Hijri/Gregorian support promise

## 2. Refresh assets and generated references

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Use this step whenever implementation updates generated asset references or
localization outputs.

## 3. Run verification

```bash
flutter analyze
flutter test test/prayer_calendar_helper_test.dart
flutter test test/prayer_calendar_hive_helper_test.dart
flutter test test/umm_al_qura_bundle_service_test.dart
flutter test test/select_location_offline_city_picker_test.dart
flutter test test/hijri_prayer_calendar_window_test.dart
```

Add targeted bundle-refresh tests once the refresh path lands, and run
`dart run tool/background_theme_audit.dart --fail-on-issues` only if the
implementation materially changes themed or background-sensitive surfaces
beyond the schedule UI updates planned here.

## 4. Manual offline walkthrough

1. Launch the app with internet disabled.
2. Open the city picker and confirm every shipped bundle city is selectable.
3. Select a city and verify today's prayer times load from the official offline
   bundle.
4. Restart the app while still offline and verify the city and today's
   schedule persist.
5. Open the prayer calendar and confirm:
   - Hijri year and month navigation are the primary browsing controls
   - dates earlier than today inside the current Hijri year are visible but
     read-only
   - supported future dates remain accessible through the end of the final
     supported Hijri year implied by the five-upcoming-Gregorian-year anchor
   - the first date after the supported final Hijri year shows localized
     out-of-range guidance
6. Edit a supported day override and verify it persists on top of the official
   schedule after reload.
7. Re-import or ship a newer approved bundle revision, reopen the app, and
   verify the selected city plus local overrides remain intact while official
   cached day records refresh to the newer bundle.
