---
title: Agents
description: Comprehensive guide for AI agents working with the Skribble design system — conventions, patterns, workflows, and rules.
---

This document is the authoritative reference for AI coding agents (Claude, Copilot, Cursor, etc.) working in the Skribble codebase. It covers every convention, pattern, constraint, and workflow an agent must follow to produce correct, mergeable contributions.

## Golden rules

1. **UI components use `HookWidget`.** Use `HookConsumerWidget` when Riverpod is needed. The motion layer uses standard Flutter state, ticker providers, and inherited scopes; see [Ink motion](../core/motion) when changing animation ownership or policy.
2. **Every widget name starts with `Wired`.** `WiredButton`, `WiredAppBar`, `WiredDatePicker` — no exceptions.
3. **Every widget reads theme from `WiredTheme.of(context)`.** Never hardcode colors, stroke widths, or roughness values.
4. **Every widget wraps its output with `RepaintBoundary`.** Use `buildWiredElement(child: ...)` or extend `WiredBaseWidget`.
5. **Every widget has 6+ tests.** Covering rendering, dimensions, interaction, state, edge cases, and accessibility.
6. **Documentation must be updated when APIs change or features are added.** This includes the docs site content, dartdoc comments, and MDT template blocks.

## Project structure

```
skribble/
├── packages/skribble/              # Main UI component library
│   ├── lib/
│   │   ├── skribble.dart           # Public barrel export (add new widgets here)
│   │   └── src/
│   │       ├── canvas/             # WiredCanvas, WiredPainter, WiredPainterBase
│   │       ├── rough/              # Rough drawing engine (Dart port of rough.js)
│   │       ├── generated/          # Generated icon font + map files
│   │       ├── wired_*.dart        # Widget implementations
│   │       ├── wired_theme.dart    # WiredThemeData + WiredTheme inherited scope
│   │       ├── wired_material_app.dart  # Material app bridge
│   │       └── wired_base.dart     # Base painters + RepaintBoundary helpers
│   ├── test/
│   │   ├── rough/                  # Rough engine unit tests
│   │   ├── widgets/                # Widget tests (one file per widget)
│   │   └── helpers/pump_app.dart   # Test helper
│   └── tool/                       # Icon generation CLI
├── packages/skribble_lints/        # Shared lint rules (very_good_analysis based)
├── packages/skribble_icons_custom/ # Custom SVG-based icon package example
├── apps/skribble_storybook/        # Interactive demo app
│   ├── lib/pages/                  # Storybook category pages
│   └── integration_test/           # Screenshot capture tests
└── docs/site/                      # This documentation site (Flutter)
```

## Creating a new widget — step by step

This is the most common task an agent will perform. Follow every step exactly.

### Step 1: Create the widget file

Create `packages/skribble/lib/src/wired_<name>.dart`:

<!-- {=docsAgentWidgetTemplate} -->

Use this template for ordinary UI components. For motion lifecycle wrappers, use standard Flutter state and ticker providers as described in the ink motion guide. Borrowed `Animation<double>` values remain owned by the consumer.

```dart
// Static example: pseudocode
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn <description> widget.
///
/// Reads colors from the nearest [WiredTheme] ancestor, falling back
/// to default constants when no theme is provided.
class Wired<Name> extends HookWidget {
  /// The widget content.
  final Widget child;

  /// Called when the widget is tapped.
  final VoidCallback? onPressed;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const Wired<Name>({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return Semantics(
      label: semanticLabel,
      child: buildWiredElement(
        child: Container(
          decoration: RoughBoxDecoration(
            shape: RoughBoxShape.rectangle,
            borderStyle: RoughDrawingStyle(
              width: theme.strokeWidth,
              color: theme.borderColor,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

<!-- {/docsAgentWidgetTemplate} -->

### Step 2: Export from the barrel file

Add one line to `packages/skribble/lib/skribble.dart`:

```dart
// Static example: api
export 'src/wired_<name>.dart';
```

Keep the exports in alphabetical order.

### Step 3: Write tests

Create `packages/skribble/test/widgets/wired_<name>_test.dart`:

<!-- {=docsAgentTestTemplate} -->

```dart
// Static example: test
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import '../helpers/pump_app.dart';

