---
title: Icons
description: Hand-drawn icon rendering, SVG icon data, animated icons, and the rough icon generation pipeline in skribble.
---

# Icons

skribble renders Material icons with rough, hand-drawn outlines and optional hachure or cross-hatch fills. The icon system includes a pre-generated catalog of Material icons converted to SVG primitives, a runtime rough renderer, and helpers for custom icon sets.

---

## WiredIcon

The primary icon widget. Looks up the given `IconData` in the pre-generated rough icon catalog and renders it with hand-drawn strokes. Falls back to Flutter's standard `Icon` for unsupported icon families.

```dart
// Live example: icon
const Wrap(
  spacing: 24,
  children: [
    WiredIcon(
      icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
      semanticLabel: 'Home',
      size: 48,
    ),
    WiredIcon(
      icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
      semanticLabel: 'Favourite',
      size: 48,
    ),
    WiredIcon(
      icon: IconData(0xe047, fontFamily: 'MaterialIcons'),
      semanticLabel: 'Add',
      size: 48,
    ),
  ],
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
| `strokeWidth`    | `double`             | `1.6`        | Base pen width; solid fills use a 45% contour to keep small counters open.  |
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

```dart
// Live example: svg-icon
WiredSvgIcon(
  data: exampleIcon('favorite'),
  size: 64,
  color: const Color(0xffe8957d),
  fillStyle: WiredIconFillStyle.solid,
  semanticLabel: 'Favourite',
)
```

### Constructor parameters

| Parameter          | Type                 | Default      | Description                                                                |
| ------------------ | -------------------- | ------------ | -------------------------------------------------------------------------- |
| `data`             | `WiredSvgIconData`   | **required** | Pre-parsed SVG icon data.                                                  |
| `size`             | `double?`            | `null`       | Icon size.                                                                 |
| `color`            | `Color?`             | `null`       | Icon color.                                                                |
| `semanticLabel`    | `String?`            | `null`       | Accessibility label.                                                       |
| `fillStyle`        | `WiredIconFillStyle` | `.solid`     | Fill strategy.                                                             |
| `strokeWidth`      | `double`             | `1.6`        | Base pen width; solid fills use a 45% contour to keep small counters open. |
| `drawConfig`       | `DrawConfig?`        | `null`       | Custom rough drawing configuration.                                        |
| `flipHorizontally` | `bool`               | `false`      | Mirror the icon horizontally.                                              |
| `sampleDistance`   | `double`             | `1.2`        | Path sampling distance.                                                    |
| `hachureGap`       | `double`             | `2.25`       | Hachure line gap.                                                          |
| `hachureAngle`     | `double`             | `320`        | Hachure angle in degrees.                                                  |

### Notes

- SVG data is scaled to fit the target size while maintaining aspect ratio.
- Path primitives are memoized with `useMemoized` for performance.
- Supports `flipHorizontally` for RTL icon rendering.

---

## WiredSvgIconData

The data type that represents a pre-parsed SVG icon. Contains the viewport dimensions and a list of drawable primitives.

```dart
// Live example: svg-icon-data
const WiredSvgIcon(
  data: WiredSvgIconData(
    width: 24,
    height: 24,
    primitives: [
      WiredSvgPrimitive.path('M12 2L2 22h20L12 2z'),
      WiredSvgPrimitive.circle(cx: 12, cy: 16, radius: 2),
    ],
  ),
  size: 64,
  semanticLabel: 'Triangle with a circular detail',
)
```

### Structure

```dart
// Static example: type
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

A hand-drawn wrapper around Flutter's `AnimatedIcon`. Applies skribble theme colors while preserving the standard animation behavior.

```dart
// Live example: animated-icon
HookBuilder(
  builder: (context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 350),
    );
    final open = useState(false);
    return WiredButton(
      onPressed: () {
        open.value = !open.value;
        if (MediaQuery.disableAnimationsOf(context)) {
          controller.value = open.value ? 1 : 0;
        } else if (open.value) {
          controller.forward();
        } else {
          controller.reverse();
        }
      },
      child: WiredAnimatedIcon.menuClose(
        progress: controller,
        semanticLabel: open.value ? 'Close' : 'Open menu',
      ),
    );
  },
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

skribble includes a build-time pipeline that converts Material icons from their standard font/SVG format into the `WiredSvgIconData` catalog used at runtime.

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
// Static example: api
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

## Icon packages

Each icon set ships as its own package so an app only pays for the artwork it renders. `skribble_icons` is the umbrella: it depends on every set, re-exports their catalogs, and adds a cross-set lookup.

| Package                   | Names  | Style                   | License    |
| ------------------------- | ------ | ----------------------- | ---------- |
| `skribble_icons_simple`   | 3,472  | brand marks             | CC0-1.0    |
| `skribble_icons_curated`  | 30     | app vocabulary          | Apache-2.0 |
| `skribble_icons_material` | 8,600+ | Flutter's `Icons`       | Apache-2.0 |
| `skribble_icons_lucide`   | 2,056  | 2px open outlines       | ISC        |
| `skribble_icons_bxs`      | 665    | filled silhouettes      | MIT        |
| `skribble_icons_cib`      | 831    | brand and product marks | CC0-1.0    |

### Installation

Install only what you render:

```bash
# Everything
dart pub add skribble_icons

