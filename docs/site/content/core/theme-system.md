---
title: Theme System
description: Deep dive into WiredThemeData, the WiredTheme scope, Material color scheme generation, theme cascading, and dynamic theming.
---

# Theme System

Every Wired widget reads its colors, stroke width, and roughness from a shared theme. The theme system has three parts: `WiredThemeData` (the data), `WiredTheme` (the inherited scope), and `WiredMaterialApp` (the app-level sync layer).

## WiredThemeData

`WiredThemeData` holds all visual properties that Wired widgets consume.

### Fields

| Field               | Type             | Default                                  | Description                                                                     |
| ------------------- | ---------------- | ---------------------------------------- | ------------------------------------------------------------------------------- |
| `borderColor`       | `Color`          | `Color(0xFF1A2B3C)`                      | Border stroke color for all shapes                                              |
| `textColor`         | `Color`          | `Colors.black`                           | Primary text color                                                              |
| `disabledTextColor` | `Color`          | `Colors.grey`                            | Text color for disabled states                                                  |
| `fillColor`         | `Color`          | `Color(0xFFFEFEFE)`                      | Interior fill color for shapes                                                  |
| `strokeWidth`       | `double`         | `2.4`                                    | Default border stroke width                                                     |
| `roughnessLevel`    | `WiredRoughness` | `expressive`                             | Coordinated defaults for borders, icons, and lettering                          |
| `roughness`         | `double`         | Level value (`1.8` for expressive)       | Resolved amplitude; an explicit constructor value overrides the preset          |
| `fontFamily`        | `String`         | Level family (`Skribble` for expressive) | Resolved bundled or custom family                                               |
| `fontPackage`       | `String?`        | `skribble` for bundled families          | Asset package; null for custom app fonts                                        |
| `drawConfig`        | `DrawConfig`     | Derived from the level and amplitude     | Resolved drawing configuration; an explicit constructor config takes precedence |

### Creating a Theme

```dart
// Default theme
final theme = WiredThemeData();

// Custom palette
final theme = WiredThemeData(
  borderColor: Color(0xFF2D3436),
  fillColor: Color(0xFFF5F0E1),
  textColor: Color(0xFF2D3436),
  strokeWidth: 2.5,
  roughness: 1.3,
);
```

### copyWith

Derive a new theme from an existing one, overriding specific fields:

```dart
final baseTheme = WiredThemeData();
final boldTheme = baseTheme.copyWith(
  strokeWidth: 4,
  roughness: 2,
);
```

### drawConfig Getter

When no `DrawConfig` is passed to the constructor, the getter derives a `DrawConfig` using the theme’s `roughness`. When a custom config is provided, that value is used instead:

```dart
final theme = WiredThemeData(
  drawConfig: DrawConfig.build(roughness: 0.5, seed: 99),
);
print(theme.drawConfig.roughness); // 0.5
```

### defaultTheme

A static singleton that holds the default theme:

```dart
final fallback = WiredThemeData.defaultTheme;
```

This is the value returned by `WiredTheme.of(context)` when no ancestor `WiredTheme` exists in the tree.

## WiredTheme scope

`WiredTheme` is a `HookWidget` backed by an internal `InheritedTheme`. It provides drawing data and matching typography to descendant Wired widgets. Its constructor and `WiredTheme.of(context)` lookup retain their existing API.

### of(context)

The standard lookup method:

<!-- {=docsThemeReadPattern} -->

```dart
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  // Use theme values for all visual properties
  final borderColor = theme.borderColor;
  final fillColor = theme.fillColor;
  final textColor = theme.textColor;
  final strokeWidth = theme.strokeWidth;
  final roughness = theme.roughness;
  final drawConfig = theme.drawConfig;
  final inkExtent = theme.inkExtent;
  // ...
}
```

<!-- {/docsThemeReadPattern} -->

If no `WiredTheme` ancestor exists, `of` returns `WiredThemeData.defaultTheme` rather than throwing. This means Wired widgets work without any explicit theme setup -- they just use default colors.