void main() {
  group('Wired<Name>', () {
    testWidgets('renders without error', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Test'), onPressed: () {}),
      );
      expect(find.byType(Wired<Name>), findsOneWidget);
    });

    testWidgets('renders child content', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Hello'), onPressed: () {}),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('has correct default height', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Test'), onPressed: () {}),
      );
      final size = tester.getSize(find.byType(Wired<Name>));
      expect(size.height, greaterThan(0));
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Tap'), onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(Wired<Name>));
      expect(tapped, isTrue);
    });

    testWidgets('rebuilds with new child', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Before'), onPressed: () {}),
      );
      expect(find.text('Before'), findsOneWidget);

      await pumpApp(
        tester,
        Wired<Name>(child: Text('After'), onPressed: () {}),
      );
      expect(find.text('After'), findsOneWidget);
    });

    testWidgets('handles rapid taps', (tester) async {
      var count = 0;
      await pumpApp(
        tester,
        Wired<Name>(child: Text('Rapid'), onPressed: () => count++),
      );
      await tester.tap(find.byType(Wired<Name>));
      await tester.tap(find.byType(Wired<Name>));
      await tester.tap(find.byType(Wired<Name>));
      expect(count, 3);
    });

    testWidgets('applies semantic label', (tester) async {
      await pumpApp(
        tester,
        Wired<Name>(
          child: Text('Label'),
          onPressed: () {},
          semanticLabel: 'My widget',
        ),
      );
      expect(
        tester.getSemantics(find.byType(Wired<Name>)),
        matchesSemantics(label: 'My widget'),
      );
    });
  });
}
```

<!-- {/docsAgentTestTemplate} -->

### Step 4: Add to the storybook

Add a showcase entry in the appropriate page under `apps/skribble_storybook/lib/pages/`. For example, if it's a button, add to `buttons_page.dart`.

### Step 5: Add dartdoc comment

Every public class and constructor parameter must have a `///` doc comment. The class comment should:

- Start with "A hand-drawn ..." or "A sketchy ..."
- Reference `WiredTheme` if the widget reads theme
- List related widgets with `[WiredOtherWidget]` links

### Step 6: Run quality gates

```bash
dart format .
dart analyze --fatal-infos .
cd packages/skribble && flutter test test/
```

### Step 7: Update documentation

When adding a new widget, update the docs site:

1. Add the widget to the appropriate `docs/site/content/widgets/<category>.md` page
2. If adding a new widget category, create a new page and add it to the sidebar in `docs/site/lib/components/site_sidebar.dart`
3. Update any MDT template blocks if the widget introduces a reusable pattern
4. Run `mdt update` if MDT blocks were modified

## Widget implementation patterns

### Reading theme values

Every widget must read colors and config from the theme — never hardcode:

```dart
// Static example: custom-class
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  // Use theme values for all visual properties
  final borderColor = theme.borderColor;    // Color(0xFF1A2B3C)
  final fillColor = theme.fillColor;        // Color(0xFFFEFEFE)
  final textColor = theme.textColor;        // Colors.black
  final strokeWidth = theme.strokeWidth;    // 2.0
  final roughness = theme.roughness;        // 1.0
  // ...
}
```

### Using RoughBoxDecoration

Replace standard `BoxDecoration` with `RoughBoxDecoration` for hand-drawn borders:

```dart
// Static example: custom-class
Container(
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.rectangle,   // or roundedRectangle, circle, ellipse
    borderStyle: RoughDrawingStyle(
      width: theme.strokeWidth,
      color: theme.borderColor,
    ),
    fillStyle: RoughDrawingStyle(
      color: theme.fillColor,
    ),
    borderRadius: BorderRadius.circular(8),  // only for roundedRectangle
  ),
  child: child,
)
```

Available `RoughBoxShape` values:

- `rectangle` — sharp-corner rectangle
- `roundedRectangle` — rounded corners (requires `borderRadius`)
- `circle` — perfect circle
- `ellipse` — oval shape

### RepaintBoundary isolation

Always wrap the widget output with `RepaintBoundary` to isolate repaints:

```dart
// Static example: custom-class
// Option 1: use the global helper function
return buildWiredElement(child: myContent);

// Option 2: extend WiredBaseWidget (override buildWiredElement())
class WiredFoo extends WiredBaseWidget {
  @override
  Widget buildWiredElement() => myContent;
}

// Option 3: use the mixin
class WiredFoo extends HookWidget with WiredRepaintMixin {
  @override
  Widget build(BuildContext context) {
    return buildWiredElement(child: myContent);
  }
}
```

### Using hooks for state

Use `flutter_hooks` for all state management:

```dart
// Static example: custom-class
class WiredCounter extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    final controller = useAnimationController(duration: Duration(milliseconds: 300));
    final memoizedValue = useMemoized(() => expensiveComputation());

    return buildWiredElement(
      child: GestureDetector(
        onTap: () => count.value++,
        child: Text('${count.value}'),
      ),
    );
  }
}
```

