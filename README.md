# JourneyJoy

Offline-first travel planner for trips, expenses, flights, activities, packing, and itinerary planning.

## Sitemap Coverage (complete)

| Screen               | Status |
|----------------------|--------|
| Splash               | ✅     |
| Welcome              | ✅     |
| Register             | ✅     |
| Login                | ✅     |
| Home                 | ✅     |
| Add Trip             | ✅     |
| Trip Detail          | ✅     |
| Expenses             | ✅     |
| Flights              | ✅     |
| Activities           | ✅     |
| Documents            | ✅     |
| Itinerary            | ✅     |
| Trip Report          | ✅     |
| Packing              | ✅     |
| Settings             | ✅     |

## QA Status

- **`flutter analyze`** — passes with no issues.
- **`flutter test`** — 51 tests, all pass.
- **Test file**: `test/qa_test.dart` covers providers, screens, currency formatting, and full-flow integration.

## Remaining Notes

- Splash screen test is skipped — requires `Firebase.initializeApp()` in test env (Firebase Auth).
- App launch integration test is skipped for the same reason.
- Firebase mocks (`firebase_core_platform_interface`) are wired for `AuthProvider`-dependent widget tests.
- 3 uncommitted commits ahead of `origin/main`.
