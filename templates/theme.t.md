<!-- Shared content for theme system and theming documentation. -->
<!-- {@docsThemeReadPattern} -->

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

<!-- Level table + bundled-font sizing note. -->
<!-- {@docsRoughnessLevelTable} -->

| Level        | Appearance                                          | Border amplitude | Font deformation | Bundled family    |
| ------------ | --------------------------------------------------- | ---------------- | ---------------- | ----------------- |
| `gentle`     | Softer handwriting and gently bowed edges (default) | 1.25             | 18               | `SkribbleGentle`  |
| `playful`    | An intermediate amount of wavering ink              | 1.5              | 27               | `SkribblePlayful` |
| `expressive` | Strong lettering and locally wandering edges        | 1.8              | 36               | `Skribble`        |

All levels keep the 2.4px pen. Regular, Bold, Italic, and Bold Italic retain the same source character coverage, advance widths, and shaping tables, so level changes do not intentionally reflow text. The fonts are bundled and work offline. This adds eight font files, about 2.8 MB before delivery compression. These are three static font levels, not a continuous variable-font axis; repeated occurrences of a character use the same outline.

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