Common hooks:

- `useState<T>(initialValue)` — reactive local state
- `useAnimationController(duration:)` — auto-disposed animation controller
- `useAnimation(controller)` — reactive animation value
- `useMemoized(() => value)` — cached computation
- `useEffect(() { ... return dispose; }, [deps])` — side effects
- `useTextEditingController()` — auto-disposed text controller
- `useFocusNode()` — auto-disposed focus node

### Custom painter pattern

For widgets that need custom drawing beyond `RoughBoxDecoration`:

```dart
// Static example: custom-class
class MyShapePainter extends WiredPainterBase {
  final Color borderColor;
  final double strokeWidth;

  MyShapePainter({
    required this.borderColor,
    required this.strokeWidth,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final generator = Generator(drawConfig, filler);
    final shape = generator.rectangle(0, 0, size.width, size.height);
    canvas.drawRough(
      shape,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(borderColor),
    );
  }
}

// Use with WiredCanvas:
WiredCanvas(
  painter: MyShapePainter(
    borderColor: theme.borderColor,
    strokeWidth: theme.strokeWidth,
  ),
  fillerType: RoughFilter.hachureFiller,
)
```

### Fill patterns

The `RoughFilter` enum controls fill patterns:

| Filter          | Effect                        |
| --------------- | ----------------------------- |
| `noFiller`      | Stroke only, no interior fill |
| `hachureFiller` | Diagonal parallel lines       |
| `zigZagFiller`  | Zigzag pattern                |
| `hatchFiller`   | Cross-hatched grid            |
| `dotFiller`     | Scattered dots                |
| `dashedFiller`  | Dashed lines                  |
| `solidFiller`   | Solid color fill              |

### Accessibility

Every interactive widget must include accessibility support:

```dart
// Static example: custom-class
Semantics(
  label: semanticLabel,
  button: true,        // for buttons
  toggled: isSelected, // for toggles
  enabled: enabled,    // for interactive widgets
  child: buildWiredElement(child: ...),
)
```

## Testing patterns

### Test file location

Tests live in `packages/skribble/test/widgets/` and mirror the `lib/src/` structure:

```
lib/src/wired_button.dart    →  test/widgets/wired_button_test.dart
lib/src/wired_card.dart      →  test/widgets/wired_card_test.dart
lib/src/wired_checkbox.dart  →  test/widgets/wired_checkbox_test.dart
```

### pumpApp helper

Always use `pumpApp()` to render widgets in tests. It wraps the widget in the correct app shell:

<!-- {=docsPumpAppExample} -->

```dart
// Static example: test
// Body slot (default)
await pumpApp(tester, myWidget);

// AppBar slot
await pumpApp(tester, WiredAppBar(title: Text('T')), asAppBar: true);

// BottomNavigationBar slot
await pumpApp(tester, myNavBar, asBottomNav: true);

// Drawer slot
await pumpApp(tester, WiredDrawer(child: Text('X')), asDrawer: true);

// With custom theme
await pumpApp(
  tester,
  myWidget,
  theme: WiredThemeData(borderColor: Colors.red),
);
```

<!-- {/docsPumpAppExample} -->

### Minimum 6 tests per widget

Every widget test file must have at least 6 `testWidgets` covering:

1. **Rendering** — widget renders without error, child content appears
2. **Dimensions** — correct default size, custom size respected
3. **Interaction** — taps fire callbacks, state changes work
4. **State** — rebuilds when values change, animations complete
5. **Edge cases** — null values, empty strings, rapid interactions, overflow
6. **Accessibility** — semantic labels applied correctly

### Testing value-driven widgets

For widgets like `WiredCheckbox` or `WiredSlider` that have a current value:

```dart
// Static example: test
testWidgets('updates when value changes', (tester) async {
  var currentValue = false;
  await pumpApp(
    tester,
    StatefulBuilder(
      builder: (context, setState) => WiredCheckbox(
        value: currentValue,
        onChanged: (v) => setState(() => currentValue = v!),
      ),
    ),
  );

  await tester.tap(find.byType(WiredCheckbox));
  await tester.pumpAndSettle();
  expect(currentValue, isTrue);
});
```

## Theming rules for agents

### Never hardcode visual values

```dart
// Static example: test
// WRONG — hardcoded colors
Container(color: Color(0xFF1A2B3C))

// CORRECT — read from theme
final theme = WiredTheme.of(context);
Container(color: theme.borderColor)
```

### WiredThemeData defaults (reference)

