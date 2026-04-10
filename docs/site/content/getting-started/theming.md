---
title: Theming
description: Customize Skribble's hand-drawn look with WiredThemeData. Control colors, stroke width, roughness, and dark mode across every widget.
---

# Theming

Every Wired widget reads its visual properties from a single `WiredThemeData` object, accessed via `WiredTheme.of(context)`. This page covers the full theming API: constructor parameters, default values, the `WiredTheme` inherited widget, Material `ThemeData` synchronization, and dark mode support.

## WiredThemeData

`WiredThemeData` is a plain Dart class that holds all the visual parameters shared across Wired widgets.

### Constructor

```dart
WiredThemeData({
  Color borderColor = const Color(0xFF1A2B3C),
  Color textColor = Colors.black,
  Color disabledTextColor = Colors.grey,
  Color fillColor = const Color(0xFFFEFEFE),
  double strokeWidth = 2,
  double roughness = 1,
  DrawConfig? drawConfig,
})
```

### Parameters

| Parameter           | Type          | Default             | Description                                                                                                                                                                                        |
| ------------------- | ------------- | ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `borderColor`       | `Color`       | `Color(0xFF1A2B3C)` | The color used for all hand-drawn borders, outlines, and strokes. A dark blue-gray by default.                                                                                                     |
| `textColor`         | `Color`       | `Colors.black`      | Primary text color. Applied to labels, button text, and synced to Material's `onSurface`.                                                                                                          |
| `disabledTextColor` | `Color`       | `Colors.grey`       | Text color for disabled widgets.                                                                                                                                                                   |
| `fillColor`         | `Color`       | `Color(0xFFFEFEFE)` | Background fill for cards, inputs, dialogs, and other surfaces. Near-white by default.                                                                                                             |
| `strokeWidth`       | `double`      | `2`                 | Width in logical pixels of the rough-drawn border strokes.                                                                                                                                         |
| `roughness`         | `double`      | `1`                 | Controls how wobbly and imperfect the hand-drawn lines are. `0` produces perfectly straight lines. Higher values increase the sketch effect.                                                       |
| `drawConfig`        | `DrawConfig?` | `null`              | Advanced drawing configuration. When `null`, uses `DrawConfig.defaultValues`. Controls `maxRandomnessOffset`, `bowing`, `curveFitting`, `curveTightness`, `curveStepCount`, and the random `seed`. |

### copyWith

Use `copyWith` to derive a new theme from an existing one, changing only specific values:

```dart
final baseTheme = WiredThemeData();
final boldTheme = baseTheme.copyWith(
  strokeWidth: 4,
  roughness: 2,
);
```

## WiredTheme InheritedWidget

`WiredTheme` is the `InheritedWidget` that makes `WiredThemeData` available throughout the widget tree.

### Providing a theme

Wrap any subtree in a `WiredTheme` to override the theme for descendant widgets:

```dart
WiredTheme(
  data: WiredThemeData(
    borderColor: Colors.deepPurple,
    fillColor: Color(0xFFF3E5F5),
  ),
  child: MyWidget(),
)
```

### Reading the theme

Inside any widget's `build` method:

```dart
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  // Use theme.borderColor, theme.fillColor, theme.strokeWidth, etc.
  return Container(
    decoration: RoughBoxDecoration(
      shape: RoughBoxShape.rectangle,
      borderStyle: RoughDrawingStyle(
        width: theme.strokeWidth,
        color: theme.borderColor,
      ),
    ),
    child: child,
  );
}
```

If no `WiredTheme` ancestor exists, `WiredTheme.of(context)` returns `WiredThemeData.defaultTheme` -- the default theme with all default values. This means Wired widgets always have a valid theme, even without explicit configuration.

## WiredMaterialApp integration

<!-- {=docsThemeSetupSection} -->

`WiredMaterialApp` is the recommended way to set up theming. It handles both the `WiredTheme` injection and Material `ThemeData` synchronization in one widget.

### Basic setup

```dart
void main() {
  runApp(
    WiredMaterialApp(
      wiredTheme: WiredThemeData(),
      home: MyHomePage(),
    ),
  );
}
```

