---
title: Beyond Flutter
description: Use Skribble fonts and editable pen specimens outside Flutter, with separate font and SVG icon pipelines.
---

# Beyond Flutter

Skribble is becoming a standalone Flutter design system. Its font files and static pen geometry can already be used in other design tools and platforms. Start with the [design kit](design-kit) for Figma installation, font names, tokens, editable SVG specimens, and motion rules.

## Use the bundled fonts

The kit includes the actual Regular, Bold, Italic, and Bold Italic faces for every bundled family. For a web page using the default Expressive Casual family:

```css
@font-face {
  font-family: 'Skribble';
  src: url('fonts/Skribble-Regular.ttf') format('truetype');
  font-weight: 400;
  font-style: normal;
}

@font-face {
  font-family: 'Skribble';
  src: url('fonts/Skribble-Bold.ttf') format('truetype');
  font-weight: 700;
  font-style: normal;
}

@font-face {
  font-family: 'Skribble';
  src: url('fonts/Skribble-Italic.ttf') format('truetype');
  font-weight: 400;
  font-style: italic;
}

@font-face {
  font-family: 'Skribble';
  src: url('fonts/Skribble-BoldItalic.ttf') format('truetype');
  font-weight: 700;
  font-style: italic;
}

body {
  font-family: 'Skribble', sans-serif;
  font-synthesis: none;
}
```

Native platforms can bundle the same TTF files. Use the PostScript names in the kit's `manifest.json` where the platform requires them, such as `Skribble-Regular` for `UIFont`. Keep all four faces together and retain the OFL notice.

## Generate a derived font

Run this from the repository root inside `devenv shell`. The source must be a static TrueType font with `glyf` and `loca` tables:

```bash
mkdir -p build/font-example
dart run packages/skribble_font_roughen/bin/skribble_font_roughen.dart \
  packages/skribble/tool/font/RecursiveSansCslSt-Regular.ttf \
  build/font-example/MyInk-Regular.ttf \
  --jitter 27 --variant regular --family MyInk
```

`--jitter` accepts 0 through 50, measured per 1,000 units per em. The default is 36. A variant names the output; use a matching source style to get real bold or italic outlines. Variable fonts and CFF outlines require conversion to static TrueType first. This CLI does not accept SVG files or icon directories.

For the complete bundled family, run `dart run packages/skribble_font_roughen/bin/roughen_fonts.dart`, then repeat with `--check` to verify committed assets and font notices.

## Export rough SVG icons

The icon pipeline is separate. Run this from the repository root inside `devenv shell`, with Deno and Chrome or Chromium installed:

```bash
dart run packages/skribble/tool/generate_rough_icons.dart \
  --kit svg-manifest \
  --manifest packages/skribble_icons_custom/tool/custom_icons.manifest.json \
  --rough-output-dir build/icon-example/svg \
  --rough-cli packages/skribble/tool/deno/svg2roughjs_cli.ts \
  --rough-only
```

The manifest maps identifiers and codepoints to source SVG files. `--rough-only` emits SVG files and skips the Dart map. Icon fonts are generated only when font output options are supplied. The wrapper downloads its pinned JavaScript dependencies on first use. See [custom icons](../guides/custom-icons) for manifest fields, prerequisites, and icon font options.

Use the resulting SVG as an image, or import its paths into a design file. Preserve its declared view box. For component borders and selected-state ink, use `dart run packages/skribble/tool/design_kit.dart`; those specimens come from Skribble's Dart rough engine.

## Scope and licenses

Static assets do not implement interaction, accessibility, layout, or native framework components. The current supported UI library is Flutter. This guide does not promise React Native, SwiftUI, Compose, or web component packages.

Skribble source code and generated design-kit pen specimens use MIT. Recursive-derived TTF files use SIL OFL 1.1; redistribute the accompanying `OFL.txt`. Icon sets retain their source notices, and OpenMoji artwork uses its own CC BY-SA 4.0 terms. Review the notices distributed with the asset set you use; the source-code license does not replace them.