| Field               | Default Value              | Description                                     |
| ------------------- | -------------------------- | ----------------------------------------------- |
| `borderColor`       | `Color(0xFF1A2B3C)`        | Sketchy stroke/border color                     |
| `textColor`         | `Colors.black`             | Primary text color                              |
| `disabledTextColor` | `Colors.grey`              | Disabled state text color                       |
| `fillColor`         | `Color(0xFFFEFEFE)`        | Paper-like background fill                      |
| `strokeWidth`       | `2.0`                      | Default stroke thickness                        |
| `roughness`         | `1.0`                      | Sketch randomness (0 = smooth, 2+ = very rough) |
| `drawConfig`        | `DrawConfig.defaultValues` | Advanced rough engine config                    |

### WiredMaterialApp theme setup

```dart
// Static example: setup
WiredMaterialApp(
  wiredTheme: WiredThemeData(
    borderColor: Color(0xFF4A3470),
    textColor: Color(0xFF2A2238),
    fillColor: Color(0xFFFFFCF1),
    roughness: 1.15,
  ),
  darkWiredTheme: WiredThemeData(
    borderColor: Color(0xFFB09BDC),
    textColor: Color(0xFFF0EBF5),
    fillColor: Color(0xFF1E1A26),
    roughness: 1.15,
  ),
  highContrastWiredTheme: WiredThemeData(
    borderColor: Colors.black,
    textColor: Colors.black,
    fillColor: Colors.white,
    strokeWidth: 3,
    roughness: 0.5,
  ),
  highContrastDarkWiredTheme: WiredThemeData(
    borderColor: Colors.white,
    textColor: Colors.white,
    fillColor: Colors.black,
    strokeWidth: 3,
    roughness: 0.5,
  ),
  themeMode: ThemeMode.system,
  home: MyHomePage(),
)
```

Theme resolution follows this fallback chain:

- Light mode: `wiredTheme`
- Dark mode: `darkWiredTheme` -> `wiredTheme`
- High contrast light: `highContrastWiredTheme` -> `wiredTheme`
- High contrast dark: `highContrastDarkWiredTheme` -> `darkWiredTheme` -> `wiredTheme`

### WiredMaterialApp.router setup

For apps using `go_router`, `auto_route`, or any `RouterConfig`, use the `.router` named constructor:

```dart
// Static example: setup
import 'package:go_router/go_router.dart';
import 'package:skribble/skribble.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomePage()),
    GoRoute(path: '/settings', builder: (context, state) => SettingsPage()),
  ],
);

WiredMaterialApp.router(
  wiredTheme: WiredThemeData(),
  darkWiredTheme: darkTheme,
  routerConfig: router,
  title: 'My App',
)
```

The `.router` constructor accepts the same theme parameters as the standard constructor but replaces `home`/`routes`/`initialRoute` with `routerConfig`/`routeInformationProvider`/`routerDelegate`/`backButtonDispatcher`.

## Common widget usage patterns for agents

### Form validation

Use `WiredForm` with `WiredInput` for validated forms:

```dart
// Live example: validated-form
HookBuilder(
  builder: (context) {
    final key = useMemoized(GlobalKey<FormState>.new);
    final accepted = useState(false);
    return WiredForm(
      formKey: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormField<String>(
            validator: (value) => value != null && value.contains('@')
                ? null
                : 'Enter an email address.',
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WiredInput(labelText: 'Email', onChanged: field.didChange),
                if (field.errorText case final String error)
                  Semantics(liveRegion: true, child: Text(error)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          WiredFilledButton(
            onPressed: () => accepted.value = key.currentState!.validate(),
            child: const Text('Check the form'),
          ),
          if (accepted.value)
            const Text('The sample form is valid. Nothing was sent.'),
        ],
      ),
    );
  },
)
```

### Popup menus

```dart
// Live example: popup-menu-button
HookBuilder(
  builder: (context) {
    final selected = useState('Choose an action');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WiredPopupMenuButton<String>(
          items: const [
            WiredPopupMenuItem(value: 'Saved', child: Text('Save')),
            WiredPopupMenuItem(value: 'Shared', child: Text('Share')),
          ],
          onSelected: (value) => selected.value = value,
        ),
        Text(selected.value),
      ],
    );
  },
)
```

### Bottom sheets

```dart
// Live example: bottom-sheet
Builder(
  builder: (context) => WiredButton(
    onPressed: () => showWiredBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Make something lovely'),
            WiredTextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    ),
    child: const Text('Open the sheet'),
  ),
)
```

### Context menus