# Or a single set
dart pub add skribble_icons_lucide
```

### Curated icons

The curated set covers the actions a typical screen needs. Each one is authored as a 24x24 SVG and warped at generation time, so no rough engine work happens at render time.

```dart
// Live example: custom-icons
Wrap(
  spacing: 24,
  runSpacing: 20,
  children: [
    SkribbleIcon(
      data: kSkribbleCuratedIcons[0xf001]!,
      semanticLabel: 'Home',
      size: 48,
    ),
    SkribbleIcon(
      data: kSkribbleCuratedIcons[0xf005]!,
      semanticLabel: 'Heart',
      size: 48,
    ),
    SkribbleIcon(
      data: kSkribbleCuratedIcons[0xf003]!,
      semanticLabel: 'Settings',
      size: 48,
    ),
  ],
)
```

**Upgrading from 0.1.x?** Icon catalogs and typefaces moved into their own packages in 0.2, and `WiredIcon` needs a one-time registration. See [Upgrading to 0.2](/getting-started/upgrading-to-0-2).

### Activating Material icons

`WiredIcon` resolves an `IconData` through a registered catalog. Importing an icon package is not enough on its own, so call the registration once during startup. Without it, `WiredIcon` falls back to Flutter's plain `Icon` widget.

```dart
// Static example: api
import 'package:skribble_icons/skribble_icons.dart';

void main() {
  registerSkribbleIcons();
  runApp(const MyApp());
}
```

The Iconify sets and the curated set need no registration. They are looked up by identifier, which the umbrella package reads directly:

```dart
// Static example: api
import 'package:skribble/skribble.dart';
import 'package:skribble_icons/skribble_icons.dart';

final data = lookupSkribbleIconByIdentifier('home');
if (data != null) {
  WiredSvgIcon(data: data, size: 32);
}
```

### Unified lookup API

`lookupSkribbleIcon` searches the sets in a fixed order and reports which one matched. The curated set wins ties because its names are chosen to match the component library's own vocabulary.

```dart
// Static example: api
final match = lookupSkribbleIcon('a-arrow-down');
print(match?.set); // SkribbleIconSet.lucide
print(match?.data); // WiredSvgIconData
```

| Function                                | Returns              | Description                                           |
| --------------------------------------- | -------------------- | ----------------------------------------------------- |
| `lookupSkribbleIconByIdentifier`        | `WiredSvgIconData?`  | Geometry for an identifier across every bundled set.  |
| `lookupSkribbleIcon`                    | `SkribbleIconMatch?` | Geometry plus the `SkribbleIconSet` that supplied it. |
| `lookupSkribbleCuratedIconByIdentifier` | `WiredSvgIconData?`  | Curated 30-icon set only.                             |
| `lookupLucideIconByIdentifier`          | `WiredSvgIconData?`  | Lucide only.                                          |
| `lookupBxsIconByIdentifier`             | `WiredSvgIconData?`  | Boxicons Solid only.                                  |
| `lookupCibIconByIdentifier`             | `WiredSvgIconData?`  | CoreUI Brands only.                                   |
| `skribbleIconCount`                     | `int`                | Names across the non-Material sets.                   |
| `skribbleMaterialIconCount`             | `int`                | Names in the Material catalog.                        |

### Codepoint bands

Private-use codepoints are allocated per set so a future merged catalog cannot collide. Material keeps its upstream codepoints and resolves through `IconData`.

| Set     | Band              |
| ------- | ----------------- |
| curated | `0xF001–0xF0FF`   |
| lucide  | `0xE000–0xEFFF`   |
| bxs     | `0xF100–0xF3FF`   |
| cib     | `0xF400–0xF7FF`   |
| simple  | `0xF0000–0xF0FFF` |

### Material icons

`WiredIcon(icon: Icons.home)` renders a hand-drawn shape once the Material catalog is registered. That catalog lives in `skribble_icons_material`, which keeps the core `skribble` package free of icon data. If you would rather not carry 8,600 codepoints, skip the registration and `WiredIcon` draws the ordinary font glyph instead.

---

## Custom icon sets

Use the `svg-manifest` kit in the rough icon CLI to generate a catalog from your own SVG icon set. The bundled sets all use it: `skribble_icons_curated` from a checked-in manifest, and the four Iconify packages from pinned upstream `icons.json` payloads.

### Workflow

1. Place SVG files in a source directory.
2. Configure the icon set in the package's build configuration.
3. Run the generation pipeline to produce a Dart file with `WiredSvgIconData` constants.
4. Use the generated constants with `WiredSvgIcon`.

```dart
// Static example: external-asset
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

