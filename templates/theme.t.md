<!-- Shared content for theme system and theming documentation. -->
<!-- {@docsThemeReadPattern} -->

```dart
// Static example: custom-class
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

<!-- Every WiredThemeData constructor parameter with its default. Keep in
     step with the constructor in packages/skribble/lib/src/wired_theme.dart. -->
<!-- {@docsWiredThemeDataParameters} -->

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

<!-- Level table + bundled-font sizing note. -->
<!-- {@docsRoughnessLevelTable} -->

Playful is the default. The docs toolbar switches the ink between Gentle, Playful, and Expressive without resetting the current page; the default Noto Sketch lettering stays the same at every level. [Compare the original and roughened Casual, Linear, and Mono fonts](/core/font-comparison).

| Level        | Appearance                                   | Border amplitude | Font deformation | Casual family     |
| ------------ | -------------------------------------------- | ---------------- | ---------------- | ----------------- |
| `gentle`     | Softer handwriting and gently bowed edges    | 0.9              | 12               | `SkribbleGentle`  |
| `playful`    | Neat, lightly wavering notebook ink          | 1.1              | 20               | `SkribblePlayful` |
| `expressive` | Strong lettering and locally wandering edges | 1.8              | 28               | `Skribble`        |

The default typeface is `WiredFont.notoSketch`, Skribble Noto Sketch from the `skribble_font_noto_sketch` package. It is hand-drawn from Google Noto and keeps the same lettering at every roughness level, as do `WiredFont.noto` and `WiredFont.notoLively` (see [Compare the lettering](/core/font-comparison#skribble-noto)). Set `font: WiredFont.casual`, `WiredFont.linear`, or `WiredFont.mono` on `WiredThemeData` for the Recursive typefaces from `skribble_font_recursive`, which follow the roughness level; the table lists the Casual family names. Use `WiredFont.mono.familyFor(level)` with `package: 'skribble_font_recursive'` for code-only typography. An explicit `fontFamily` takes precedence.

All levels keep the 1.6px pen width (`kWiredStrokeWidth`). Every Recursive face, in all seven weights and their italics, retains the source character coverage, advance widths, and shaping tables, so level changes do not intentionally reflow text. The fonts are bundled and work offline. Each of the three Recursive typefaces bundles 42 static faces: seven weights, upright and italic, at each of the three levels. Font deformation is the roughening strength per 1,000 units per em. Skribble Noto ships one Regular face per level, and Flutter synthesizes bold and italic from it. These are three static font levels, not a continuous variable-font axis; repeated occurrences of a character use the same outline.

<!-- {/docsRoughnessLevelTable} -->

<!-- Override semantics + custom font tuning shared by theming pages. -->
<!-- {@docsRoughnessLevelBehavior} -->

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