```dart
// Live example: context-menu
WiredContextMenu(
  actions: [
    WiredContextMenuAction(label: 'Save', onPressed: () {}),
    WiredContextMenuAction(label: 'Share', onPressed: () {}),
  ],
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Text('Make something lovely'),
  ),
)
```

### Steppers

```dart
// Live example: stepper
HookBuilder(
  builder: (context) {
    final current = useState(0);
    return WiredStepper(
      currentStep: current.value,
      onStepTapped: (index) => current.value = index,
      steps: const [
        WiredStep(
          title: Text('Imagine'),
          content: Text('Start with a small idea.'),
        ),
        WiredStep(title: Text('Make'), content: Text('Give it a little ink.')),
        WiredStep(title: Text('Share'), content: Text('Let someone try it.')),
      ],
    );
  },
)
```

### Data tables

```dart
// Live example: data-table
const WiredDataTable(
  columns: [
    WiredDataColumn(label: Text('Sketch')),
    WiredDataColumn(label: Text('Status')),
  ],
  rows: [
    WiredDataRow(cells: [Text('Paper boats'), Text('Ready')]),
    WiredDataRow(cells: [Text('Tiny gardens'), Text('Growing')]),
  ],
)
```

### Cupertino vs Material widget selection

Skribble provides both Material and Cupertino variants for common patterns. Use the Cupertino variants when building iOS-native experiences:

| Material                   | Cupertino                        | When to use Cupertino     |
| -------------------------- | -------------------------------- | ------------------------- |
| `WiredButton`              | `WiredCupertinoButton`           | iOS press-opacity effect  |
| `WiredAppBar`              | `WiredCupertinoNavigationBar`    | iOS-style navigation bar  |
| `WiredBottomNavigationBar` | `WiredCupertinoTabBar`           | iOS tab bar look          |
| `WiredSwitch`              | `WiredCupertinoSwitch`           | iOS-style animated toggle |
| `WiredSlider`              | `WiredCupertinoSlider`           | iOS slider feel           |
| `WiredInput`               | `WiredCupertinoTextField`        | iOS rounded text field    |
| `WiredDialog`              | `WiredCupertinoAlertDialog`      | iOS alert style           |
| `WiredDatePicker`          | `WiredCupertinoDatePicker`       | iOS wheel picker          |
| `WiredSegmentedButton`     | `WiredCupertinoSegmentedControl` | iOS segmented control     |
| `WiredScaffold`            | `WiredPageScaffold`              | iOS page scaffold         |

For platform-adaptive apps, check `Theme.of(context).platform` and choose accordingly.

### Selection patterns

When implementing selection UI, choose the right widget:

| Pattern                      | Widget                                        | Use when                                       |
| ---------------------------- | --------------------------------------------- | ---------------------------------------------- |
| Single exclusive choice      | `WiredRadio` / `WiredRadioListTile`           | User picks exactly one option from a small set |
| Multiple independent choices | `WiredCheckbox` / `WiredCheckboxListTile`     | User can toggle multiple options on/off        |
| Tag-like selection           | `WiredChoiceChip` / `WiredFilterChip`         | Compact chip-based selection                   |
| Single exclusive (compact)   | `WiredSegmentedButton`                        | 2-5 mutually exclusive options                 |
| Dropdown single choice       | `WiredCombo`                                  | Long list, pick one                            |
| Color selection              | `WiredColorPicker`                            | Color swatch grid                              |
| Date selection               | `WiredDatePicker` / `WiredCalendarDatePicker` | Date input                                     |
| Time selection               | `WiredTimePicker`                             | Time input                                     |

## Rough engine reference for agents

### Generator shapes

```dart
// Static example: configuration
final generator = Generator(drawConfig, filler);

// Lines
generator.line(x1, y1, x2, y2);

// Rectangles
generator.rectangle(x, y, width, height);
generator.roundedRectangle(x, y, width, height, tl, tr, br, bl);

// Circles and ellipses
generator.circle(cx, cy, diameter);
generator.ellipse(cx, cy, width, height);

// Polygons
generator.polygon([PointD(x1, y1), PointD(x2, y2), ...]);

// Arcs
generator.arc(cx, cy, width, height, startAngle, stopAngle, closed);

// Multi-segment lines
generator.linearPath([PointD(x1, y1), PointD(x2, y2), ...]);
```

### DrawConfig tuning

