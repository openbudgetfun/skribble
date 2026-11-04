# skribble_font_recursive

The roughened Recursive typefaces (Casual, Linear, and Mono) as a standalone package. Each is redrawn at the Gentle, Playful, and Expressive roughness levels and follows the theme's level. skribble's default typeface is Skribble Noto Sketch (`skribble_font_noto_sketch`); select these with `WiredThemeData(font: WiredFont.casual)`, `.linear`, or `.mono`.

## Provenance

The bundled typefaces are generated, never hand-tuned. Every face descends from one pinned variable source, warped by `packages/skribble_font_roughen`.

| Field            | Value                                                              |
| ---------------- | ------------------------------------------------------------------ |
| Source typeface  | [Recursive](https://recursive.design) `1.085` by Arrow Type        |
| Upstream commit  | `6d491202cea5cf6a493ef710cbef2527b9b08939`                         |
| Source SHA-256   | `653221ca467f4732fe6856ac493f6c409e9f56a7674abe36b2364acc89796f7c` |
| License          | SIL OFL 1.1 (`assets/fonts/OFL.txt` ships alongside the faces)     |
| Roughness levels | Gentle 12.0, Playful 20.0, Expressive 28.0 (per 1,000 units)       |
| Families         | Casual, Linear, Mono Linear × 3 roughness levels                   |
| Static faces     | 126 (7 weights × 2 italics × 3 levels × 3 spacing styles)          |
| Variable faces   | 3 (`SkribbleVariable{Gentle,Playful,Expressive}`)                  |
| Generator        | `dart run packages/skribble_font_roughen/bin/roughen_fonts.dart`   |
| Files            | 130 (129 faces + `OFL.txt`)                                        |
| Registry         | `tool/asset_sources.txt`                                           |

Each static face is instanced from a finished variable font, so all 126 share the same hand-drawn displacement and stay consistent across weight, italics, and spacing.

The Gentle lean treatment uses shorter, smooth waves to keep the lettering hand-drawn. Each glyph also gets a deterministic lean of at most 0.045 degrees per strength unit, with maxima of 0.54, 0.9, and 1.26 degrees at Gentle, Playful, and Expressive. Vertical motion is 0.3 of the strength and fades to zero at the base outline's top and bottom; short punctuation gets even less vertical movement. No whole-glyph baseline bounce is added. Advance widths, kerning, and line metrics stay unchanged.

Generation is deterministic. Each glyph's index sets the phase of smooth coordinate-based waves; there is no random point jitter. Rebuilding produces byte-identical fonts. `roughen_fonts.dart --check` proves it: it builds into a temporary directory and compares every output byte against what is committed. CI runs that check on every pull request.

## Usage

```bash
flutter pub add skribble_font_recursive
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