## Reproducible catalogs and readable counters

The Material catalog contains 8,622 unique icon codepoints (8,825 names including aliases) for the pinned Flutter 3.47.0 SDK. Run `./scripts/check_rough_icons_ci.sh all` to check unresolved symbols and Material catalog drift, and `melos run icons-check` to re-derive every icon catalog and fail on any diff.

The 30 curated icons regenerate from `packages/skribble_icons_curated/tool/skribble_icons.manifest.json` with `melos run icons-curated`. The Simple Icons, Lucide, Boxicons Solid, and CoreUI Brands catalogs regenerate from their pinned sources with `melos run icons-iconify`; the versions and SHA-256 checksums live in `tool/asset_sources.txt`, so an upstream bump is an explicit edit rather than a silent drift.

Curated geometry retains its source view box, preventing oversized output. Runtime rough fills preserve separate contours and even-odd fill rules, so rings, search symbols, and other counters stay open. Small icons use a gentler wobble than layout borders. `WiredSvgPrimitive.path` also accepts `clipPaths` in the same coordinate system. Source colors may be `#RGB`, `#RRGGBB`, or `#RRGGBBAA`.

Theme-derived icon outline deformation follows the active geometry amplitude, including `WiredRoughness` presets. Supplying an icon `drawConfig` keeps that explicit configuration when the theme level changes.

## Animated glyph compatibility

`WiredAnimatedIcon.menuClose(progress: animation)` selects the built-in menu-to-close glyph without requiring a Material import. This compatibility widget uses Flutter's smooth glyph morph. Use `WiredDraw` or `WiredDrawTransition` around Wired components when you want hand-drawn outlines to appear as pen strokes.

## Simple Icons brand marks

GitHub, Dart, Flutter, and Figma are bundled as vector paths. Choose a fill style in the live example, and use the page roughness control to compare the contours. Solid ink keeps a clean interior; hachure makes the drawing strokes visible.

```dart
// Live example: brand-icons
Wrap(
  spacing: 24,
  runSpacing: 20,
  children: [
    for (final brand in WiredBrandIcon.values)
      WiredSvgIcon(
        data: brand.data,
        size: 48,
        color: const Color(0xffe8957d),
        fillStyle: WiredIconFillStyle.solid,
        semanticLabel: brand.name,
      ),
  ],
)
```

`WiredBrandIcon.github.data` can be passed directly to `WiredSvgIcon`. The curated artwork comes from Simple Icons 16.30.0. See the [source and brand guidelines](https://github.com/simple-icons/simple-icons/tree/16.30.0) before using a brand mark in a product.

### How icon roughness works

A deterministic, smooth displacement moves the icon's contour points. Fills and outlines share this geometry, so small icons have uneven curves without noisy edges. The theme's Gentle, Playful, and Expressive presets control the amplitude. An explicit `drawConfig` overrides the theme; set its roughness to zero for the unwarped silhouette.

Icons remain vector data. No bitmap images or per-resolution assets are generated for these styles. To regenerate the curated brand catalog from the repository root:

```bash
dart run packages/skribble/tool/generate_rough_icons.dart --kit svg-manifest --manifest packages/skribble/tool/brands/manifest.json --output packages/skribble/lib/src/generated/brand_rough_icons.g.dart --map-name kBrandRoughIcons
dart format packages/skribble/lib/src/generated/brand_rough_icons.g.dart
```

## Upright hand-drawn outlines

Hand-drawn icons keep the source artwork's orientation. The generator preserves stroke endpoints and adds small opposing bends between them, so vertical stems stay upright. Deliberately diagonal artwork, such as an arrow, keeps its direction. Runtime rough icons remove the displacement field's overall tilt before painting.

Generated coordinates discard insignificant floating-point drift before decimal rounding, keeping the catalogs identical on ARM and x64 hosts.

The docs and storybook register the Material catalog at startup. Applications using `WiredIcon` must call `registerSkribbleIcons()` before `runApp`; without a registered catalog, the widget uses Flutter's regular icon glyph.

The storybook's **Skribble Icons** page has searchable Curated, Material, Lucide, Simple Icons, Boxicons, and CoreUI Brands catalogs. Tap an icon to compare it at 24, 48, and 96 pixels. Lookups stay within the selected set even when names overlap.