```dart
// Static example: configuration
DrawConfig(
  maxRandomnessOffset: 2,    // Max random offset per point
  roughness: 1,              // 0 = smooth, 1 = standard, 2+ = very rough
  bowing: 1,                 // Arc bowing factor
  curveFitting: 0.95,        // Curve accuracy
  curveTightness: 0,         // Curve tension
  curveStepCount: 9,         // Curve segments
  seed: 42,                  // Fixed seed for deterministic output
)
```

### Rendering to canvas

```dart
// Static example: configuration
final drawable = generator.rectangle(0, 0, 100, 50);
canvas.drawRough(
  drawable,
  WiredBase.pathPainter(2, color: Colors.black),   // stroke paint
  WiredBase.fillPainter(Colors.white),              // fill paint
);
```

## Base painters reference

These are the built-in painters agents should reuse where possible:

| Painter                     | Shape             | Key Parameters                                                         |
| --------------------------- | ----------------- | ---------------------------------------------------------------------- |
| `WiredRectangleBase`        | Rectangle         | `leftIndent`, `rightIndent`, `fillColor`, `borderColor`, `strokeWidth` |
| `WiredCircleBase`           | Circle            | `diameterRatio`, `fillColor`, `borderColor`, `strokeWidth`             |
| `WiredLineBase`             | Line              | `x1`, `y1`, `x2`, `y2`, `borderColor`, `strokeWidth`                   |
| `WiredRoundedRectangleBase` | Rounded rect      | `borderRadius`, `fillColor`, `borderColor`, `strokeWidth`              |
| `WiredInvertedTriangleBase` | Inverted triangle | `borderColor`, `strokeWidth`                                           |

## Constants reference

```dart
// Static example: api
const double kWiredButtonHeight = 42.0;
const Color _defaultBorderColor = Color(0xFF1A2B3C);
const Color _defaultFillColor = Color(0xFFFEFEFE);
```

## Commands reference

<!-- {=docsCommandsSection} -->

```bash
# Install dependencies
flutter pub get

# Run all lint checks (format + analyze + docs)
lint:all

# Run dart analyze across all packages
melos run analyze

# Run Flutter widget tests
melos run flutter-test

# Format all Dart code
dart format .

# Fix all fixable lint, format, and docs issues
fix:all

# Capture component screenshots
melos run screenshot

# Generate rough Material icon SVGs
melos run rough-icons

# Generate rough icon font (TTF + Dart helpers)
melos run rough-icons-font

# Generate custom icon artifacts from SVG manifest
melos run rough-icons-custom

# Run CI-equivalent rough icon checks
melos run rough-icons-ci-check
```

<!-- {/docsCommandsSection} -->

## Commit message conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add WiredInfoBox widget
fix: correct WiredSlider thumb offset
refactor: migrate test files to pumpApp
test: add WiredCheckbox rapid-tap test
docs: update button catalog page
chore: bump version to 0.3.5
```

## File naming conventions

| Type           | Location                              | Naming                            |
| -------------- | ------------------------------------- | --------------------------------- |
| Widget         | `packages/skribble/lib/src/`          | `wired_<name>.dart` (snake_case)  |
| Export         | `packages/skribble/lib/skribble.dart` | `export 'src/wired_<name>.dart';` |
| Test           | `packages/skribble/test/widgets/`     | `wired_<name>_test.dart`          |
| Storybook page | `apps/skribble_storybook/lib/pages/`  | `<category>_page.dart`            |
| Docs page      | `docs/site/content/widgets/`          | `<category>.md`                   |

## Checklist for agents

Before marking any widget task as complete, verify:

- [ ] Widget file created at `packages/skribble/lib/src/wired_<name>.dart`
- [ ] UI components use `HookWidget`; motion lifecycle code uses standard Flutter state and tickers
- [ ] Name starts with `Wired` prefix
- [ ] Reads theme via `WiredTheme.of(context)` — no hardcoded colors
- [ ] Wraps output with `buildWiredElement()` or `RepaintBoundary`
- [ ] Has `///` doc comment on the class
- [ ] Has `semanticLabel` parameter for accessibility
- [ ] Exported from `packages/skribble/lib/skribble.dart`
- [ ] Test file at `packages/skribble/test/widgets/wired_<name>_test.dart`
- [ ] Test file has 6+ `testWidgets` covering all categories
- [ ] Tests use `pumpApp()` helper
- [ ] Storybook entry added
- [ ] `dart format .` passes
- [ ] `dart analyze --fatal-infos .` passes
- [ ] `flutter test` passes
- [ ] Documentation updated (widget catalog page, any affected MDT blocks)
- [ ] Changeset added and `monochange check` passes with no lint issues

## Common mistakes to avoid

