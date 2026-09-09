---
title: Theming
description: Customize Skribble's hand-drawn look with WiredThemeData. Control colors, stroke width, roughness, and dark mode across every widget.
---

# Theming

Every Wired widget reads its visual properties from a single `WiredThemeData` object, accessed via `WiredTheme.of(context)`. This page covers the full theming API: constructor parameters, default values, the `WiredTheme` inherited scope, Material `ThemeData` synchronization, and dark mode support.

## WiredThemeData

`WiredThemeData` is a plain Dart class that holds all the visual parameters shared across Wired widgets.

### Constructor

```dart
WiredThemeData({
  Color borderColor = const Color(0xFF1A2B3C),
  Color textColor = Colors.black,
  Color disabledTextColor = Colors.grey,
  Color fillColor = const Color(0xFFFEFEFE),
  double strokeWidth = 2.4,
  WiredRoughness roughnessLevel = WiredRoughness.expressive,
  double? roughness,
  String? fontFamily,
  DrawConfig? drawConfig,
})
```

### Parameters

| Parameter           | Type             | Default               | Description                                                                                                                                                 |
| ------------------- | ---------------- | --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `borderColor`       | `Color`          | `Color(0xFF1A2B3C)`   | The color used for all hand-drawn borders, outlines, and strokes. A dark blue-gray by default.                                                              |
| `textColor`         | `Color`          | `Colors.black`        | Primary text color. Applied to labels, button text, and synced to Material's `onSurface`.                                                                   |
| `disabledTextColor` | `Color`          | `Colors.grey`         | Text color for disabled widgets.                                                                                                                            |
| `fillColor`         | `Color`          | `Color(0xFFFEFEFE)`   | Background fill for cards, inputs, dialogs, and other surfaces. Near-white by default.                                                                      |
| `strokeWidth`       | `double`         | `2.4`                 | Width in logical pixels of the rough-drawn border strokes.                                                                                                  |
| `roughnessLevel`    | `WiredRoughness` | `expressive`          | Coordinated border, icon, and font defaults: `gentle`, `playful`, or `expressive`.                                                                          |
| `roughness`         | `double?`        | `null` → level value  | Optional geometry amplitude override. The default expressive level resolves to `1.8`; `0` removes random displacement.                                      |
| `fontFamily`        | `String?`        | `null` → level family | Optional font override. Bundled families resolve to the `skribble` package; custom families belong to the consuming app.                                    |
| `drawConfig`        | `DrawConfig?`    | `null` → level config | Optional complete drawing override. Otherwise the configuration derives its roughness, offset, and line wobble from the level and any explicit `roughness`. |

### copyWith

Use `copyWith` to derive a new theme from an existing one, changing only specific values:

```dart
final baseTheme = WiredThemeData();
final boldTheme = baseTheme.copyWith(
  strokeWidth: 4,
  roughness: 2,
);
```

## WiredTheme scope

`WiredTheme` is a `HookWidget` backed by an internal `InheritedTheme`; it makes the drawing settings and typography available throughout its subtree.

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

```dart
import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';

void main() {
  final wiredTheme = WiredThemeData(
    borderColor: Color(0xFF4A3470),
    textColor: Color(0xFF2A2238),
    disabledTextColor: Color(0xFFA39AAD),
    fillColor: Color(0xFFFFFCF1),
    roughness: 1.15,
  );

  runApp(
    WiredMaterialApp(
      wiredTheme: wiredTheme,
      darkWiredTheme: WiredThemeData(
        borderColor: Color(0xFFB09BDC),
        textColor: Color(0xFFF0EBF5),
        fillColor: Color(0xFF1E1A26),
        roughness: 1.15,
      ),
      themeMode: ThemeMode.system,
      title: 'My Sketchy App',
      home: MyHomePage(),
    ),
  );
}
```

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
    roughness: 1.5,          // line wobbliness (default: 1.8)
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
    roughness: 1.2,                      // gentler than the default
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

## The bundled handwriting

