# skribble_icons_material

Hand-drawn versions of the full Flutter Material icon set.

Ships precomputed rough geometry for all 8,600+ Material icon codepoints plus a generated icon font. Because the geometry is already warped, rendering never runs the rough engine.

This catalog used to live inside the core `skribble` package. It moved here so that apps which do not render Material icons no longer download it — `skribble` dropped from roughly 31 MiB compressed to about 1.5 MiB.

## Installation

```bash
dart pub add skribble_icons_material
```

To pull in every skribble icon set at once, use [`skribble_icons`](https://pub.dev/packages/skribble_icons) instead.

## Usage

Register the catalog once during startup so `WiredIcon` draws hand-drawn shapes instead of the Material font glyph:

```dart
import 'package:skribble_icons_material/skribble_icons_material.dart';

void main() {
  registerSkribbleMaterialIcons();
  runApp(const MyApp());
}
```

Then either resolve an `IconData`:

```dart
WiredIcon(icon: Icons.search, size: 32)
```

or look up an identifier directly, which needs no registration:

```dart
final data = lookupMaterialRoughIconByIdentifier('search');
```

### Why registration is explicit

`WiredIcon` lives in the core `skribble` package, which must not depend on an icon set. It resolves `IconData` through a catalog that a set registers at startup. Without a registration it falls back to Flutter's ordinary `Icon`, so forgetting the call degrades to a plain glyph rather than crashing.

## Exports

| Export                                | Type                         | Description                                   |
| ------------------------------------- | ---------------------------- | --------------------------------------------- |
| `registerSkribbleMaterialIcons`       | `void Function()`            | Installs the catalog for `WiredIcon`.         |
| `lookupMaterialRoughIconByIdentifier` | `WiredSvgIconData? Function` | Geometry for a Material identifier.           |
| `kMaterialRoughIcons`                 | `Map<int, WiredSvgIconData>` | Geometry keyed by codepoint.                  |
| `kMaterialRoughIconsCodePoints`       | `Map<String, int>`           | Identifiers to codepoints, including aliases. |
| `kMaterialRoughIconsFontFamily`       | `String`                     | Family name of the generated icon font.       |
| `lookupMaterialRoughIconsIconData`    | `IconData? Function`         | Font-backed `IconData` for an identifier.     |

`WiredBrandIcon` (GitHub, Dart, Flutter, and Figma marks) ships in the core `skribble` package, because it is project branding rather than an icon set.

## Regenerating

The catalog comes from the Flutter SDK's own icon declarations, resolved against upstream Material SVG packages. Regenerating needs Deno and a Chromium binary, which the pipeline drives through `svg2roughjs`:

```bash
melos run rough-icons          # rough SVG output only
melos run rough-icons-font     # SVG + TTF font + Dart helpers
melos run rough-icons-baseline # refresh the unresolved-codepoint baseline
melos run rough-icons-ci-check # the same regression gates CI enforces
```

See `docs/rough-icon-pipeline.md` for the full option list, the supplemental manifest used for upstream gaps, and the unresolved-regression gates.

## Attribution

Material icon artwork is Apache-2.0, copyright Google LLC. The generated font and geometry are derivatives and retain that license.

## License

skribble is licensed under the root repository's [LICENSE](../../LICENSE). The icon artwork in this package is Apache-2.0.

## Provenance

This catalog is generated, never hand-edited. The table records exactly what it was built from. Bumping a value means editing `tool/asset_sources.txt` in the same commit as the regenerated catalog.

| Field               | Value                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------- |
| Icon declarations   | Flutter SDK `3.47.0` (`material/icons.dart`)                                             |
| Outline SVGs        | [`@material-design-icons/svg`](https://www.npmjs.com/package/@material-design-icons/svg) |
| Symbol SVGs         | [`@material-symbols/svg-400`](https://www.npmjs.com/package/@material-symbols/svg-400)   |
| Brand fallback      | [`simple-icons`](https://simpleicons.org)                                                |
| Upstream gaps       | `packages/skribble/tool/examples/material_rough_icons.supplemental.manifest.json`        |
| Regression baseline | `packages/skribble/tool/examples/material_rough_icons.unresolved-baseline.json`          |
| Rough engine        | `svg2roughjs` via Deno, seed `1337` + codepoint                                          |
| License             | Apache-2.0                                                                               |
| Generator           | `melos run rough-icons-font`                                                             |
| Registry            | `tool/asset_sources.txt`                                                                 |

Generation is deterministic: rebuilding from the same source bytes reproduces this catalog byte for byte. CI re-derives every catalog and fails on any diff, so an upstream change can never land silently.