### Theme variants

`WiredMaterialApp` supports four theme variants for full platform adaptation:

```dart
WiredMaterialApp(
  // Light mode theme (required)
  wiredTheme: WiredThemeData(
    borderColor: Color(0xFF1A2B3C),
    fillColor: Color(0xFFFEFEFE),
  ),

  // Dark mode theme (optional -- falls back to wiredTheme)
  darkWiredTheme: WiredThemeData(
    borderColor: Color(0xFFB0BEC5),
    textColor: Colors.white,
    fillColor: Color(0xFF263238),
  ),

  // High-contrast theme for accessibility (optional -- falls back to wiredTheme)
  highContrastWiredTheme: WiredThemeData(
    borderColor: Colors.black,
    textColor: Colors.black,
    fillColor: Colors.white,
    strokeWidth: 3,
  ),

  // High-contrast dark theme (optional -- falls back to darkWiredTheme, then wiredTheme)
  highContrastDarkWiredTheme: WiredThemeData(
    borderColor: Colors.white,
    textColor: Colors.white,
    fillColor: Colors.black,
    strokeWidth: 3,
  ),

  // Controls which theme is active
  themeMode: ThemeMode.system,

  home: MyHomePage(),
)
```

### Theme resolution

`WiredMaterialApp` resolves the active `WiredThemeData` based on `themeMode` and the platform's accessibility settings:

| `themeMode`        | High contrast off                          | High contrast on                           |
| ------------------ | ------------------------------------------ | ------------------------------------------ |
| `ThemeMode.light`  | `wiredTheme`                               | `highContrastWiredTheme`                   |
| `ThemeMode.dark`   | `darkWiredTheme`                           | `highContrastDarkWiredTheme`               |
| `ThemeMode.system` | Light or dark based on platform brightness | High-contrast variant of the resolved mode |

If an optional variant is not provided, the fallback chain is: `highContrastDarkWiredTheme` -> `darkWiredTheme` -> `wiredTheme`.

<!-- {/docsThemeSetupSection} -->

## Material ThemeData synchronization

`WiredMaterialApp` does not just inject `WiredTheme` -- it also generates a full Material `ThemeData` from your `WiredThemeData`. This keeps standard Material widgets (scaffolds, text, icons, dialogs) visually consistent with Wired widgets.

### toColorScheme()

`WiredThemeData.toColorScheme()` builds a Material `ColorScheme` seeded from `borderColor`:

```dart
final scheme = WiredThemeData(
  borderColor: Color(0xFF1A2B3C),
  fillColor: Color(0xFFFEFEFE),
  textColor: Colors.black,
).toColorScheme();

// scheme.primary      == borderColor
// scheme.onPrimary    == auto-contrasting (white or black)
// scheme.secondary    == textColor
// scheme.surface      == fillColor
// scheme.onSurface    == textColor
// scheme.outline      == borderColor at 70% opacity
```

Pass `brightness: Brightness.dark` to generate a dark-mode color scheme.

### toThemeData()

`WiredThemeData.toThemeData()` produces a complete Material `ThemeData`:

```dart
final materialTheme = myWiredTheme.toThemeData();
```

The generated `ThemeData` configures:

- **`scaffoldBackgroundColor`** -- set to `paperBackgroundColor`, a softly lifted paper tone derived from `fillColor`
- **`canvasColor`** -- set to `fillColor`
- **`colorScheme`** -- from `toColorScheme()`
- **`textTheme`** -- body and display colors set to `textColor`
- **`iconTheme`** -- color set to `textColor`
- **`appBarTheme`** -- transparent elevation, paper background, text-colored foreground
- **`cardTheme`** -- fill-colored, zero elevation, no surface tint
- **`dialogTheme`** -- fill-colored, zero elevation
- **`inputDecorationTheme`** -- outline border with `borderColor` and `strokeWidth`
- **`snackBarTheme`** -- fill-colored background, text-colored content
- **`dividerTheme`** -- border-colored at 35% opacity
- **`bottomSheetTheme`** -- fill-colored, zero elevation

### paperBackgroundColor