Skribble's four text styles are derived from the matching **Recursive Sans Casual** static sources. `WiredMaterialApp` registers the package-qualified Skribble family through its theme, so regular, bold, italic, and bold italic select the right bundled assets. Do not manually register only the regular font with `FontLoader`.

For a bare `TextStyle` outside the app theme, use `fontFamily: skribbleFontFamily, package: 'skribble'`. Custom font families remain unqualified. The default pen is 2.4 logical pixels with roughness 1.8. Local widget text styles merge with inherited typography instead of dropping the font family. The bundled Recursive Casual derivative uses deformation strength 36 across Regular, Bold, Italic, and Bold Italic, preserving the source's spacing and shaping.

## App-wide roughness levels

Choose a level once at the app root. The theme coordinates borders, rough icons, and all four lettering styles:

```dart
WiredMaterialApp(
  wiredTheme: WiredThemeData(
    roughnessLevel: WiredRoughness.gentle,
    borderColor: const Color(0xFF624079),
    fillColor: const Color(0xFFFFFBEF),
  ),
  home: const MyHomePage(),
)
```

<!-- {=docsRoughnessLevelTable} -->

| Level        | Appearance                                             | Border amplitude | Font deformation | Bundled family    |
| ------------ | ------------------------------------------------------ | ---------------- | ---------------- | ----------------- |
| `gentle`     | Earlier, softer handwriting and gently bowed edges     | 1.25             | 18               | `SkribbleGentle`  |
| `playful`    | An intermediate amount of wavering ink                 | 1.5              | 27               | `SkribblePlayful` |
| `expressive` | Strong lettering and locally wandering edges (default) | 1.8              | 36               | `Skribble`        |

All levels keep the 2.4px pen. Regular, Bold, Italic, and Bold Italic retain the same source character coverage, advance widths, and shaping tables, so level changes do not intentionally reflow text. The fonts are bundled and work offline. This adds eight font files, about 2.8 MB before delivery compression. These are three static font levels, not a continuous variable-font axis; repeated occurrences of a character use the same outline.

<!-- {/docsRoughnessLevelTable} -->

For a section with quieter ink, inherit the palette and override only its level:

```dart
WiredTheme(
  data: WiredTheme.of(context).copyWith(
    roughnessLevel: WiredRoughness.gentle,
  ),
  child: const MyQuietSection(),
)
```

<!-- {=docsRoughnessLevelBehavior} -->

`WiredTheme` updates plain `Text`, the Material compatibility text theme, and the inherited drawing settings. Its internal `InheritedTheme` also supports captured theme scopes for overlays. Changing a level does not reset control state. Widgets without their own text style inherit the selected family; explicitly styled text, custom fonts, explicit `DrawConfig` values, and artwork with a fixed drawing configuration remain deliberate overrides.

`copyWith` preserves explicit overrides, even when the level changes. For example, a custom `fontFamily` remains custom; a manually supplied `roughness` remains the geometry amplitude. Create fresh `WiredThemeData(roughnessLevel: ...)` to return all those controls to preset defaults. Explicit widget drawing configurations take precedence over the theme.

For custom tuning, `roughness` and `DrawConfig` continue to accept numeric settings. `DrawConfig.lineWobble` controls local wandering: zero restores the earlier bowed-edge renderer; values through one increase the local wavering. Geometry controls do not deform a font at runtime. To generate a custom font between the bundled levels, run:

```bash
dart run packages/skribble_font_roughen/bin/skribble_font_roughen.dart \
  input.ttf MyInk-Regular.ttf --jitter 23.5 --family MyInk
```

Repeat with the matching source and `--variant` for each desired weight/style. Register the resulting files in your app's `pubspec.yaml`, then set `fontFamily: 'MyInk'`. Family names use 1–48 ASCII letters, digits, or hyphens and begin with a letter, so their generated PostScript names remain valid. `--jitter` accepts finite values from 0 through 50.

Rebuild every bundled level with `dart run packages/skribble_font_roughen/bin/roughen_fonts.dart`; add `--check` to verify generated artifacts. The storybook's persistent **Ink style** picker changes the app-level theme and follows navigation to every category.

<!-- {/docsRoughnessLevelBehavior} -->
