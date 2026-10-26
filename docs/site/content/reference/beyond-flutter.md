---
title: Beyond Flutter
description: Use skribble fonts and editable pen specimens outside Flutter, with separate font and SVG icon pipelines.
---

# Beyond Flutter

skribble is becoming a standalone Flutter design system. Its font files and static pen geometry can already be used in other design tools and platforms. Start with the [design kit](design-kit) for Figma installation, font names, tokens, editable SVG specimens, and motion rules.

For websites built with [Jaspr](https://jaspr.site), `skribble_jaspr` renders hand-drawn components on the server, and the pure-Dart `skribble_rough` engine writes rough shapes as SVG path data anywhere Dart runs. See [Using skribble on Jaspr](../guides/jaspr).

For JavaScript projects, `@skribble.dev/rough` is a TypeScript port of the same engine that draws byte-identical SVG, with components for React, React Native, Vue, and Svelte. See [Using skribble from JavaScript](../guides/javascript).

For Rust, `skribble_rough` is a port of the same engine that draws byte-identical SVG, and `skribble_leptoskit` builds hand-drawn components on it for [leptoskit](https://github.com/ifiokjr/leptoskit) apps on the web and native platforms. See [Using skribble with leptoskit](../guides/leptoskit).

## Use the bundled fonts

The kit includes the default Skribble Noto Sketch face, the Soft and Lively Noto levels, and the Regular, Bold, Italic, and Bold Italic faces of every Recursive family. For a web page using the default Noto Sketch lettering:

```css
@font-face {
  font-family: 'SkribbleNotoSketch';
  src: url('fonts/SkribbleNotoSketch-Regular.ttf') format('truetype');
  font-weight: 400;
  font-style: normal;
}

body {
  font-family: 'SkribbleNotoSketch', sans-serif;
}
```

Noto Sketch has one Regular face, so leave `font-synthesis` on for bold and italic. It covers Latin, Greek, and Cyrillic; add files from the Skribble Noto Sketch font kit on the [GitHub release](https://github.com/openbudgetfun/skribble/releases/latest) for other scripts, such as `SkribbleNotoSketchJP` or `SkribbleNotoSketchArabic`, and list them after it in `font-family`.

Native platforms can bundle the same TTF files. Use the PostScript names in the kit's `manifest.json` where the platform requires them, such as `SkribbleNotoSketch-Regular` for `UIFont`. For a Recursive family, keep all four faces together, set `font-synthesis: none`, and retain the OFL notice.

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

Use the resulting SVG as an image, or import its paths into a design file. Preserve its declared view box. For component borders and selected-state ink, use `dart run packages/skribble/tool/design_kit.dart`; those specimens come from skribble's Dart rough engine.

## Scope and licenses

Static assets do not implement interaction, accessibility, layout, or native framework components. The current supported UI library is Flutter. This guide does not promise React Native, SwiftUI, Compose, or web component packages.

skribble source code and generated design-kit pen specimens use MIT. Recursive-derived TTF files use SIL OFL 1.1; redistribute the accompanying `OFL.txt`. skribble's own emoji and glyph art is MIT too. Third-party icon sets retain their source notices. Review the notices distributed with the asset set you use; the source-code license does not replace them.
