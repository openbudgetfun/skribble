# Skribble font roughener

Builds hand-drawn Recursive fonts as three variable roughness families and 126 dedicated static faces. Casual, Linear, and Mono Linear each have Gentle, Playful, and Expressive versions, with upright and italic weights 300 through 900.

## Build and verify

Run from repository root in the pinned development shell:

```bash
devenv shell dart run packages/skribble_font_roughen/bin/roughen_fonts.dart
devenv shell dart run packages/skribble_font_roughen/bin/roughen_fonts.dart --check
```

FontTools expands the source `gvar` point deltas before the Dart writer applies smooth waves and a deterministic tilt to the default outline. The writer preserves all expanded deltas and the point topology. This keeps the hand-drawn displacement consistent across continuous weight, casualness, spacing, and slant changes. Cursive switches letterforms. Static faces are instanced from the finished variable fonts, then receive their weight, italic flags, and family names.

Sparse variable input is rejected because moving the base outlines changes IUP inference ratios. CFF must be converted to TrueType first. Glyph coverage, layout features, and variation tables survive serialization; obsolete hint programs and signatures are removed. Repeated letters retain the same outline.

`--check` builds in a temporary directory and compares every output byte. The package owns all static and variable assets. Four legacy Expressive Casual copies stay synchronized in the tool and storybook directories. Font release archives are discovered from the package manifest and include the OFL license.

## Roughen another font

```bash
dart run skribble_font_roughen input.ttf output.ttf --jitter 27 --family MyInk
```

Strength is measured per 1,000 font units and accepts 0–50. Zero preserves geometry. The bundled levels use 18, 27, and 36. Family names accept 1–48 ASCII letters, digits, or hyphens and must start with a letter. For variable input, first use `fonttools varLib.instancer input.ttf --no-optimize --no-recalc-timestamp -o expanded.ttf`.

Tests cover malformed input, deterministic serialization, full outline coverage, preserved variation tables, intermediate instances, shaping, checksums, and weight/italic metadata for all static faces. See the documentation site's font comparison for interactive specimens and `../skribble/tool/font/VARIABLE-SOURCE.md` for source provenance.