1. **Using stateful UI components** — use `HookWidget` with `useState` for ordinary components. Keep the motion layer on standard Flutter lifecycle classes.
2. **Forgetting `RepaintBoundary`** — every widget must isolate repaints
3. **Hardcoding colors** — always read from `WiredTheme.of(context)`
4. **Skipping tests** — minimum 6 `testWidgets` per widget, no exceptions
5. **Wrong test helper** — use `pumpApp()`, not raw `tester.pumpWidget()`
6. **Missing barrel export** — widget must be exported from `skribble.dart`
7. **Missing dartdoc** — every public class and parameter needs `///` comments
8. **Missing semantic label** — interactive widgets need a `semanticLabel` parameter
9. **Not updating docs** — when APIs change, update the docs site content
10. **Using `const` constructors for Wired widgets in tests** — many Wired widgets contain mutable rough drawing state, so tests may need non-const instances

## Working with the rough engine

### When to use RoughBoxDecoration vs custom painters

Use `RoughBoxDecoration` when:

- You need a standard shape (rectangle, rounded rect, circle, ellipse)
- You want drop-in replacement for `BoxDecoration`
- The widget uses `Container` or `DecoratedBox`

Use a custom `WiredPainterBase` when:

- You need a non-standard shape (star, wave, arrow, etc.)
- You need to draw multiple shapes in a single painter
- You need fine-grained control over the drawing sequence
- You need to animate the drawing

### DrawConfig and determinism

For consistent visual output in tests and screenshots, use a fixed seed:

```dart
// Static example: configuration
DrawConfig(seed: 42, roughness: 1)
```

Without a fixed seed, rough drawings will vary between renders, which can cause flaky visual regression tests.

## Documentation update requirements

**Every change to the codebase must have corresponding documentation updates.** This is a hard rule, not a suggestion. No PR should be merged without documentation for what changed.

**When you add a widget:**

1. Add it to the appropriate widget catalog page in `docs/site/content/widgets/`
2. Include a code example, parameter table, and behavioral notes
3. Export it from `packages/skribble/lib/skribble.dart`
4. Add a `///` dartdoc comment on the class and all public parameters
5. Add the widget to the API overview at `docs/site/content/reference/api-overview.md`

**When you modify a widget API:**

1. Update the widget's entry in the widget catalog
2. Update any code examples that reference the changed API
3. Update MDT template blocks if the change affects reusable patterns
4. Update the agents.md reference if it lists the widget's parameters

**When you add a feature:**

1. Add or update the relevant guide in `docs/site/content/guides/`
2. Update the getting-started pages if the feature is fundamental
3. Update this agents.md if the feature changes agent workflows
4. Update the API overview if new public types are introduced

**When you modify the theme system:**

1. Update `docs/site/content/core/theme-system.md`
2. Update the theming getting-started page
3. Update the WiredThemeData defaults table in this document
4. Update the theming MDT template block in `templates/theme.t.md`

**When you modify tests or testing infrastructure:**

1. Update `docs/site/content/guides/testing.md`
2. Update the test template in this agents.md

**When you modify the rough engine:**

1. Update `docs/site/content/core/rough-engine.md`
2. Update `docs/site/content/core/painters.md` if painters are affected
3. Update the rough engine reference section in this agents.md

**When you add or modify devenv scripts:**

1. Update the commands section in AGENTS.md (root)
2. Update the workspace commands table at the bottom of this agents.md

**When you modify the docs site itself:**

1. Update the sidebar if pages were added/removed (`docs/site/lib/components/site_sidebar.dart`)
2. Update internal cross-links between pages

**When you modify release or publication automation:**

1. Update `docs/site/content/reference/releasing.md`
2. Run `monochange step validate` and `monochange check`
3. Preview release changes with `monochange step prepare-release --dry-run --diff`
4. Keep pub.dev publication in the two documented rate-limit batches

## Icon pipeline reference

### Generating Material rough icons

```bash
melos run rough-icons          # SVG output only
melos run rough-icons-font     # SVG + TTF font + Dart helpers
```

### Generating custom icon sets

1. Create a manifest JSON:

```json
[
  {
    "identifier": "my_icon",
    "codepoint": "0xE001",
    "svg_path": "icons/my_icon.svg"
  }
]
```

2. Run the generator:

```bash
dart run tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest path/to/manifest.json \
  --output lib/src/generated/my_icons.g.dart \
  --map-name kMyRoughIcons
```

### Using icons in widgets

```dart
// Static example: external-asset
// Material rough icon
WiredIcon(icon: Icons.home)

// Custom SVG icon
WiredIcon.svg(iconData: myCustomIconData)
```

