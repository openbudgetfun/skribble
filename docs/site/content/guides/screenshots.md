---
title: Screenshots
description: How Skribble captures widget screenshots via integration tests, organized by category, validated in CI, and compared against baselines.
---

# Screenshots

Skribble uses integration tests to capture screenshots of every widget in the storybook app. These screenshots serve as visual documentation and regression baselines.

## Where screenshots are saved

Screenshots are saved to the `.screenshots/` directory at the repository root. This directory is gitignored -- screenshots are generated locally and in CI, never committed to the repository.

```
.screenshots/
  home/
    home.png
  buttons/
    buttons.png
    wired-button.png
    wired-elevated-button.png
    wired-outlined-button.png
    wired-text-button.png
    wired-icon.png
    wired-icon-button.png
    wired-fab.png
  inputs/
    inputs.png
    wired-input.png
    wired-text-area.png
  selection/
    wired-checkbox.png
    wired-radio.png
    wired-switch.png
```

## Directory organization

Screenshots are organized by widget category. Each category gets its own subdirectory:

```
.screenshots/<category>/<widget>.png
```

The category matches the storybook navigation structure (Buttons, Inputs, Selection, Layout, Navigation, Feedback, etc.). Each category has a page-level screenshot (e.g., `buttons/buttons.png`) and individual widget screenshots (e.g., `buttons/wired-button.png`).

## The integration test

Screenshot capture is driven by the integration test at:

```
apps/skribble_storybook/integration_test/screenshots_test.dart
```

### Test structure

The test file defines a `WidgetShot` class that pairs a screenshot name with a text anchor used to scroll the storybook to the right widget:

```dart
class WidgetShot {
  final String name;
  final String anchor;

  const WidgetShot({required this.name, required this.anchor});
}
```

### Core helper functions

The test defines several helpers:

**`pumpStorybook()`** -- pumps the full storybook app wrapped in a `RepaintBoundary` for screenshot capture:

```dart
Future<void> pumpStorybook(WidgetTester tester) async {
  await tester.pumpWidget(
    RepaintBoundary(
      key: captureBoundaryKey,
      child: const SkribbleStorybookApp(),
    ),
  );
  await tester.pumpAndSettle();
}
```

**`takeScreenshot()`** -- captures the current screen to a PNG file. It first tries the `IntegrationTestWidgetsFlutterBinding.takeScreenshot()` method, then falls back to rendering the `RepaintBoundary` directly:

```dart
Future<void> takeScreenshot(WidgetTester tester, String name) async {
  final dir = Directory('$screenshotsDir/${name.split('/').first}');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  // Try platform screenshot first, fall back to boundary capture
  final screenshotFile = File('$screenshotsDir/$name.png');
  // ...
}
```

**`focusOnText()`** -- scrolls the storybook page until a specific text widget is visible. This handles the case where a widget is below the fold:

```dart
Future<void> focusOnText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  if (finder.evaluate().isEmpty) {
    // Find the largest scrollable and scroll until text appears
    // ...
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}
```

**`capturePageAndWidgets()`** -- the high-level function that navigates to a category, captures the page screenshot, then captures each individual widget:

```dart
Future<void> capturePageAndWidgets(
  WidgetTester tester, {
  required String category,
  required String pageShot,
  required List<WidgetShot> widgetShots,
}) async {
  await pumpStorybook(tester);
  await openCategory(tester, category);
  await takeScreenshot(tester, pageShot);

  for (final widgetShot in widgetShots) {
    await focusOnText(tester, widgetShot.anchor);
    await takeScreenshot(tester, widgetShot.name);
  }
}
```

### Example test case

A typical screenshot test group looks like this:

```dart
testWidgets('capture buttons page and widgets', (tester) async {
  await capturePageAndWidgets(
    tester,
    category: 'Buttons',
    pageShot: 'buttons/buttons',
    widgetShots: const [
      WidgetShot(name: 'buttons/wired-button', anchor: 'WiredButton'),
      WidgetShot(
        name: 'buttons/wired-elevated-button',
        anchor: 'WiredElevatedButton',
      ),
      WidgetShot(
        name: 'buttons/wired-outlined-button',
        anchor: 'WiredOutlinedButton',
      ),
      WidgetShot(
        name: 'buttons/wired-text-button',
        anchor: 'WiredTextButton',
      ),
      WidgetShot(name: 'buttons/wired-icon', anchor: 'WiredIcon'),
      WidgetShot(
        name: 'buttons/wired-icon-button',
        anchor: 'WiredIconButton',
      ),
      WidgetShot(name: 'buttons/wired-fab', anchor: 'WiredFab'),
    ],
  );
});
```

