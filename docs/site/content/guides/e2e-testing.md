---
title: End-to-End Testing
description: Run the Skribble notebook through Patrol in a real browser, with screenshots and traces.
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

These commands exercise Flutter web in Chromium. Native Android and iOS testing requires configured runners and devices; browser coverage must not be reported as native-device coverage. Patrol's current web documentation is at [Patrol web testing](https://patrol.leancode.co/documentation/web). The `test:all` command runs Flutter packages sequentially with four test workers per package. This keeps large generated catalogs and timing checks from competing across packages on CI runners.

Chromium CI installs Playwright 1.56.0's Linux system libraries with `install --with-deps`, matching Patrol 4.9.0's web runner. The browser process runs in the host shell with the pinned Flutter SDK and Node 22, so Ubuntu's browser libraries are visible. Patrol's automatic browser download alone does not install those libraries.

CI enables Patrol's verbose output and HTML, JSON, and list reporters. Verbose output exposes Playwright startup errors that otherwise appear only as an exit code before any tests or report files exist.

The CI browser uses `--web-locale en-GB`. An unspecified Linux runner locale can produce an invalid browser language and stop Flutter's `parseBrowserLanguages` before test discovery. Set the browser locale explicitly when reproducing CI runs.

The root Ink style control exercises Gentle, Playful, and Expressive across fonts and borders. The quality journeys switch all three levels while preserving entered text, then navigate to another category to verify the app-level selection follows the route. Run both `quality_test.dart` and `patrol_test.dart` for the complete set of 18 browser journeys.

CI allows `--web-server-timeout 300` for the initial Flutter compilation. This changes only server startup allowance, not individual journey deadlines or assertions; the larger catalog can exceed the CLI's two-minute startup default on a busy machine.