### Placing WiredTheme in the Tree

```dart
WiredTheme(
  data: WiredThemeData(
    borderColor: Colors.indigo,
    fillColor: Color(0xFFF0EDE5),
  ),
  child: MaterialApp(
    home: Scaffold(
      body: WiredButton(
        onPressed: () {},
        child: Text('Themed button'),
      ),
    ),
  ),
)
```

### updateShouldNotify

`WiredTheme` compares the `data` reference. When you pass a new `WiredThemeData` instance, all dependent widgets rebuild:

```dart
@override
bool updateShouldNotify(WiredTheme oldWidget) {
  return data != oldWidget.data;
}
```

## toColorScheme()

`WiredThemeData` can generate a Material `ColorScheme` derived from its colors:

```dart
ColorScheme toColorScheme({Brightness brightness = Brightness.light})
```

The method uses `ColorScheme.fromSeed` with `borderColor` as the seed, then overrides key slots:

| ColorScheme slot | Mapped from                                          |
| ---------------- | ---------------------------------------------------- |
| `primary`        | `borderColor`                                        |
| `onPrimary`      | Best contrast against `borderColor` (white or black) |
| `secondary`      | `textColor`                                          |
| `onSecondary`    | Best contrast against `textColor`                    |
| `surface`        | `fillColor`                                          |
| `onSurface`      | `textColor`                                          |
| `outline`        | `borderColor` at 70% opacity                         |
| `surfaceTint`    | `borderColor`                                        |
| `shadow`         | `borderColor` at 12% opacity                         |

```dart
final scheme = theme.toColorScheme();
print(scheme.primary); // same as theme.borderColor
```

For dark mode, pass `Brightness.dark`:

```dart
final darkScheme = theme.toColorScheme(brightness: Brightness.dark);
```

## toThemeData()

Converts the Wired theme into a complete Material `ThemeData`:

```dart
ThemeData toThemeData({
  Brightness brightness = Brightness.light,
  bool useMaterial3 = true,
  TextTheme? textTheme,
})
```

This method sets up Material component themes so that standard Material widgets blend with the Skribble aesthetic:

### Component Theme Mapping

| Material Component        | Wired Theme Mapping                        |
| ------------------------- | ------------------------------------------ |
| `scaffoldBackgroundColor` | `paperBackgroundColor`                     |
| `canvasColor`             | `fillColor`                                |
| `dividerColor`            | `borderColor` at 35% opacity               |
| `textTheme`               | Body and display colors set to `textColor` |
| `iconTheme`               | Color set to `textColor`                   |
| `primaryIconTheme`        | Color set to `colorScheme.onPrimary`       |

### AppBarTheme

```dart
AppBarTheme(
  backgroundColor: paperBackgroundColor,
  foregroundColor: textColor,
  elevation: 0,
  shadowColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
)
```

### CardTheme

```dart
CardThemeData(
  color: fillColor,
  elevation: 0,
  surfaceTintColor: Colors.transparent,
  margin: EdgeInsets.zero,
)
```

### DialogTheme

```dart
DialogThemeData(
  backgroundColor: fillColor,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
)
```

### BottomSheetTheme

```dart
BottomSheetThemeData(
  backgroundColor: fillColor,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
)
```

### SnackBarTheme

```dart
SnackBarThemeData(
  backgroundColor: fillColor,
  contentTextStyle: TextStyle(color: textColor),
  actionTextColor: borderColor,
)
```

### InputDecorationTheme

```dart
InputDecorationTheme(
  filled: true,
  fillColor: fillColor,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: borderColor, width: strokeWidth),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: borderColor, width: strokeWidth),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: borderColor, width: strokeWidth + 0.5),
  ),
)
```

### DividerTheme

```dart
DividerThemeData(
  color: borderColor.withValues(alpha: 0.35),
  thickness: 1,
)
```

## paperBackgroundColor

A computed getter that produces a soft, paper-like background tone by alpha-blending `fillColor` over white:

```dart
Color get paperBackgroundColor =>
    Color.alphaBlend(fillColor.withValues(alpha: 0.92), Colors.white);
```

This is used as the `scaffoldBackgroundColor` in `toThemeData()`, giving Material pages a subtle off-white that matches the Wired aesthetic.

## Theme Cascading

Theme data flows through three levels:

```
WiredMaterialApp(wiredTheme: ...)
    |
    v
WiredTheme(data: ...)           <- injected automatically
    |
    v
WiredTheme.of(context)          <- individual widgets read here
```

### Level 1: WiredMaterialApp

The app shell accepts a `wiredTheme` parameter. It wraps the entire `MaterialApp` in a `WiredTheme` ancestor and also calls `toThemeData()` to keep Material theming aligned.

### Level 2: Nested WiredTheme

You can insert additional `WiredTheme` ancestors to override the theme for a subtree:

```dart
WiredMaterialApp(
  wiredTheme: globalTheme,
  home: Column(
    children: [
      WiredButton(...), // uses globalTheme

      WiredTheme(
        data: globalTheme.copyWith(borderColor: Colors.red),
        child: WiredButton(...), // uses red borders
      ),
    ],
  ),
)
```

### Level 3: Per-Widget Overrides

Some widgets accept color parameters directly. These take precedence over the theme:

```dart
WiredRectangleBase(
  borderColor: Colors.blue, // overrides theme.borderColor
  fillColor: Colors.yellow, // overrides theme.fillColor
)
```

## Dark Mode and High-Contrast Support

`WiredMaterialApp` accepts four theme variants:

```dart
WiredMaterialApp(
  wiredTheme: lightTheme,
  darkWiredTheme: darkTheme,
  highContrastWiredTheme: highContrastLight,
  highContrastDarkWiredTheme: highContrastDark,
  themeMode: ThemeMode.system,
  home: MyHomePage(),
)
```

The app resolves which `WiredThemeData` to use based on `ThemeMode` and the platform's accessibility settings:

| ThemeMode | High Contrast Off                                                        | High Contrast On             |
| --------- | ------------------------------------------------------------------------ | ---------------------------- |
| `light`   | `wiredTheme`                                                             | `highContrastWiredTheme`     |
| `dark`    | `darkWiredTheme`                                                         | `highContrastDarkWiredTheme` |
| `system`  | Platform brightness selects light or dark, then high-contrast is checked |                              |

Fallback behavior: if `darkWiredTheme` is not provided, `wiredTheme` is used for dark mode. Similarly, the high-contrast variants fall back to their non-high-contrast equivalents.

### Example: Dark Theme

```dart
final lightTheme = WiredThemeData(
  borderColor: Color(0xFF1A2B3C),
  fillColor: Color(0xFFFEFEFE),
  textColor: Colors.black,
);

final darkTheme = WiredThemeData(
  borderColor: Color(0xFFB0BEC5),
  fillColor: Color(0xFF263238),
  textColor: Color(0xFFECEFF1),
);

WiredMaterialApp(
  wiredTheme: lightTheme,
  darkWiredTheme: darkTheme,
  themeMode: ThemeMode.system,
  home: MyHomePage(),
)
```

## Dynamic Theming with Hooks

Because every widget uses `HookWidget`, you can build dynamic theme switchers with `useState`:

```dart
class ThemeSwitcherApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = useState(false);

    final lightTheme = WiredThemeData(
      borderColor: Color(0xFF1A2B3C),
      fillColor: Color(0xFFFEFEFE),
    );
    final darkTheme = WiredThemeData(
      borderColor: Color(0xFFB0BEC5),
      fillColor: Color(0xFF263238),
      textColor: Color(0xFFECEFF1),
    );

    return WiredMaterialApp(
      wiredTheme: lightTheme,
      darkWiredTheme: darkTheme,
      themeMode: isDark.value ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: Center(
          child: WiredButton(
            onPressed: () => isDark.value = !isDark.value,
            child: Text(isDark.value ? 'Light Mode' : 'Dark Mode'),
          ),
        ),
      ),
    );
  }
}
```

