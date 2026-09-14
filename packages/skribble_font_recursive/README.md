# skribble_font_recursive

The bundled skribble typefaces as a standalone package.

## Provenance

The bundled typefaces are generated, never hand-tuned. Every face descends from one pinned variable source, warped by `packages/skribble_font_roughen`.

| Field            | Value                                                              |
| ---------------- | ------------------------------------------------------------------ |
| Source typeface  | [Recursive](https://recursive.design) `1.085` by Arrow Type        |
| Upstream commit  | `6d491202cea5cf6a493ef710cbef2527b9b08939`                         |
| Source SHA-256   | `653221ca467f4732fe6856ac493f6c409e9f56a7674abe36b2364acc89796f7c` |
| License          | SIL OFL 1.1 (`RECURSIVE-OFL.txt` ships alongside the faces)        |
| Roughness levels | Gentle 18.0, Playful 27.0, Expressive 36.0 (per 1,000 units)       |
| Families         | Casual, Linear, Mono Linear × 3 roughness levels                   |
| Static faces     | 126 (7 weights × 2 italics × 3 levels × 3 spacing styles)          |
| Variable faces   | 3 (`SkribbleVariable{Gentle,Playful,Expressive}`)                  |
| Generator        | `dart run packages/skribble_font_roughen/bin/roughen_fonts.dart`   |
| Files            | 130 (129 faces + `OFL.txt`)                                        |
| Registry         | `tool/asset_sources.txt`                                           |

Each static face is instanced from a finished variable font, so all 126 share the same hand-drawn displacement and stay consistent across weight, italics, and spacing.

Generation is deterministic. The jitter is a pure integer hash of a seed and a point index — there is no `Random` anywhere in the pipeline — so rebuilding produces byte-identical fonts. `roughen_fonts.dart --check` proves it: it builds into a temporary directory and compares every output byte against what is committed. CI runs that check on every pull request.

## Usage

```yaml
dependencies:
  skribble_font_recursive: ^0.1.1
```

No code is required — Flutter registers the families from this package's pubspec. Then select them through core's theme:

```dart
import 'package:skribble/skribble.dart';

WiredTheme(
  data: WiredThemeData(font: WiredFont.casual),
  child: const MyApp(),
)
```

`WiredFont` and `WiredRoughness` in the core `skribble` package own the family names; this package owns the bytes. Keep the two in step when upgrading.
