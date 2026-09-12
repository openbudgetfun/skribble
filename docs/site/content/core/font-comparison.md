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

Every Casual, Linear, and Mono family includes dedicated upright and italic files at 300 (Light), 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold), 800 (ExtraBold), and 900 (Black). Select these through `TextStyle.fontWeight` and `fontStyle` as usual.

The three shared variable families, one per roughness level, contain all these weights and continuous style axes. The playground compares a variable specimen against the nearest dedicated static face. Weight buttons set exact 100-step values; sliders allow intermediate values. Cursive uses three choices because Recursive switches letterforms rather than blending them continuously.

| Axis   | Range     | Purpose                            |
| ------ | --------- | ---------------------------------- |
| `wght` | 300–900   | Light through Black                |
| `CASL` | 0–1       | Linear through Casual              |
| `MONO` | 0–1       | Proportional through fixed-width   |
| `slnt` | −15–0     | Slanted through upright            |
| `CRSV` | 0, 0.5, 1 | Roman, automatic, or cursive forms |

```dart
// Static example: configuration
TextStyle(
  fontFamily: WiredFont.variableFamilyFor(WiredRoughness.playful),
  package: 'skribble',
  fontVariations: const [
    FontVariation('wght', 575),
    FontVariation('CASL', 0.7),
    FontVariation('MONO', 0),
    FontVariation('slnt', -8),
    FontVariation('CRSV', 0.5),
  ],
)
```

Import `FontVariation` from `dart:ui`. Set `wght` explicitly when using a variable family. Its default is 400, with linear proportional forms. Casual uses `CASL=1, MONO=0`; Mono Linear uses `CASL=0, MONO=1`. Static italics use `slnt=-15, CRSV=1`. The variable font can also show upright cursive forms and intermediate casualness or spacing.

The pipeline expands sparse variation deltas before deforming the default outlines. It preserves those explicit deltas and point topology, so the displacement stays consistent across the designspace. It then instances the finished variable font to produce every static face. This changes the former static-only roughening baseline; existing 400/700 faces are regenerated from the same design as the new weights. All source layout features and variation axes are retained, with weight restricted from Recursive's 300–1000 source range to 300–900.

Sources: [Recursive axes and licensing](https://github.com/arrowtype/recursive), [FontTools instancing](https://fonttools.readthedocs.io/en/latest/varLib/instancer.html). The pinned source, checksum, and reproduction notes are in `packages/skribble/tool/font/VARIABLE-SOURCE.md`.

## Reproduce the comparison

Run from the repository root:

```bash
devenv shell dart run packages/skribble_font_roughen/bin/roughen_fonts.dart
dart run tool/docs_font_comparison.dart
```

Add `--check` to either command to verify without writing. All 126 static faces and three variable fonts live in the Skribble package. The docs keep only the 12 unmodified originals for comparison; modified Linear files are no longer duplicated there. These are vector font files, but adding families still increases the package asset size. The OFL license and pinned Recursive 1.085 source provenance are retained with the fonts.
