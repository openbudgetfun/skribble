---
title: Testing Widgets
description: Comprehensive guide to testing Skribble widgets, including the pumpApp helper, required test categories, full example test files, and coverage tracking.
---

# Testing Widgets

Every Skribble widget ships with comprehensive widget tests. This guide covers the test structure, the `pumpApp()` helper, required test categories, and how to run and track tests.

## Test file structure

Test files mirror the `lib/src/` directory structure inside `packages/skribble/test/widgets/`:

```
packages/skribble/
  lib/src/
    wired_button.dart
    wired_card.dart
    wired_checkbox.dart
  test/
    helpers/
      pump_app.dart          # shared test helper
    widgets/
      wired_button_test.dart
      wired_card_test.dart
      wired_checkbox_test.dart
```

Every `wired_*.dart` source file must have a corresponding `wired_*_test.dart` test file.

## The pumpApp() helper

<!-- {=docsPumpAppHelper} -->

All widget tests use the `pumpApp()` helper from `test/helpers/pump_app.dart`. It wraps your widget in a `MaterialApp` and `Scaffold`, which is the minimum tree required for Material widgets to function.

### Signature

```dart
Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  ThemeData? theme,
  bool asAppBar = false,
  bool asBottomNav = false,
  bool asDrawer = false,
  Widget? body,
})
```

### Basic usage

Place a widget in the `Scaffold.body` slot (default):

```dart
await pumpApp(tester, WiredButton(
  onPressed: () {},
  child: const Text('Press me'),
));
```

### App bar slot

Use `asAppBar: true` for widgets that implement `PreferredSizeWidget`:

```dart
await pumpApp(
  tester,
  WiredAppBar(title: Text('Title')),
  asAppBar: true,
);
```

### Bottom navigation slot

Use `asBottomNav: true` for bottom navigation widgets:

```dart
await pumpApp(
  tester,
  myBottomNavBar,
  asBottomNav: true,
);
```

### Drawer slot

Use `asDrawer: true` for drawer widgets:

```dart
await pumpApp(
  tester,
  WiredDrawer(child: Text('Menu')),
  asDrawer: true,
);
```

### Custom theme

Pass a `ThemeData` to test under a specific Material theme:

```dart
await pumpApp(
  tester,
  WiredButton(onPressed: () {}, child: const Text('Dark')),
  theme: ThemeData.dark(),
);
```

<!-- {/docsPumpAppHelper} -->

### Testing with WiredTheme

When you need to test how a widget responds to `WiredThemeData`, bypass `pumpApp()` and build the tree manually:

```dart
await tester.pumpWidget(
  MaterialApp(
    home: WiredTheme(
      data: WiredThemeData(borderColor: Colors.red),
      child: Scaffold(
        body: WiredButton(onPressed: () {}, child: const Text('Themed')),
      ),
    ),
  ),
);
```

## Required test categories

Every widget must have at least 6 `testWidgets` calls covering these categories:

### 1. Rendering

Verify the widget renders without throwing and displays its child content:

```dart
testWidgets('renders child text widget', (tester) async {
  await pumpApp(
    tester,
    WiredButton(onPressed: () {}, child: const Text('Press me')),
  );

  expect(find.text('Press me'), findsOneWidget);
});

testWidgets('renders with icon child', (tester) async {
  await pumpApp(
    tester,
    WiredButton(onPressed: () {}, child: const Icon(Icons.add)),
  );

  expect(find.byIcon(Icons.add), findsOneWidget);
});
```

### 2. Dimensions

Verify the widget has the expected size and respects custom dimensions:

```dart
testWidgets('renders with correct height (42.0)', (tester) async {
  await pumpApp(
    tester,
    WiredButton(onPressed: () {}, child: const Text('Height test')),
  );

  final buttonSize = tester.getSize(find.byType(WiredButton));
  expect(buttonSize.height, 42.0);
});
```

### 3. Interaction

Verify the widget responds to taps and calls callbacks:

```dart
testWidgets('calls onPressed callback when tapped', (tester) async {
  var pressed = false;

  await pumpApp(
    tester,
    WiredButton(onPressed: () => pressed = true, child: const Text('Tap')),
  );

  await tester.tap(find.text('Tap'));
  await tester.pump();

  expect(pressed, isTrue);
});
```

### 4. State changes

Verify the widget rebuilds correctly when values change:

```dart
testWidgets('rebuilds when value changes', (tester) async {
  var value = false;

  await pumpApp(
    tester,
    StatefulBuilder(
      builder: (context, setState) {
        return WiredCheckbox(
          value: value,
          onChanged: (v) => setState(() => value = v ?? false),
        );
      },
    ),
  );

  // Tap to toggle
  await tester.tap(find.byType(WiredCheckbox));
  await tester.pump();

  expect(value, isTrue);
});
```

### 5. Edge cases

Test null values, empty content, rapid interactions, and boundary conditions:

```dart
testWidgets('handles null semantic label gracefully', (tester) async {
  await pumpApp(
    tester,
    WiredButton(
      onPressed: () {},
      semanticLabel: null,
      child: const Text('No label'),
    ),
  );

  expect(find.byType(WiredButton), findsOneWidget);
});

testWidgets('handles rapid taps without error', (tester) async {
  var tapCount = 0;

  await pumpApp(
    tester,
    WiredButton(
      onPressed: () => tapCount++,
      child: const Text('Rapid'),
    ),
  );

  for (var i = 0; i < 10; i++) {
    await tester.tap(find.text('Rapid'));
  }
  await tester.pump();

  expect(tapCount, 10);
});
```

### 6. Accessibility

Verify semantic labels are applied and the widget tree has correct semantics:

```dart
testWidgets('applies semantic label when provided', (tester) async {
  await pumpApp(
    tester,
    WiredButton(
      onPressed: () {},
      semanticLabel: 'Submit form',
      child: const Text('Submit'),
    ),
  );

  expect(find.bySemanticsLabel('Submit form'), findsOneWidget);
});
```

### 7. Internal structure (recommended)

Verify the widget contains expected internal widgets like `RepaintBoundary`, `TextButton`, etc.:

```dart
testWidgets('has RepaintBoundary wrapper', (tester) async {
  await pumpApp(
    tester,
    WiredButton(onPressed: () {}, child: const Text('Repaint')),
  );

  expect(
    find.descendant(
      of: find.byType(WiredButton),
      matching: find.byType(RepaintBoundary),
    ),
    findsOneWidget,
  );
});

testWidgets('contains TextButton internally', (tester) async {
  await pumpApp(
    tester,
    WiredButton(onPressed: () {}, child: const Text('Button')),
  );

  expect(
    find.descendant(
      of: find.byType(WiredButton),
      matching: find.byType(TextButton),
    ),
    findsOneWidget,
  );
});
```

## Full example test file

Here is a complete test file for `WiredButton`, showing all required categories:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredButton', () {
    // -- Rendering --

    testWidgets('renders child text widget', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Press me')),
      );

      expect(find.text('Press me'), findsOneWidget);
    });

    testWidgets('renders with icon child', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Icon(Icons.add)),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    // -- Dimensions --

    testWidgets('renders with correct height (42.0)', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Height test')),
      );

      final buttonSize = tester.getSize(find.byType(WiredButton));
      expect(buttonSize.height, 42.0);
    });

    // -- Interaction --

    testWidgets('calls onPressed callback when tapped', (tester) async {
      var pressed = false;

      await pumpApp(
        tester,
        WiredButton(
          onPressed: () => pressed = true,
          child: const Text('Tap'),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    // -- Internal structure --

    testWidgets('contains TextButton internally', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Button')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredButton),
          matching: find.byType(TextButton),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredButton(onPressed: () {}, child: const Text('Repaint')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredButton),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    // -- Theme --

    testWidgets('uses theme border color from WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.red),
            child: Scaffold(
              body: WiredButton(
                onPressed: () {},
                child: const Text('Themed'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(WiredButton), findsOneWidget);
    });

    // -- Accessibility --

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredButton(
          onPressed: () {},
          semanticLabel: 'Submit form',
          child: const Text('Submit'),
        ),
      );

      expect(find.bySemanticsLabel('Submit form'), findsOneWidget);
    });
  });
}
```

## Running tests

### All packages

```bash
melos run flutter-test
```

### Single package

```bash
cd packages/skribble
flutter test
```

### Single test file

```bash
cd packages/skribble
flutter test test/widgets/wired_button_test.dart
```

### With verbose output

```bash
cd packages/skribble
flutter test --reporter expanded
```

## Coverage tracking

Generate a coverage report for the skribble package:

```bash
cd packages/skribble
flutter test --coverage
```

This writes `coverage/lcov.info`. View it with `lcov` or `genhtml`:

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Coverage expectations

Every widget should have:

- At least 6 `testWidgets` per widget class
- Tests for all public constructor parameters
- Tests for callback invocations
- Tests for theme integration
- Tests for semantic labels

## Common patterns

### Testing hover/focus states

```dart
testWidgets('shows focus ring on focus', (tester) async {
  await pumpApp(
    tester,
    WiredButton(onPressed: () {}, child: const Text('Focus')),
  );

  // Focus the button
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pump();

  expect(find.byType(WiredButton), findsOneWidget);
});
```

### Testing with async callbacks

```dart
testWidgets('handles async onPressed', (tester) async {
  var completed = false;

  await pumpApp(
    tester,
    WiredButton(
      onPressed: () async {
        await Future<void>.delayed(Duration.zero);
        completed = true;
      },
      child: const Text('Async'),
    ),
  );

  await tester.tap(find.text('Async'));
  await tester.pump();

  expect(completed, isTrue);
});
```

### Testing value-driven widgets

```dart
testWidgets('slider updates value on drag', (tester) async {
  double value = 0.5;

  await pumpApp(
    tester,
    StatefulBuilder(
      builder: (context, setState) {
        return WiredSlider(
          value: value,
          onChanged: (v) => setState(() => value = v),
        );
      },
    ),
  );

  // Drag the slider
  final slider = find.byType(WiredSlider);
  await tester.drag(slider, const Offset(100, 0));
  await tester.pump();

  expect(value, isNot(0.5));
});
```

## Analyze before committing

Always run analysis before committing test changes:

```bash
melos run analyze
dart analyze --fatal-infos .
```
