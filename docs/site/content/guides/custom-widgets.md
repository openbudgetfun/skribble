---
title: Build a Custom Widget
description: Step-by-step guide to building a new Skribble widget from scratch, including theming, accessibility, repaint isolation, and comprehensive tests.
---

# Build a Custom Widget

This guide walks through building a complete Skribble widget from file creation to storybook integration. Every Skribble widget follows the same pattern: extend `HookWidget`, read the theme, use rough decorations, wrap with `buildWiredElement()`, and ship with tests.

## Prerequisites

Before you start, make sure you have the workspace set up:

```bash
git clone https://github.com/openbudgetfun/skribble.git
cd skribble
devenv shell
melos bootstrap
```

## Step 1: Create the widget file

All widgets live in `packages/skribble/lib/src/`. Create a new file following the `wired_` prefix convention:

```
packages/skribble/lib/src/wired_info_box.dart
```

## Step 2: Extend HookWidget

Every Skribble widget uses `HookWidget` from the `flutter_hooks` package. Never use `StatefulWidget` or `StatelessWidget`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn information box with a sketchy rectangle border.
///
/// Reads colors from the nearest [WiredTheme] ancestor, falling back
/// to the default constants when no theme is provided.
class WiredInfoBox extends HookWidget {
  /// The content displayed inside the box.
  final Widget child;

  /// Whether to show a hachure fill pattern.
  final bool fill;