## Running screenshot capture

### Via Melos

From the repository root:

```bash
melos run screenshot
```

This runs the integration test against the storybook app and writes all screenshots to `.screenshots/`.

### Manually

```bash
cd apps/skribble_storybook
flutter test integration_test/screenshots_test.dart
```

### On a specific device

```bash
cd apps/skribble_storybook
flutter test integration_test/screenshots_test.dart -d macos
flutter test integration_test/screenshots_test.dart -d chrome
flutter test integration_test/screenshots_test.dart -d linux
```

The screenshot fallback mechanism (rendering the `RepaintBoundary` to an image) works on all platforms, even when the platform-specific screenshot plugin is unavailable.

## Adding new screenshots

To capture screenshots for a new widget, add entries to the existing test group or create a new group in `screenshots_test.dart`.

### Step 1: Add the widget to the storybook

Make sure your widget appears on a storybook page with a visible text label that can serve as an anchor. The anchor text is what `focusOnText()` searches for.

### Step 2: Add WidgetShot entries

If the widget belongs to an existing category, add `WidgetShot` entries to the corresponding `capturePageAndWidgets()` call:

```dart
testWidgets('capture inputs page and widgets', (tester) async {
  await capturePageAndWidgets(
    tester,
    category: 'Inputs',
    pageShot: 'inputs/inputs',
    widgetShots: const [
      WidgetShot(name: 'inputs/wired-input', anchor: 'WiredInput'),
      WidgetShot(name: 'inputs/wired-text-area', anchor: 'WiredTextArea'),
      // Add your new widget:
      WidgetShot(name: 'inputs/wired-search-bar', anchor: 'WiredSearchBar'),
    ],
  );
});
```

### Step 3: Create a new category (if needed)

For a new category, add a new `testWidgets` block:

```dart
testWidgets('capture my-category page and widgets', (tester) async {
  await capturePageAndWidgets(
    tester,
    category: 'My Category',
    pageShot: 'my-category/my-category',
    widgetShots: const [
      WidgetShot(name: 'my-category/wired-new-widget', anchor: 'WiredNewWidget'),
    ],
  );
});
```

### Step 4: Run and verify

```bash
melos run screenshot
```

Check that the new PNG files appear in `.screenshots/` with the expected names and content.

## Screenshot capture flow

1. The integration test initializes `IntegrationTestWidgetsFlutterBinding`
2. Google Fonts runtime fetching is disabled (fonts are bundled)
3. The full `SkribbleStorybookApp` is pumped inside a `RepaintBoundary`
4. For each category:
   a. Navigate to the category page in the storybook
   b. Capture the full-page screenshot
   c. For each widget, scroll to its anchor text and capture
5. Screenshots are written as PNG files to `.screenshots/<category>/<name>.png`

## Baseline comparison in CI

CI can compare screenshots against committed baselines to detect visual regressions. The workflow typically:

1. Captures screenshots on a fixed platform and screen size
2. Compares pixel data against baseline images
3. Fails the build if differences exceed a threshold

Because `.screenshots/` is gitignored, baseline images for CI are stored separately (typically uploaded as artifacts or committed to a dedicated branch).

## Troubleshooting

### Screenshot shows blank white image

The storybook app may not have fully settled. Make sure `pumpAndSettle()` completes before taking the screenshot. If animations are infinite, use `pump(Duration)` with a specific duration instead.

### MissingPluginException

This occurs when the platform-specific screenshot plugin is not available. The test automatically falls back to the `RepaintBoundary` capture method, so this is handled transparently.

### Widget not found by anchor text

The `focusOnText()` helper scrolls to find the text. If the text does not exist on the current page, the test fails with a descriptive error. Make sure the anchor text exactly matches a visible text widget on the storybook page.