## Workspace commands quick reference

| Command                          | What it does                                    |
| -------------------------------- | ----------------------------------------------- |
| `melos run analyze`              | Dart analyze across all packages                |
| `melos run flutter-test`         | Run Flutter widget tests                        |
| `melos run format`               | Format all Dart code                            |
| `melos run screenshot`           | Capture component screenshots                   |
| `melos run rough-icons`          | Generate rough Material icon SVGs               |
| `melos run rough-icons-font`     | Generate icon font + Dart helpers               |
| `melos run rough-icons-custom`   | Generate custom icon artifacts                  |
| `melos run rough-icons-ci-check` | CI-equivalent icon checks                       |
| `lint:all`                       | All lint checks (format + analyze)              |
| `lint:push`                      | CI lint checks before `git push`                |
| `test:all`                       | All unit and widget tests                       |
| `fix:all`                        | Auto-fix format + lint issues                   |
| `docs:site:serve`                | Serve docs site locally                         |
| `docs:site:build`                | Build static docs for deployment                |
| `monochange step validate`       | Validate release configuration                  |
| `monochange check`               | Validate and lint config, changesets, manifests |
| `monochange run release`         | Open or refresh the release PR                  |

## Changeset lint rules

Changesets are linted by `monochange check`, which the CI `lint` job runs on every pull request. A changeset that breaks a rule fails CI, so follow these when authoring one:

- Exactly one H1 summary heading, 8–90 characters, no trailing period, no Conventional Commit prefix (`feat:` or `fix(scope):` headings are rejected).
- The first description sentence must add information beyond the heading, not restate it.
- At least 80 characters of body prose (120 plus a code block for `major` bumps).
- Keep entries in the inline `target: type` form; never use change types as section headings (`## Breaking`).
- One changeset file per concern; duplicate targets across files are rejected.

Run `monochange check --fix` to auto-fix the style rules; everything else needs a manual edit. The full policy is documented in `docs/site/content/reference/releasing.md` under "Changeset lint rules".

## Visual asset checks

After changing fonts, SVG import, or painting, run the glyph/corpus/pixel regressions and inspect real browser screenshots. `dart run packages/skribble_emoji_gen/bin/update_assets.dart` rebuilds the pinned source assets. `dart run tool/font_specimen.dart` creates embedded-font HTML comparisons. Patrol notebook journeys use shared keys in `lib/testing/quality_keys.dart`; run them through Patrol CLI and retain screenshots. Report browser coverage separately from native-device coverage.

Git hooks are managed by devenv with `prek` and installed the first time you enter the devenv shell. The pre-commit stage checks formatting with `lint:format` and scans staged changes for secrets with gitleaks; the pre-push stage runs the CI lint job (`lint:push`) and scans the full history for secrets. Hooks invoke devenv profile scripts by absolute path, so they work outside the devenv shell, and the pre-push script prepends `.devenv/profile/bin` to `PATH` so nested `dart`/`melos`/`mdt` calls resolve the pinned toolchain.

The automated PR review resolves the Flutter docs workspace package before repository-wide analysis. Its generated Markdown lives under `.audit/` so it does not fail its own formatting check, and test-file inventory paths are repository-relative without a duplicate package prefix.

Repository Markdown uses dprint with `textWrap: "never"`. Keep prose paragraphs unwrapped and run `dprint fmt` after editing Markdown.

### Executable documentation examples

Live Markdown fences begin with `// Live example: <stable-id>`. Define the matching compiled expression in the relevant `docs/site/lib/src/examples/*.examples.dart` category file, with an `@docs-example` doc comment. Editable values use the typed `ExampleSettings` fields. The generator parses setting references, so text and comments are never changed by string matching.

From `docs/site`, run `dart run tool/generate_examples.dart` after changing a builder. It extracts the displayed source and synchronizes marked Markdown fences and the shared button template. Run `--check` in CI. Unknown IDs, unused builders, and stale source must fail validation. Run `mdt update` after generation when changing template-owned examples.

Keep previews in the actual docs layout during tests: inherited typography and article padding can expose failures that an isolated widget hides. Configuration, shell commands, and platform setup remain source instructions rather than simulated widgets.

Every Dart fence requires an explicit classification. Standalone widget expressions use a live example marker. Setup, configuration, API definitions, implementation lessons, tests, pseudocode, and examples requiring custom assets use `// Static example: <reason>` with a reason accepted by `tool/generate_examples.dart`. These internal markers are hidden from displayed and copied code. Do not classify a runnable widget demonstration as static just to bypass preview coverage.
