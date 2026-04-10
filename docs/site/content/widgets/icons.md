---
title: Icons
description: Hand-drawn icon rendering, SVG icon data, animated icons, and the rough icon generation pipeline in Skribble.
---

# Icons

Skribble renders Material icons with rough, hand-drawn outlines and optional hachure or cross-hatch fills. The icon system includes a pre-generated catalog of Material icons converted to SVG primitives, a runtime rough renderer, and helpers for custom icon sets.

---

## WiredIcon

The primary icon widget. Looks up the given `IconData` in the pre-generated rough icon catalog and renders it with hand-drawn strokes. Falls back to Flutter's standard `Icon` for unsupported icon families.

<!-- {=docsIconUsage} -->

```dart
// Basic usage
WiredIcon(icon: Icons.home)

// With customization
WiredIcon(
  icon: Icons.favorite,
  size: 32,
  color: Colors.red,
  fillStyle: WiredIconFillStyle.hachure,
  strokeWidth: 2.0,
)
```

### Constructor parameters

| Parameter        | Type                 | Default      | Description                                                                 |
| ---------------- | -------------------- | ------------ | --------------------------------------------------------------------------- |
| `icon`           | `IconData`           | **required** | The icon to render.                                                         |
| `size`           | `double?`            | `null`       | Icon size. Defaults to `IconTheme.of(context).size` or 24.                  |
| `color`          | `Color?`             | `null`       | Icon color. Defaults to `IconTheme.of(context).color` or `theme.textColor`. |
| `semanticLabel`  | `String?`            | `null`       | Accessibility label.                                                        |
| `fillStyle`      | `WiredIconFillStyle` | `.solid`     | Fill strategy for the icon shapes.                                          |
| `strokeWidth`    | `double`             | `1.6`        | Width of the outline strokes.                                               |
| `drawConfig`     | `DrawConfig?`        | `null`       | Custom rough drawing configuration.                                         |
| `sampleDistance` | `double`             | `1.2`        | Sampling distance along path contours.                                      |
| `hachureGap`     | `double`             | `2.25`       | Gap between hachure fill lines.                                             |
| `hachureAngle`   | `double`             | `320`        | Angle of hachure fill lines in degrees.                                     |

### Fill styles

The `WiredIconFillStyle` enum controls how icon shapes are filled:

| Style        | Description                                              |
| ------------ | -------------------------------------------------------- |
| `none`       | Outline only, no fill.                                   |
| `solid`      | Solid color fill (default). Clean and readable.          |
| `hachure`    | Diagonal hatching lines at the configured angle and gap. |
| `crossHatch` | Two layers of hachure lines at 90 degrees to each other. |

### Notes

- Only `MaterialIcons` font family icons have rough equivalents in the catalog. Other icon families (e.g., custom fonts) fall back to `Icon`.
- RTL text direction is handled automatically: icons with `matchTextDirection` are flipped horizontally.
- The `drawConfig` parameter allows full control over randomness, roughness, bowing, and curve fitting.
- The rough rendering uses path sampling along contours, with `sampleDistance` controlling fidelity.

---

## WiredSvgIcon

Renders a pre-parsed `WiredSvgIconData` with rough hand-drawn strokes. This is the lower-level rendering widget used by `WiredIcon` internally.

<!-- {=docsSvgIconUsage} -->

```dart
WiredSvgIcon(
  data: myCustomSvgIconData,
  size: 48,
  color: Colors.blue,
  fillStyle: WiredIconFillStyle.crossHatch,
  strokeWidth: 2.0,
)
```

### Constructor parameters

| Parameter          | Type                 | Default      | Description                         |
| ------------------ | -------------------- | ------------ | ----------------------------------- |
| `data`             | `WiredSvgIconData`   | **required** | Pre-parsed SVG icon data.           |
| `size`             | `double?`            | `null`       | Icon size.                          |
| `color`            | `Color?`             | `null`       | Icon color.                         |
| `semanticLabel`    | `String?`            | `null`       | Accessibility label.                |
| `fillStyle`        | `WiredIconFillStyle` | `.solid`     | Fill strategy.                      |
| `strokeWidth`      | `double`             | `1.6`        | Outline stroke width.               |
| `drawConfig`       | `DrawConfig?`        | `null`       | Custom rough drawing configuration. |
| `flipHorizontally` | `bool`               | `false`      | Mirror the icon horizontally.       |
| `sampleDistance`   | `double`             | `1.2`        | Path sampling distance.             |
| `hachureGap`       | `double`             | `2.25`       | Hachure line gap.                   |
| `hachureAngle`     | `double`             | `320`        | Hachure angle in degrees.           |

### Notes

- SVG data is scaled to fit the target size while maintaining aspect ratio.
- Path primitives are memoized with `useMemoized` for performance.
- Supports `flipHorizontally` for RTL icon rendering.

---

## WiredSvgIconData

The data type that represents a pre-parsed SVG icon. Contains the viewport dimensions and a list of drawable primitives.

<!-- {=docsSvgIconDataUsage} -->

```dart
const myIcon = WiredSvgIconData(
  width: 24,
  height: 24,
  primitives: [
    WiredSvgPrimitive.path('M12 2L2 22h20L12 2z'),
    WiredSvgPrimitive.circle(cx: 12, cy: 16, radius: 2),
  ],
);
```

