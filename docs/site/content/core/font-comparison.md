---
title: Compare the lettering
description: Compare original and roughened Recursive Casual, Sans Linear, and Mono at real reading sizes.
---

# Three kinds of lettering

Choose `WiredFont.casual`, `WiredFont.linear`, or `WiredFont.mono` in `WiredThemeData`. Casual remains the default. All three follow the inherited Gentle, Playful, or Expressive setting. Mono Linear provides equal character advances for code; the docs use it for syntax-highlighted examples.

```dart
// Static example: configuration
WiredThemeData(
  font: WiredFont.linear,
  roughnessLevel: WiredRoughness.playful,
)
```

To use Mono just for a code block, resolve its family against the surrounding theme:

```dart
// Static example: configuration
TextStyle(
  fontFamily: WiredFont.mono.familyFor(WiredTheme.of(context).roughnessLevel),
  package: 'skribble',
)
```

Each comparison uses the same generator, strength, weight, style, and size. Gentle uses strength 18, Playful 27, and Expressive 36 per 1,000 font units. Use **Code specimen** to compare aligned text, or type your own sample. On narrow screens the three specimens stack within each roughness level.

## How the handwriting is made

The generator reads the actual TrueType glyph outlines and moves their points with smooth waves and a small, deterministic tilt. Nearby points move together, preserving the relationship between a stroke and its counter. This changes the letter shapes themselves. It does not add a blur or a raster texture. Repeated occurrences of a character use the same outline.

Character mappings, advance widths, kerning, and shaping tables are retained. The original row loads untouched fonts with their hinting; roughened fonts have new outlines and remove obsolete source hinting. Both changes contribute to the visual difference.

## Experimental lettering

A separate Casual and coding-font experiment is available through `dart run tool/casual_font_experiment.dart`, followed by `dart run tool/font_exploration_specimen.dart --serve`. Run these from repository root with FontForge installed. Outputs go to `.screenshots/font-exploration/`; the shipped font families stay unchanged.

The `SkribblePetal` prototype adds a looped ascender, text ligatures, and optional swashes. `SkribbleCode` derives from Recursive's dedicated Code Casual release and preserves its fixed-width cells and `calt` programming ligatures. Both have four real styles. These are experiments for comparison, not yet package font choices. See `docs/research/font-exploration.md` for reproduction, coverage limits, shaping verification, and editor settings.

The existing Regular and Bold Casual fonts have optional programming substitutions under `dlig`, but no standard `liga` text feature. Italic and Bold Italic inherit `fi` and `ffi`. Existing Mono derives from the desktop Linear source and also requires `dlig` for optional code substitutions. Requesting a feature tag only activates rules already present in the selected font.

## Weights and variable fonts

The current output is **static TrueType**, with four real faces for every family and roughness:

| Face        | Weight | Style   |
| ----------- | ------ | ------- |
| Regular     | 400    | Upright |
| Bold        | 700    | Upright |
| Italic      | 400    | Italic  |
| Bold italic | 700    | Italic  |

There are no dedicated Light, Semibold, or Extra Bold files, and no continuous weight axis. Requesting another weight does not produce the corresponding Recursive source design.

A variable hand-drawn font is possible in principle, but requires a pipeline that preserves or rebuilds the variation data and checks interpolated outlines. The current writer deliberately rejects variable input. Adding more genuine static weights from Recursive would be a smaller extension. This release keeps the approved four-face approach.

## Reproduce the comparison

Run from the repository root:

```bash
dart run packages/skribble_font_roughen/bin/roughen_fonts.dart
dart run tool/docs_font_comparison.dart
```

Add `--check` to either command to verify without writing. All 36 modified faces live in the Skribble package. The docs keep only the 12 unmodified originals for comparison; modified Linear files are no longer duplicated there. These are vector font files, but adding families still increases the package asset size. The OFL license and pinned Recursive 1.085 source provenance are retained with the fonts.
