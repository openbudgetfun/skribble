---
title: Theming
description: Customize skribble's hand-drawn look with WiredThemeData. Control colors, stroke width, roughness, and dark mode across every widget.
order: 4
---

# Theming

Every Wired widget reads its visual properties from a single `WiredThemeData` object, accessed via `WiredTheme.of(context)`. This page covers the full theming API: constructor parameters, default values, the `WiredTheme` inherited scope, Material `ThemeData` synchronization, and dark mode support.

## WiredThemeData

`WiredThemeData` is a plain Dart class that holds all the visual parameters shared across Wired widgets.

### Constructor

```dart
// Static example: api
WiredThemeData({
  bool motionEnabled = true,
  WiredInkInteraction inkInteraction = WiredInkInteraction.pressure,
  Color borderColor = WiredPalette.ink,
  Color textColor = WiredPalette.ink,
  Color disabledTextColor = WiredPalette.mutedInk,
  Color errorColor = WiredPalette.cherry,
  Color fillColor = WiredPalette.paper,
  Color markerColor = WiredPalette.sunshine,
  Color accentColor = WiredPalette.tomato,
  List<Color>? accents, // the WiredColorway.sunny washes
  double strokeWidth = kWiredStrokeWidth, // 1.6
  WiredRoughness roughnessLevel = WiredRoughness.playful,
  WiredFont font = WiredFont.notoSketch,
  List<String>? fontFamilyFallback,
  double? roughness,
  String? fontFamily,
  DrawConfig? drawConfig,
  RoughPen? pen,
})
```

### Colourways