### Structure

```dart
final class WiredSvgIconData {
  final double width;
  final double height;
  final List<WiredSvgPrimitive> primitives;
}
```

### Primitive types

| Type                       | Factory                              | Description                                |
| -------------------------- | ------------------------------------ | ------------------------------------------ |
| `WiredSvgPathPrimitive`    | `.path(data)`                        | An SVG path string (e.g., `'M0 0L10 10'`). |
| `WiredSvgCirclePrimitive`  | `.circle(cx, cy, radius)`            | A circle primitive.                        |
| `WiredSvgEllipsePrimitive` | `.ellipse(cx, cy, radiusX, radiusY)` | An ellipse primitive.                      |

Each primitive supports an optional `fillRule` parameter (`WiredSvgFillRule.nonZero` or `.evenOdd`).

---

## WiredAnimatedIcon

A hand-drawn wrapper around Flutter's `AnimatedIcon`. Applies Skribble theme colors while preserving the standard animation behavior.

<!-- {=docsAnimatedIconUsage} -->

```dart
final controller = useAnimationController(
  duration: Duration(milliseconds: 300),
);

WiredAnimatedIcon(
  icon: AnimatedIcons.menu_arrow,
  progress: controller,
  size: 24,
)
```

### Constructor parameters

| Parameter       | Type                | Default      | Description                                |
| --------------- | ------------------- | ------------ | ------------------------------------------ |
| `icon`          | `AnimatedIconData`  | **required** | The animated icon data.                    |
| `progress`      | `Animation<double>` | **required** | Animation progress (0.0 to 1.0).           |
| `color`         | `Color?`            | `null`       | Icon color. Defaults to `theme.textColor`. |
| `size`          | `double?`           | `null`       | Icon size.                                 |
| `semanticLabel` | `String?`           | `null`       | Accessibility label.                       |
| `textDirection` | `TextDirection?`    | `null`       | Text direction for the icon.               |

### Notes

- Wraps the standard `AnimatedIcon` in `buildWiredElement` for repaint isolation.
- Color defaults to `theme.textColor` when not specified.

---

## Rough icon generation pipeline

Skribble includes a build-time pipeline that converts Material icons from their standard font/SVG format into the `WiredSvgIconData` catalog used at runtime.

### Overview

The pipeline consists of two tooling packages:

1. **flutter-material kit** -- Extracts SVG path data from the Material Icons font and converts each glyph into `WiredSvgPrimitive` entries.

2. **svg-manifest kit** -- Processes SVG files into the manifest format, generating Dart source files with `WiredSvgIconData` constants.

### Generated files

The build pipeline produces two files in `packages/skribble/lib/src/generated/`:

- **`material_rough_icons.g.dart`** -- A `Map<int, WiredSvgIconData>` keyed by icon code point, containing the SVG primitive data for every supported Material icon.

- **`material_rough_icon_font.g.dart`** -- Code point lookup tables and a custom font family constant for the rough icon font.

### Using generated icon maps

```dart
import 'package:skribble/skribble.dart';

// Look up by IconData
final data = lookupMaterialRoughIcon(Icons.home);
if (data != null) {
  // Use with WiredSvgIcon
}

// Look up by string identifier
final data2 = lookupMaterialRoughIconByIdentifier('home');

// Get the rough font family name
final fontFamily = materialRoughFontFamily;

// Get all available icon identifiers
final identifiers = materialRoughIconIdentifiers;

// Get all available code points
final codePoints = materialRoughIconCodePoints;
```

### Icon lookup helpers

| Function                                      | Description                                      |
| --------------------------------------------- | ------------------------------------------------ |
| `lookupMaterialRoughIcon(IconData)`           | Returns `WiredSvgIconData?` for a Material icon. |
| `lookupMaterialRoughIconByIdentifier(String)` | Returns `WiredSvgIconData?` by icon name string. |
| `lookupMaterialRoughFontIcon(String)`         | Returns `IconData?` for the rough icon font.     |
| `materialRoughFontFamily`                     | The font family string for the rough icon font.  |
| `materialRoughFontCodePoints`                 | `Map<String, int>` of icon name to code point.   |
| `materialRoughIconIdentifiers`                | `List<String>` of all available icon names.      |
| `materialRoughIconCodePoints`                 | `List<int>` of all available code points.        |

---

## Custom icon sets

The `skribble_icons_custom` package provides tooling for generating rough icon catalogs from your own SVG icon sets.

### Workflow

1. Place SVG files in a source directory.
2. Configure the icon set in the package's build configuration.
3. Run the generation pipeline to produce a Dart file with `WiredSvgIconData` constants.
4. Use the generated constants with `WiredSvgIcon`.

<!-- {=docsCustomIconsUsage} -->

```dart
// After generating from your SVG set:
import 'package:my_app/generated/custom_icons.g.dart';

WiredSvgIcon(
  data: kCustomIcons['logo']!,
  size: 48,
  fillStyle: WiredIconFillStyle.hachure,
)
```

### Notes

- Custom icons go through the same SVG-to-primitive conversion as Material icons.
- The generator handles path, circle, and ellipse SVG elements.
- Fill rules (nonZero / evenOdd) are preserved from the source SVG.
- Complex SVG features (gradients, filters, masks) are not supported -- icons should be simple path-based designs.
