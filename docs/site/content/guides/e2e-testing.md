---
title: E2E Testing
description: Widget tests, integration tests, and Patrol tests across the Skribble workspace and storybook.
---

# E2E Testing

Skribble's testing strategy has three tiers, all runnable from the workspace:

## Tier 1 — Widget tests (unit-level, fast)

Every Wired widget has a widget-test suite in
`packages/skribble/test/widgets/`, mirroring `lib/src/` layout. They cover
rendering, interaction, state changes, edge cases, and Semantics. These run
purely on the Dart VM through `flutter test`:

```bash
cd packages/skribble && flutter test
```

## Tier 2 — Patrol + integration tests (storybook journeys)

The storybook app carries real-journey tests in
`apps/skribble_storybook/integration_test/`:

- `patrol_test.dart` — `patrolTest` harness flows (category navigation,
  component discovery)
- `journey_test.dart` — cross-page journeys including the icons gallery,
  emoji catalog, font specimen, and the long-tail widgets from the parity
  batches
- `navigation_test.dart` — plain integration navigation regression
- `screenshots_test.dart` — the screenshot capture pipeline

### Running as widget tests (no device needed)

Patrol tests compile under the standard widget-test binding, so the whole
suite can run on the host:

```bash
cd apps/skribble_storybook
flutter test integration_test/   # or a single file
```

### Running on a real device (Patrol)

With the native runner configured (Android `MainActivityTest` + iOS
dev signing), run the suite on a phone or emulator:

```bash
cd apps/skribble_storybook
patrol test -d <device-id>          # native runner: full Patrol features
flutter test integration_test/ -d <device-id>   # integration-test runner
```

Discover device IDs with `flutter devices`. The `patrol:` block in
`apps/skribble_storybook/pubspec.yaml` configures the test directory
(`integration_test`) and the Android package name.

## Tier 3 — CI

GitHub Actions run Tiers 1 and 2 (no device) on every PR; the device tier is
run by maintainers on phones/emulators before releases to validate
real-environment behaviour.

## Notes

- The Patrol native Android runner (`androidTest` orchestrator files) is a
  documented next step: `flutter create . --platforms android` in the
  storybook, then follow
  [Patrol's Android setup](https://patrol.leancode.co/documentation#android-setup).
- Nightly full-suite runs use `melos run flutter-test` + the storybook
  integration suites.