## Advanced: Custom DrawConfig Per Widget

While most widgets inherit `DrawConfig` from the theme, you can override it at the widget level for isolated effects -- for example, making a single card extra rough while the rest of the UI stays smooth.

Pass a custom `DrawConfig` directly to `WiredCanvas`:

```dart
WiredCanvas(
  painter: WiredRectangleBase(
    fillColor: theme.fillColor,
    borderColor: theme.borderColor,
  ),
  fillerType: RoughFilter.hachureFiller,
  drawConfig: DrawConfig.build(roughness: 4, bowing: 3, seed: 42),
)
```

Or use `RoughBoxDecoration` with a custom config:

```dart
Container(
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.rectangle,
    borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),
    drawConfig: DrawConfig.build(roughness: 0.3), // very smooth
  ),
  child: Text('Barely rough'),
)
```

You can also set a custom `DrawConfig` on the theme itself to affect all widgets:

```dart
final theme = WiredThemeData(
  drawConfig: DrawConfig.build(
    roughness: 2.5,
    bowing: 2,
    seed: 7,
  ),
);
```

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

| Level        | Appearance                                             | Border amplitude | Font deformation | Bundled family    |
| ------------ | ------------------------------------------------------ | ---------------- | ---------------- | ----------------- |
| `gentle`     | Earlier, softer handwriting and gently bowed edges     | 1.25             | 18               | `SkribbleGentle`  |
| `playful`    | An intermediate amount of wavering ink                 | 1.5              | 27               | `SkribblePlayful` |
| `expressive` | Strong lettering and locally wandering edges (default) | 1.8              | 36               | `Skribble`        |

All levels keep the 2.4px pen. Regular, Bold, Italic, and Bold Italic retain the same source character coverage, advance widths, and shaping tables, so level changes do not intentionally reflow text. The fonts are bundled and work offline. This adds eight font files, about 2.8 MB before delivery compression. These are three static font levels, not a continuous variable-font axis; repeated occurrences of a character use the same outline.

For a section with quieter ink, inherit the palette and override only its level:

```dart
WiredTheme(
  data: WiredTheme.of(context).copyWith(
    roughnessLevel: WiredRoughness.gentle,
  ),
  child: const MyQuietSection(),
)
```

`WiredTheme` updates plain `Text`, the Material compatibility text theme, and the inherited drawing settings. Its internal `InheritedTheme` also supports captured theme scopes for overlays. Changing a level does not reset control state. Widgets without their own text style inherit the selected family; explicitly styled text, custom fonts, explicit `DrawConfig` values, and artwork with a fixed drawing configuration remain deliberate overrides.

`copyWith` preserves explicit overrides, even when the level changes. For example, a custom `fontFamily` remains custom; a manually supplied `roughness` remains the geometry amplitude. Create fresh `WiredThemeData(roughnessLevel: ...)` to return all those controls to preset defaults. Explicit widget drawing configurations take precedence over the theme.

For custom tuning, `roughness` and `DrawConfig` continue to accept numeric settings. `DrawConfig.lineWobble` controls local wandering: zero restores the earlier bowed-edge renderer; values through one increase the local wavering. Geometry controls do not deform a font at runtime. To generate a custom font between the bundled levels, run:

```bash
dart run packages/skribble_font_roughen/bin/skribble_font_roughen.dart \
  input.ttf MyInk-Regular.ttf --jitter 23.5 --family MyInk
```

Repeat with the matching source and `--variant` for each desired weight/style. Register the resulting files in your app's `pubspec.yaml`, then set `fontFamily: 'MyInk'`. Family names use 1–48 ASCII letters, digits, or hyphens and begin with a letter, so their generated PostScript names remain valid. `--jitter` accepts finite values from 0 through 50.

Rebuild every bundled level with `dart run packages/skribble_font_roughen/bin/roughen_fonts.dart`; add `--check` to verify generated artifacts. The storybook's persistent **Ink style** picker changes the app-level theme and follows navigation to every category.
