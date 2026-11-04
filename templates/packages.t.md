<!-- The published Dart packages and the bundled typefaces. Links use
     pub.dev so the same text works in the root README, package READMEs on
     pub.dev, and the docs site. -->

<!-- {@docsPackageCatalog} -->

| Package                                                                           | What it adds                                                                                 |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| [`skribble`](https://pub.dev/packages/skribble)                                   | The Wired widgets, `SkribbleApp`, the theme, and the Flutter painting layer. Start here.     |
| [`skribble_font_noto_sketch`](https://pub.dev/packages/skribble_font_noto_sketch) | Skribble Noto Sketch, the default hand-drawn lettering                                       |
| [`skribble_font_noto`](https://pub.dev/packages/skribble_font_noto)               | Skribble Noto Soft, the calmest Noto level                                                   |
| [`skribble_font_noto_lively`](https://pub.dev/packages/skribble_font_noto_lively) | Skribble Noto Lively, the most playful Noto level                                            |
| [`skribble_font_recursive`](https://pub.dev/packages/skribble_font_recursive)     | Roughened Recursive Casual, Linear, and Mono, which follow the roughness level               |
| [`skribble_icons`](https://pub.dev/packages/skribble_icons)                       | Every icon set behind one import, with a unified lookup                                      |
| [`skribble_icons_material`](https://pub.dev/packages/skribble_icons_material)     | Flutter's Material icons as hand-drawable geometry                                           |
| [`skribble_icons_lucide`](https://pub.dev/packages/skribble_icons_lucide)         | Lucide outline icons                                                                         |
| [`skribble_icons_bxs`](https://pub.dev/packages/skribble_icons_bxs)               | Boxicons Solid icons                                                                         |
| [`skribble_icons_simple`](https://pub.dev/packages/skribble_icons_simple)         | Simple Icons brand marks                                                                     |
| [`skribble_icons_cib`](https://pub.dev/packages/skribble_icons_cib)               | CoreUI Brands marks                                                                          |
| [`skribble_emoji`](https://pub.dev/packages/skribble_emoji)                       | skribble's own hand-drawn emoji for every Unicode emoji                                      |
| [`skribble_maps`](https://pub.dev/packages/skribble_maps)                         | MapLibre maps with hand-drawn pins, routes, areas, and controls                              |
| [`skribble_charts`](https://pub.dev/packages/skribble_charts)                     | Exact OHLC data, hand-drawn financial charts, indicators, and drawing tools                  |
| [`skribble_rough`](https://pub.dev/packages/skribble_rough)                       | The pure-Dart rough engine, with SVG path output and no Flutter dependency                   |
| [`skribble_jaspr`](https://pub.dev/packages/skribble_jaspr)                       | Server-rendered hand-drawn components for Jaspr sites                                        |
| [`skribble_font_roughen`](https://pub.dev/packages/skribble_font_roughen)         | A command-line tool that roughens your own fonts                                             |
| [`skribble_emoji_gen`](https://pub.dev/packages/skribble_emoji_gen)               | The generator that compiles emoji, glyph art, and icon sets into Dart catalogs (maintainers) |
| [`skribble_lints`](https://pub.dev/packages/skribble_lints)                       | Shared lint rules, extending `very_good_analysis`                                            |

<!-- {/docsPackageCatalog} -->

<!-- The bundled typefaces. `WiredFont` and `WiredRoughness` in
     packages/skribble own the family names. -->
<!-- {@docsTypefaceTable} -->

| Typeface                                  | Package                     | Select with                                                  | Follows the roughness level |
| ----------------------------------------- | --------------------------- | ------------------------------------------------------------ | --------------------------- |
| Skribble Noto Sketch (default)            | `skribble_font_noto_sketch` | nothing: it is the default, or `WiredFont.notoSketch`        | No                          |
| Skribble Noto Soft                        | `skribble_font_noto`        | `WiredThemeData(font: WiredFont.noto)`                       | No                          |
| Skribble Noto Lively                      | `skribble_font_noto_lively` | `WiredThemeData(font: WiredFont.notoLively)`                 | No                          |
| Recursive Casual, Linear, and Mono (code) | `skribble_font_recursive`   | `WiredThemeData(font: WiredFont.casual)`, `.linear`, `.mono` | Yes                         |

Install the package for each typeface you select; every package bundles its own font files, so it works offline. The Skribble Noto packages cover Latin, Greek, and Cyrillic in one Regular face, and Flutter synthesizes bold and italic. Recursive has seven real weights with italics. An explicit `fontFamily` on `WiredThemeData` overrides the choice.

<!-- {/docsTypefaceTable} -->