Most apps start from a colourway instead of the constructor: `WiredThemeData.colorway(WiredColorway.sunny)` (the default colours), `berry`, `ocean`, `citrus`, or the calm `quiet`, each for light or dark paper. See the [colourway table](/core/theme-system#colourways) and [Vivid and alive](/guides/vivid-design).

### Parameters

<!-- {=docsWiredThemeDataParameters} -->

| Parameter            | Type                  | Default                                              | Description                                                                                                                                                |
| -------------------- | --------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `borderColor`        | `Color`               | `WiredPalette.ink`                                   | The color of every hand-drawn border, outline, and stroke. Plum ink by default.                                                                            |
| `textColor`          | `Color`               | `WiredPalette.ink`                                   | Primary text color for labels and button text.                                                                                                             |
| `disabledTextColor`  | `Color`               | `WiredPalette.mutedInk`                              | Text color for disabled widgets. A muted plum by default.                                                                                                  |
| `errorColor`         | `Color`               | `WiredPalette.cherry`                                | Ink for errors: the border of an input with error text and the error text itself.                                                                          |
| `fillColor`          | `Color`               | `WiredPalette.paper`                                 | Background fill for cards, inputs, dialogs, and other surfaces. Warm paper by default.                                                                     |
| `markerColor`        | `Color`               | `WiredPalette.sunshine`                              | The highlighter wash under selected and active things: navigation indicators, progress and slider fills, switch tracks, selected chips, and segments.      |
| `accentColor`        | `Color`               | `WiredPalette.tomato`                                | The fill of primary actions: `WiredFilledButton`, the floating action button, and badges. Labels on it use `onAccentColor`.                                |
| `accents`            | `List<Color>?`        | `null`: the `WiredColorway.sunny` washes             | Vivid washes for colour-coding cards, chips, tags, and chart series. Read one with `theme.accentAt(index)`, which cycles through the list.                 |
| `strokeWidth`        | `double`              | `kWiredStrokeWidth` (1.6)                            | Width in logical pixels of the rough-drawn strokes.                                                                                                        |
| `roughnessLevel`     | `WiredRoughness`      | `WiredRoughness.playful`                             | Coordinated border, icon, pen, and Recursive lettering defaults: `gentle`, `playful`, or `expressive`.                                                     |
| `font`               | `WiredFont`           | `WiredFont.notoSketch`                               | The bundled typeface. Install the package that ships it.                                                                                                   |
| `fontFamilyFallback` | `List<String>?`       | `null`                                               | App font families tried after the main family, such as Skribble Noto kit scripts. Used as written, never prefixed with a package.                          |
| `roughness`          | `double?`             | `null`: the level's amplitude (1.1 for playful)      | Geometry amplitude override; `0` removes random displacement.                                                                                              |
| `fontFamily`         | `String?`             | `null`: the `font` family                            | Font override. Bundled families resolve to their font package (`WiredFont.packageFor`); custom families belong to the app.                                 |
| `drawConfig`         | `DrawConfig?`         | `null`: derived from the level                       | A complete drawing override. Otherwise the configuration derives its roughness, offset, and line wobble from the level and the amplitude.                  |
| `pen`                | `RoughPen?`           | `null`: the level's pen (`RoughPen.ink` for playful) | How lines are inked. `RoughPen.uniform` draws constant-width lines.                                                                                        |
| `motionEnabled`      | `bool`                | `true`                                               | Whether decorative ink motion is allowed. The platform's reduced-motion setting still wins.                                                                |
| `inkInteraction`     | `WiredInkInteraction` | `WiredInkInteraction.pressure`                       | Default decorative feedback for buttons: `none`, `pressure` (reinforces strokes on hover, focus, and press), or `redraw` (redraws outlines on each press). |

<!-- {/docsWiredThemeDataParameters} -->

`WiredThemeData.cuddly(brightness: Brightness.dark)` switches the palette to night paper and uses `WiredPalette.dusk` for the marker.

The defaults above are the branded warm-paper palette (`WiredThemeData.cuddly()` for light mode is the same palette with explicit light/dark switching). Reach for the `WiredPalette` constants — `ink`, `paper`, `night`, `mutedInk`, `mutedPaper`, plus the `lilac`, `peach`, `sage`, `butter`, and `coral` accent washes, `dusk` for night markers, and `blush` for the logo's cheeks — so custom themes stay consistent with the kit.

### copyWith

Use `copyWith` to derive a new theme from an existing one, changing only specific values:

```dart
// Static example: configuration
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
// Static example: setup
WiredTheme(
  data: WiredThemeData(
    borderColor: Color(0xFF6A1B9A), // deep purple
    fillColor: Color(0xFFF3E5F5),
  ),
  child: MyWidget(), // any subtree
)
```

### Reading the theme

Inside any widget's `build` method (here `child` is a field of your widget):

```dart
// Static example: custom-class
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

## SkribbleApp integration

`SkribbleApp` installs the theme for the whole app. It is widgets-based, so no Material ancestor is required; see [App shell](../core/app-shell).

`WiredMaterialApp` is the transitional compatibility shell: it lets a Material app adopt Wired theming without replacing its shell. It is not skribble's destination -- see [Architecture](/core/architecture) and the [Material bridge](/core/material-bridge). You can also place a `WiredTheme` ancestor yourself and skip the bridge entirely.

<!-- {=docsThemeSetupSection} -->

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

void main() {
  runApp(
    SkribbleApp(
      // Plum ink on warm paper, with a vivid marker, accent, and washes.
      wiredTheme: WiredThemeData.colorway(WiredColorway.sunny),
      darkWiredTheme: WiredThemeData.colorway(
        WiredColorway.sunny,
        brightness: Brightness.dark,
      ),
      themeMode: SkribbleThemeMode.system,
      title: 'My sketchy app',
      builder: (context, child) => WiredMaterialTheme(child: child!),
      home: WiredScaffold(
        appBar: WiredAppBar(title: Text('Bright ink, day and night')),
        body: Center(
          child: WiredFilledButton(
            onPressed: () {},
            child: Text('Press me'),
          ),
        ),
      ),
    ),
  );
}
```

<!-- {/docsThemeSetupSection} -->

## Material ThemeData synchronization

skribble's core installs `WiredTheme` without touching Material. When Material widgets share the tree -- either because you kept `MaterialApp` via `WiredMaterialApp`, or because a `SkribbleApp` subtree is wrapped in `WiredMaterialTheme` -- skribble also generates a full Material `ThemeData` from your `WiredThemeData`, so standard Material widgets (scaffolds, text, icons, dialogs) stay visually consistent with Wired widgets. See the [Material bridge](../core/material-bridge).

### toColorScheme()

`WiredThemeData.toColorScheme()` builds a Material `ColorScheme` seeded from `borderColor`:

```dart
// Static example: api
final scheme = WiredThemeData(
  borderColor: WiredPalette.ink,
  fillColor: WiredPalette.paper,
  textColor: WiredPalette.ink,
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
// Static example: api
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
// Static example: api
Color get paperBackgroundColor =>
    Color.alphaBlend(fillColor.withValues(alpha: 0.92), Colors.white);
```

This gives scaffolds a slightly warm, paper-like background instead of pure white. It is used automatically for `scaffoldBackgroundColor` and `AppBarTheme.backgroundColor`.

## DrawConfig: advanced rough-drawing tuning

For fine-grained control over the rough-drawing engine, pass a custom `DrawConfig`:

```dart
// Static example: configuration
WiredThemeData(
  drawConfig: DrawConfig.build(
    maxRandomnessOffset: 3,  // max pixel offset for jitter (default: 1.2)
    roughness: 1.5,          // line wobbliness (default: 1.1)
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

Here is a complete `lib/main.dart` that starts from the berry colourway, swaps in its own run of washes, and colour-codes a list. Change colours on top of a colourway rather than building a palette from greys: the colourway keeps ink, paper, and contrast right in both themes.

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
import 'package:skribble/skribble.dart';

const washes = [
  WiredPalette.bubblegum,
  WiredPalette.sky,
  WiredPalette.lime,
  WiredPalette.tangerine,
];

void main() {
  runApp(
    SkribbleApp(
      title: 'Berry Sketch',
      wiredTheme: WiredThemeData.colorway(
        WiredColorway.berry,
      ).copyWith(accents: washes),
      darkWiredTheme: WiredThemeData.colorway(
        WiredColorway.berry,
        brightness: Brightness.dark,
      ).copyWith(accents: washes),
      themeMode: SkribbleThemeMode.system,
      builder: (context, child) => WiredMaterialTheme(child: child!),
      home: const BerryDemo(),
    ),
  );
}

class BerryDemo extends StatelessWidget {
  const BerryDemo({super.key});

  static const tasks = ['Pick berries', 'Bake a pie', 'Share a slice'];

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return WiredScaffold(
      appBar: WiredAppBar(title: const Text('Berry Sketch')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          WiredCascade(
            spacing: 12,
            children: [
              for (final (i, task) in tasks.indexed)
                WiredCard(
                  height: null,
                  color: theme.accentAt(i),
                  child: Text(task),
                ),
            ],
          ),
          const SizedBox(height: 16),
          WiredInput(hintText: 'Add something sweet...'),
          const SizedBox(height: 16),
          WiredFilledButton(
            onPressed: () {},
            child: const Text('Add it'),
          ),
        ],
      ),
    );
  }
}
```

## Nested theme overrides

You can nest `WiredTheme` widgets to override the theme for specific subtrees. This is useful for sections that need a different color treatment. Use this as the `home` of a `SkribbleApp`:

```dart
// Static example: setup
WiredScaffold(
  body: Column(
    children: [
      // Uses the app's theme
      WiredButton(
        onPressed: () {},
        child: Text('Default colors'),
      ),

      // Override just for this section
      WiredTheme(
        data: WiredThemeData(
          borderColor: Color(0xFFC62828), // red ink
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
)
```

The red-themed card and button draw with the red ink, while everything outside that subtree keeps the app's border color (`WiredPalette.ink` by default). A fresh `WiredThemeData` resets every other value to its default; use `WiredTheme.of(context).copyWith(...)` to inherit the rest of the parent theme instead.

## Next steps

- [Widget Reference](/widgets/buttons) -- browse the full catalog with API details
- [Custom Widgets](/guides/custom-widgets) -- build your own Wired widgets using the rough-drawing engine
- [Icons](/widgets/icons) -- use the hand-drawn icon sets

## The bundled handwriting

The default lettering, **Skribble Noto Sketch**, is Google Noto redrawn with a round marker pen. `SkribbleApp`, `WiredTheme`, and `WiredMaterialApp` apply the package-qualified family through the theme, so text resolves the bundled asset with no code. Do not register the fonts yourself with `FontLoader`.

<!-- {=docsTypefaceTable} -->

| Typeface                                  | Package                     | Select with                                                  | Follows the roughness level |
| ----------------------------------------- | --------------------------- | ------------------------------------------------------------ | --------------------------- |
| Skribble Noto Sketch (default)            | `skribble_font_noto_sketch` | nothing: it is the default, or `WiredFont.notoSketch`        | No                          |
| Skribble Noto Soft                        | `skribble_font_noto`        | `WiredThemeData(font: WiredFont.noto)`                       | No                          |
| Skribble Noto Lively                      | `skribble_font_noto_lively` | `WiredThemeData(font: WiredFont.notoLively)`                 | No                          |
| Recursive Casual, Linear, and Mono (code) | `skribble_font_recursive`   | `WiredThemeData(font: WiredFont.casual)`, `.linear`, `.mono` | Yes                         |

Install the package for each typeface you select; every package bundles its own font files, so it works offline. The Skribble Noto packages cover Latin, Greek, and Cyrillic in one Regular face, and Flutter synthesizes bold and italic. Recursive has seven real weights with italics. An explicit `fontFamily` on `WiredThemeData` overrides the choice.

<!-- {/docsTypefaceTable} -->

For a bare `TextStyle` outside the app theme, use `fontFamily: skribbleFontFamily, package: 'skribble_font_noto_sketch'`; see [Installation](/getting-started/installation#choose-another-typeface). Custom font families remain unqualified. Local widget text styles merge with inherited typography instead of dropping the font family. The default pen is 1.6 logical pixels (`kWiredStrokeWidth`) with roughness 1.1.

## App-wide roughness levels

Choose a level once at the app root. The theme coordinates borders, rough icons, pens, and the Recursive lettering:

```dart
// Static example: setup
SkribbleApp(
  wiredTheme: WiredThemeData(
    roughnessLevel: WiredRoughness.gentle,
    borderColor: const Color(0xFF624079),
    fillColor: const Color(0xFFFFFBEF),
  ),
  builder: (context, child) => WiredMaterialTheme(child: child!),
  home: const MyHomePage(), // your own page widget
)
```

<!-- {=docsRoughnessLevelTable} -->

Playful is the default. The docs toolbar switches the ink between Gentle, Playful, and Expressive without resetting the current page; the default Noto Sketch lettering stays the same at every level. [Compare the original and roughened Casual, Linear, and Mono fonts](/core/font-comparison).

| Level        | Appearance                                   | Border amplitude | Font deformation | Casual family     |
| ------------ | -------------------------------------------- | ---------------- | ---------------- | ----------------- |
| `gentle`     | Softer handwriting and gently bowed edges    | 0.9              | 12               | `SkribbleGentle`  |
| `playful`    | Neat, lightly wavering notebook ink          | 1.1              | 20               | `SkribblePlayful` |
| `expressive` | Strong lettering and locally wandering edges | 1.8              | 28               | `Skribble`        |

The default typeface is `WiredFont.notoSketch`, Skribble Noto Sketch from the `skribble_font_noto_sketch` package. It is hand-drawn from Google Noto and keeps the same lettering at every roughness level, as do `WiredFont.noto` and `WiredFont.notoLively` (see [Compare the lettering](/core/font-comparison#skribble-noto)). Set `font: WiredFont.casual`, `WiredFont.linear`, or `WiredFont.mono` on `WiredThemeData` for the Recursive typefaces from `skribble_font_recursive`, which follow the roughness level; the table lists the Casual family names. Use `WiredFont.mono.familyFor(level)` with `package: 'skribble_font_recursive'` for code-only typography. An explicit `fontFamily` takes precedence.

All levels keep the 1.6px pen width (`kWiredStrokeWidth`). Every Recursive face, in all seven weights and their italics, retains the source character coverage, advance widths, and shaping tables, so level changes do not intentionally reflow text. The fonts are bundled and work offline. Each of the three Recursive typefaces bundles 42 static faces: seven weights, upright and italic, at each of the three levels. Font deformation is the roughening strength per 1,000 units per em. Skribble Noto ships one Regular face per level, and Flutter synthesizes bold and italic from it. These are three static font levels, not a continuous variable-font axis; repeated occurrences of a character use the same outline.

<!-- {/docsRoughnessLevelTable} -->

For a section with quieter ink, inherit the palette and override only its level:

```dart
// Static example: setup
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
