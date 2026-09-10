# skribble_font_roughen

Creates digitally hand-lettered derivatives of **Recursive Sans Casual, Sans Linear, and Mono Linear**. Every bundled typeface includes Regular (400), Bold (700), Italic (400), and Bold Italic (700), generated from the corresponding static Recursive styles. It retains the source's character coverage, spacing, and shaping features.

The generator modifies the actual TrueType `glyf` outlines, including compound glyphs. It applies a gentle continuous displacement and a small glyph-dependent tilt. Moving neighboring points together keeps counters open and curves readable; independently scattering points produces broken joins and noisy letters.

## Generate the bundled family

From the repository root, inside `devenv shell`:

```bash
dart run packages/skribble_font_roughen/bin/roughen_fonts.dart
dart run packages/skribble_font_roughen/bin/roughen_fonts.dart --check
dart run tool/font_specimen.dart
```

The first command writes all 36 faces (three typefaces × three roughness levels × four styles) to the package font directory. Legacy Expressive Casual copies also stay synchronized in the tool and storybook directories. `--check` regenerates in memory and fails if any bundled copy differs. Each style has 1,297 nonempty outlined glyphs; empty glyphs such as spaces remain empty. The HTML specimens are saved under `.screenshots/font/`. Open them in a browser and inspect the rendered fonts at 12–48 px.

## Roughen another static TrueType font

```bash
dart run skribble_font_roughen input.ttf output.ttf --jitter 36 --variant regular
```

`--jitter` ranges from 0 to 50 and is measured per 1,000 units per em; the default is 36. This doubles the previous default's deformation for visibly less regular stems, bowls, and letter angles. Zero leaves the geometry unchanged. This is normalized to the source font's em, not the temporary display size of a glyph.

Use a matching source weight and style for each output. `--variant bold` names the output; it does not manufacture a bold weight from a regular source.

```dart
final result = await FontRoughener(
  inputPath: 'RecursiveSansCslSt-Regular.ttf',
  outputPath: 'Skribble-Regular.ttf',
).roughen();
```

## Format and verification

Supported inputs are static TrueType fonts with `glyf` and `loca` tables. Variable fonts and CFF/OpenType outlines must first be converted to static TrueType; unsupported inputs fail explicitly. The writer preserves `cmap`, horizontal metrics, kerning, and OpenType layout tables. It regenerates outlines, locations, bounds, naming metadata, and checksums, and removes stale hinting programs and signatures.

The bundled-font tests reparse every output, check every outlined glyph changed, bound the deformation, verify checksums and preserved tables, compare deterministic rebuilds, and exercise malformed input. This is a static font family: repeated occurrences of a letter have the same outline, as in the source. It does not simulate a different pen motion on every keystroke.

`VisualDiff` creates a self-contained HTML comparison with embedded fonts and counts changed outline points. Its statistics are **not** a perceptual or pixel-similarity score. Image extensions are rejected instead of producing placeholder screenshots.

```bash
cd packages/skribble_font_roughen
dart test
```

Recursive is by Arrow Type, under the SIL Open Font License 1.1. The derivative is named Skribble. Keep the bundled OFL notice when redistributing the fonts. Sources: [Recursive releases](https://github.com/arrowtype/recursive/releases), [TrueType glyph specification](https://learn.microsoft.com/en-us/typography/opentype/spec/glyf).

## Roughness levels and custom families

The bundled generator now writes Gentle (18), Playful (27), and Expressive (36), each in all four styles. The extra families live in the main library assets; existing Expressive copies remain synchronized for compatibility. Run the same command with `--check` to detect stale files.

For custom strengths, use `--jitter 23.5 --family MyInk` or `FontRoughener(jitterAmount: 23.5, familyName: 'MyInk', ...)`. Family names use 1–48 ASCII letters, digits or hyphens and start with a letter. The font remains static, with preserved advance widths and shaping.