`WiredThemeData` exposes a computed `paperBackgroundColor` property:

```dart
Color get paperBackgroundColor =>
    Color.alphaBlend(fillColor.withValues(alpha: 0.92), Colors.white);
```

This gives scaffolds a slightly warm, paper-like background instead of pure white. It is used automatically for `scaffoldBackgroundColor` and `AppBarTheme.backgroundColor`.

## DrawConfig: advanced rough-drawing tuning

For fine-grained control over the rough-drawing engine, pass a custom `DrawConfig`:

```dart
WiredThemeData(
  drawConfig: DrawConfig.build(
    maxRandomnessOffset: 3,  // max pixel offset for jitter (default: 2)
    roughness: 1.5,          // line wobbliness (default: 1)
    bowing: 2,               // arc bowing for curves (default: 1)
    curveFitting: 0.9,       // how tightly curves follow control points (default: 0.95)
    curveTightness: 0.1,     // tightness of curve interpolation (default: 0)
    curveStepCount: 12,      // number of steps in curve approximation (default: 9)
    seed: 42,                // RNG seed for deterministic output (default: 1)
  ),
)
```

The `seed` parameter is important: the same seed produces the same wobbly lines on every rebuild. Change the seed to get a different (but still deterministic) rough pattern.

## Custom theme example

Here is a complete example with a purple sketchy palette:

```dart
import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';

void main() {
  // Define a custom purple theme
  final purpleTheme = WiredThemeData(
    borderColor: Color(0xFF6A1B9A),    // deep purple
    textColor: Color(0xFF4A148C),       // darker purple for text
    disabledTextColor: Color(0xFFCE93D8), // light purple for disabled
    fillColor: Color(0xFFF3E5F5),       // very light purple surface
    strokeWidth: 2.5,                    // slightly thicker strokes
    roughness: 1.2,                      // a bit more sketchy
  );

  // Dark variant
  final purpleDarkTheme = WiredThemeData(
    borderColor: Color(0xFFCE93D8),    // light purple borders on dark
    textColor: Color(0xFFE1BEE7),       // light purple text
    disabledTextColor: Color(0xFF7B1FA2),
    fillColor: Color(0xFF1A0A2E),       // very dark purple surface
    strokeWidth: 2.5,
    roughness: 1.2,
  );

  runApp(
    WiredMaterialApp(
      wiredTheme: purpleTheme,
      darkWiredTheme: purpleDarkTheme,
      themeMode: ThemeMode.system,
      home: PurpleDemo(),
    ),
  );
}

class PurpleDemo extends StatelessWidget {
  const PurpleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WiredAppBar(title: const Text('Purple Sketch')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            WiredCard(
              height: null,
              fill: true,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Everything is purple and hand-drawn.'),
              ),
            ),
            const SizedBox(height: 16),
            WiredInput(
              hintText: 'Type something purple...',
            ),
            const SizedBox(height: 16),
            WiredButton(
              onPressed: () {},
              child: const Text('Purple Button'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Nested theme overrides

You can nest `WiredTheme` widgets to override the theme for specific subtrees. This is useful for sections that need a different color treatment:

```dart
WiredMaterialApp(
  wiredTheme: WiredThemeData(), // default theme for most of the app
  home: Scaffold(
    body: Column(
      children: [
        // Uses the default theme
        WiredButton(
          onPressed: () {},
          child: Text('Default colors'),
        ),

        // Override just for this section
        WiredTheme(
          data: WiredThemeData(
            borderColor: Colors.red,
            fillColor: Color(0xFFFFEBEE),
          ),
          child: WiredCard(
            height: null,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('This section uses red borders'),
                  WiredButton(
                    onPressed: () {},
                    child: Text('Red button'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
)
```

The red-themed card and button will use `Colors.red` for borders, while everything outside that subtree keeps the default `Color(0xFF1A2B3C)` border color.

## Next steps

- [Widget Reference](/widgets) -- browse the full catalog with API details
- [Custom Widgets](/guides/custom-widgets) -- build your own Wired widgets using the rough-drawing engine
- [Icons](/guides/icons) -- use the hand-drawn icon set
