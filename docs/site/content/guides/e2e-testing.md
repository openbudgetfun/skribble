---
title: End-to-End Testing
description: Run Storybook journeys in a real browser, on Android, and in an iOS simulator.
---

# End-to-End Testing

The storybook uses Patrol for real-browser interaction tests. Run from the repository root:

```bash
devenv shell
cd apps/skribble_storybook
dart pub global activate patrol_cli 4.7.0
dart pub global run patrol_cli:main test --device chrome \
  --target integration_test/quality_test.dart --web-headless \
  --web-screenshot on --web-trace retain-on-failure --web-workers 1
```

Use the workspace Flutter/Dart SDK. Patrol CLI 4.7.0 is paired with the storybook's Patrol 4.9.0 dependency. Chrome/Chromium must be available; the CLI installs its Playwright harness. Run `patrol test`, not `flutter test`, for tests that use Patrol's platform automation.

The notebook journeys resize the real browser to 390, 820, and 1,440 pixels, type accented text and currency, save a note, mark a task, reset external state, switch between morning and evening palettes, and toggle reminders. Shared keys live in `lib/testing/quality_keys.dart`. New tests use those keys rather than coordinates or fragile text selectors.

Reports are written to `playwright-report/` and screenshots to `test-results/`. CI uploads them even after failures; traces are retained for failing journeys. View the actual screenshot before treating a test as visual evidence. A passing interaction test alone does not prove a font loaded or a border looks good.

Run the original catalog journeys separately with `--target integration_test/patrol_test.dart`. Widget tests cover more states cheaply, including long labels, narrow layouts, font inheritance, 300% text scaling, theme changes, and deterministic pixel rendering. See [Testing](testing) and [Screenshots](screenshots).

These commands exercise Flutter web in Chromium. Run the native journey below for Android and iOS coverage. Patrol's current web documentation is at [Patrol web testing](https://patrol.leancode.co/documentation/web). The `test:all` command runs Flutter packages sequentially with four test workers per package. This keeps large generated catalogs and timing checks from competing across packages on CI runners.

Chromium CI installs Playwright 1.56.0's Linux system libraries with `install --with-deps`, matching Patrol 4.9.0's web runner. The browser process runs in the host shell with the pinned Flutter SDK and Node 22, so Ubuntu's browser libraries are visible. Patrol's automatic browser download alone does not install those libraries.

CI enables Patrol's verbose output and HTML, JSON, and list reporters. Verbose output exposes Playwright startup errors that otherwise appear only as an exit code before any tests or report files exist.

The CI browser uses `--web-locale en-GB`. An unspecified Linux runner locale can produce an invalid browser language and stop Flutter's `parseBrowserLanguages` before test discovery. Set the browser locale explicitly when reproducing CI runs.

The root Ink style control exercises Gentle, Playful, and Expressive across fonts and borders. The quality journeys switch all three levels while preserving entered text, then navigate to another category to verify the app-level selection follows the route. Run both `quality_test.dart` and `patrol_test.dart` for the complete set of 18 browser journeys.

CI allows `--web-server-timeout 300` for the initial Flutter compilation. This changes only server startup allowance, not individual journey deadlines or assertions; the larger catalog can exceed the CLI's two-minute startup default on a busy machine.

## Native charts and maps

The Storybook includes Android and iOS runners. Use an attached Android device or a booted iOS simulator, and find its identifier with `flutter devices`. The iOS runner requires Xcode, CocoaPods, and iOS 15 or later. Maps require internet access to load their styles, fonts, and tiles.

From `apps/skribble_storybook` inside `devenv shell`, run the actual Storybook journey with Flutter's `integration_test` driver:

```bash
SKRIBBLE_DEVICE_LABEL=android flutter drive --profile --no-dds \
  --driver=test_driver/charts_device_test.dart \
  --target=integration_test/charts_device_test.dart --device-id=<android-device-id>

SKRIBBLE_DEVICE_LABEL=ios flutter drive \
  --driver=test_driver/charts_device_test.dart \
  --target=integration_test/charts_device_test.dart --device-id=<ios-simulator-id>
```

The journey starts at the catalog and exercises crosshair selection, pan, pinch zoom, all four chart styles, night mode, drawing edits, and workspace restoration. It then waits for MapLibre's tiles and transitions to finish, selects markers, changes location, zooms, and changes the map palette. It uses portrait orientation during the test and releases that preference afterward. Leave `STORYBOOK_ROUTE` unset so the navigation assertions run from the catalog.

The host driver saves screenshots under `.screenshots/charts/` and `.screenshots/maps/` at the repository root. It also saves frame timings in `.screenshots/charts/<device-label>-performance.json`, including when a later assertion fails. Use `--no-dds` on Android so the performance recorder can reach the device's VM service. Inspect the screenshots and test result together before reporting a successful native run. Android profile timings measure an attached device; iOS simulator debug timings are useful for diagnosis and do not establish physical-device performance.
