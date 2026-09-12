# Skribble design kit

The [editable Figma file](https://www.figma.com/design/pjRi0rh4NWkGRROPlWLLBo/Skribble-Design-System) pairs the Flutter library with warm paper, plum ink, reusable components, and seeded flourishes.

You can also download the [editable `.fig` source](../../assets/design/skribble-design-system.fig) from the repository and open it in the Figma desktop app.

## How the file is organized

Start on `✨ Start here`. It explains the reading order and includes three reusable guide components: `📌 Component anatomy`, `💡 Usage callout`, and `🌿 Flourish tile`. The working pages then follow a short path:

1. `🎨 Foundations` — paper, ink, palette, type, spacing, and roughness.
2. `📌 Brand` — the bracketed smile, light and dark marks, and logo usage.
3. `🌿 Flourishes` — the core hand-drawn vocabulary.
4. `🌈 More flourishes` — twelve additional kinds, each shown with three seeded variants.
5. The `· Wired` pages — reusable component sets grouped by interaction and surface.

The `🗂️ Archive · …` pages come last and preserve the older explorations without competing with the current guide. Archive boards have been translated into positive canvas space and reflowed where needed, so their original work remains inspectable without covering nearby frames.

Long notes use fixed reading widths and height-based text resizing. This keeps guidance visible at normal zoom and prevents copy from sitting on top of examples.

## Brand and flourishes

The refined logo preserves Ifiok Jr.'s smile inside square brackets. It uses fewer overlapping strokes, round pen endings, and generous space around the face. Light, dark, lilac, and transparent SVG variants live in `assets/brand`. The browser favicon has a stronger pen for small sizes.

Nineteen flourishes have three exported seed samples each. Flutter accepts any integer seed. The same pure Dart cubic geometry produces both the widget paths and the SVG artwork. Scribbles vary their angle and loop count with the seed; the other marks keep their silhouette while receiving a smooth, repeatable ink wobble:

```sh
devenv shell dart run packages/skribble/tool/export_design_assets.dart
```

`geometry.json` contains control outlines exported from the actual rough engine, with gentle, playful, and expressive settings. Figma paths are editable. Figma's text styles use the original Recursive Sans Casual source face; the Flutter families contain generated outline variation. Install the bundled fonts when preparing final text assets where that variation matters.

## Theme and component feedback

`WiredThemeData.cuddly()` applies the palette used by the kit. `Brightness.dark` selects dark plum paper and pale ink. Accent washes are exposed through `WiredPalette`. Existing default theme values remain compatible.

Inputs, checkboxes, and cards now have rounded ink corners by default, with configurable `borderRadius`. Use `BorderRadius.zero` for square corners. The three roughness settings remain independent of color.

Flourishes ignore pointer events, remain seed-stable, and are silent to assistive technology unless they have an explicit label. They use the existing cached ink renderer and reduced-motion policy.

## Attribution and license

The original logo and reference sketches were designed by Ifiok Jr. The refined brand and new generated flourishes are part of Skribble under the repository's MIT license. Recursive fonts retain their bundled OFL license.