  /// Optional height override. Defaults to null (intrinsic sizing).
  final double? height;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const WiredInfoBox({
    super.key,
    required this.child,
    this.fill = false,
    this.height,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Step 3: Read theme
    // Step 4: Use RoughBoxDecoration
    // Step 5: Wrap with buildWiredElement()
    // Step 6: Add semantics
    throw UnimplementedError();
  }
}
```

The `const` constructor with `super.key` is required. Document every parameter with a doc comment.

## Step 3: Read the theme

Every widget reads its colors and configuration from `WiredTheme.of(context)`. This returns a `WiredThemeData` that contains `borderColor`, `textColor`, `fillColor`, `strokeWidth`, and `roughness`.

```dart
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  // theme.borderColor -- sketchy border stroke color
  // theme.textColor   -- label/content text color
  // theme.fillColor   -- background fill color
  // theme.strokeWidth -- border stroke width
  // theme.roughness   -- how wobbly lines are
  // theme.drawConfig  -- DrawConfig for the rough engine
}
```

When no `WiredTheme` ancestor exists, `WiredTheme.of(context)` falls back to `WiredThemeData.defaultTheme`, so widgets always have valid values.

## Step 4: Use RoughBoxDecoration

Replace standard `BoxDecoration` with `RoughBoxDecoration` to get sketchy borders. Available shapes are `rectangle`, `roundedRectangle`, `circle`, and `ellipse`.

```dart
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  return Container(
    height: height,
    padding: const EdgeInsets.all(12),
    decoration: RoughBoxDecoration(
      shape: RoughBoxShape.rectangle,
      borderStyle: RoughDrawingStyle(
        width: theme.strokeWidth,
        color: theme.borderColor,
      ),
      fillStyle: RoughDrawingStyle(
        width: 1,
        color: theme.fillColor,
      ),
      filler: fill
          ? HachureFiller(FillerConfig.defaultConfig)
          : NoFiller(),
    ),
    child: DefaultTextStyle(
      style: TextStyle(color: theme.textColor),
      child: child,
    ),
  );
}
```

## Step 5: Wrap with buildWiredElement()

The `buildWiredElement()` function wraps your widget tree in a `RepaintBoundary`. This isolates repaint operations so that when the rough engine redraws, it does not trigger repaints in unrelated parts of the tree.

```dart
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  return buildWiredElement(
    child: Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: RoughBoxDecoration(
        shape: RoughBoxShape.rectangle,
        borderStyle: RoughDrawingStyle(
          width: theme.strokeWidth,
          color: theme.borderColor,
        ),
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: theme.textColor),
        child: child,
      ),
    ),
  );
}
```

The `buildWiredElement()` top-level function is defined in `wired_base.dart`. There is also a `WiredBaseWidget` abstract class and a `WiredRepaintMixin` for more advanced use cases, but most widgets use the simple function form.

## Step 6: Add semanticLabel for accessibility

Wrap the outermost widget in `Semantics` when a `semanticLabel` is provided:

```dart
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  return Semantics(
    label: semanticLabel,
    child: buildWiredElement(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(12),
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.rectangle,
          borderStyle: RoughDrawingStyle(
            width: theme.strokeWidth,
            color: theme.borderColor,
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: theme.textColor),
          child: child,
        ),
      ),
    ),
  );
}
```

For interactive widgets like buttons, also set `button: true` on the `Semantics` widget:

```dart
Semantics(
  label: semanticLabel,
  button: true,
  child: buildWiredElement(child: ...),
);
```

## Step 7: Export from skribble.dart

Add your widget to the barrel export file at `packages/skribble/lib/skribble.dart`. Keep the list in alphabetical order:

```dart
export 'src/wired_icon.dart';
export 'src/wired_icon_button.dart';
export 'src/wired_info_box.dart';   // <-- add this line
export 'src/wired_input.dart';
export 'src/wired_input_chip.dart';
```

## Step 8: Add tests

Create a test file at `packages/skribble/test/widgets/wired_info_box_test.dart`. Every widget needs at least 6 `testWidgets` calls covering rendering, interaction, state, edge cases, and accessibility.

Use the `pumpApp()` helper from `test/helpers/pump_app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('WiredInfoBox', () {
    testWidgets('renders child text widget', (tester) async {
      await pumpApp(
        tester,
        WiredInfoBox(child: const Text('Hello')),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders without error when fill is true', (tester) async {
      await pumpApp(
        tester,
        WiredInfoBox(fill: true, child: const Text('Filled')),
      );

      expect(find.byType(WiredInfoBox), findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      await pumpApp(
        tester,
        WiredInfoBox(height: 200, child: const Text('Tall')),
      );

      final size = tester.getSize(find.byType(WiredInfoBox));
      expect(size.height, 200);
    });

    testWidgets('has RepaintBoundary wrapper', (tester) async {
      await pumpApp(
        tester,
        WiredInfoBox(child: const Text('Repaint')),
      );

      expect(
        find.descendant(
          of: find.byType(WiredInfoBox),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses theme border color from WiredTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WiredTheme(
            data: WiredThemeData(borderColor: Colors.red),
            child: Scaffold(
              body: WiredInfoBox(child: const Text('Themed')),
            ),
          ),
        ),
      );

      expect(find.byType(WiredInfoBox), findsOneWidget);
    });

    testWidgets('applies semantic label when provided', (tester) async {
      await pumpApp(
        tester,
        WiredInfoBox(
          semanticLabel: 'Information panel',
          child: const Text('Info'),
        ),
      );

      expect(find.bySemanticsLabel('Information panel'), findsOneWidget);
    });

    testWidgets('renders with null height (intrinsic)', (tester) async {
      await pumpApp(
        tester,
        WiredInfoBox(height: null, child: const Text('Intrinsic')),
      );

      expect(find.byType(WiredInfoBox), findsOneWidget);
    });

    testWidgets('renders with complex child widget', (tester) async {
      await pumpApp(
        tester,
        WiredInfoBox(
          child: Column(
            children: [
              const Text('Title'),
              const SizedBox(height: 8),
              const Text('Subtitle'),
            ],
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
    });
  });
}
```

Run the tests:

```bash
melos run flutter-test
```

Or for just the skribble package:

```bash
cd packages/skribble
flutter test
```

## Step 9: Add to the storybook

Create or update a storybook page in `apps/skribble_storybook/` to showcase the new widget. The storybook app is the live demo surface for all Skribble widgets.

## Step 10: Full working example

Here is the complete `wired_info_box.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn information box with a sketchy rectangle border.
///
/// Reads colors from the nearest [WiredTheme] ancestor, falling back
/// to the default constants when no theme is provided.
class WiredInfoBox extends HookWidget {
  /// The content displayed inside the box.
  final Widget child;

  /// Whether to show a hachure fill pattern.
  final bool fill;

  /// Optional height override. Defaults to null (intrinsic sizing).
  final double? height;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const WiredInfoBox({
    super.key,
    required this.child,
    this.fill = false,
    this.height,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return Semantics(
      label: semanticLabel,
      child: buildWiredElement(
        child: Container(
          height: height,
          padding: const EdgeInsets.all(12),
          decoration: RoughBoxDecoration(
            shape: RoughBoxShape.rectangle,
            borderStyle: RoughDrawingStyle(
              width: theme.strokeWidth,
              color: theme.borderColor,
            ),
            fillStyle: RoughDrawingStyle(
              width: 1,
              color: theme.fillColor,
            ),
            filler: fill
                ? HachureFiller(FillerConfig.defaultConfig)
                : NoFiller(),
          ),
          child: DefaultTextStyle(
            style: TextStyle(color: theme.textColor),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

## Checklist

Before submitting your widget:

- [ ] File created at `packages/skribble/lib/src/wired_<name>.dart`
- [ ] Widget extends `HookWidget` (not `StatefulWidget`)
- [ ] Theme read via `WiredTheme.of(context)`
- [ ] `RoughBoxDecoration` used for sketchy borders
- [ ] `buildWiredElement()` wraps the tree for repaint isolation
- [ ] `semanticLabel` parameter and `Semantics` wrapper included
- [ ] Exported from `packages/skribble/lib/skribble.dart`
- [ ] Test file at `packages/skribble/test/widgets/wired_<name>_test.dart`
- [ ] At least 6 `testWidgets` covering rendering, dimensions, theme, repaint boundary, accessibility, edge cases
- [ ] `melos run analyze` passes
- [ ] `melos run flutter-test` passes
- [ ] `melos run format` produces no changes
