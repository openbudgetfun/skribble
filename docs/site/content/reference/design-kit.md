---
title: Design kit
description: Fonts, editable SVG pen specimens, design tokens, and the ink motion contract for design handoff.
---

# Design kit

Use the same fonts and rough geometry in a design file that Skribble uses in Flutter. Generate the kit from the repository root:

```bash
devenv shell dart run packages/skribble/tool/design_kit.dart
```

Open `build/design-kit/index.html` to compare all bundled fonts and pen specimens. The directory contains actual TTF files, their OFL notice, editable SVGs, a JSON manifest with dimensions and font names, and this guide. It works offline. To share the complete kit:

```bash
cd build
zip -r skribble-design-kit.zip design-kit
```

The exporter copies the committed fonts without modifying or regenerating them. Regenerate the kit after changing the source fonts or rough engine. It uses the engine's drawing operations directly and requires no Figma account or Material widget runtime.

## Fonts for Figma

The default family is `Skribble`, derived from Recursive Sans Casual. All families include these four real styles:

| Style       | Filename suffix   | Weight | PostScript name for the default family |
| ----------- | ----------------- | ------ | -------------------------------------- |
| Regular     | `-Regular.ttf`    | 400    | `Skribble-Regular`                     |
| Bold        | `-Bold.ttf`       | 700    | `Skribble-Bold`                        |
| Italic      | `-Italic.ttf`     | 400    | `Skribble-Italic`                      |
| Bold Italic | `-BoldItalic.ttf` | 700    | `Skribble-BoldItalic`                  |

The kit includes 36 files, covering the current Casual, Linear, and Mono families at all three roughness levels. Install all four styles of each family you use. Do not simulate bold or italic from the regular face.

| Typeface | Gentle                 | Playful                 | Expressive                 |
| -------- | ---------------------- | ----------------------- | -------------------------- |
| Casual   | `SkribbleGentle`       | `SkribblePlayful`       | `Skribble`                 |
| Linear   | `SkribbleLinearGentle` | `SkribbleLinearPlayful` | `SkribbleLinearExpressive` |
| Mono     | `SkribbleMonoGentle`   | `SkribbleMonoPlayful`   | `SkribbleMonoExpressive`   |

For local editing, install the TTF files in Font Book on macOS or Fonts on Windows. Browser users also need Figma's font installer. Reload the file or restart Figma after installation.

For MCP and Figma agent, upload the files to your Figma account. In the file browser, open your avatar menu, choose **Settings**, then **Account > Your uploaded fonts > Upload fonts**. Select the required styles and complete the rights confirmation. Check **Uploaded by you** in the font picker. Local installation alone does not provide remote access. These steps follow [Figma's font instructions](https://help.figma.com/hc/en-us/articles/360039956894-Add-a-font-to-Figma), checked on 10 September 2026.

Before handoff, render `Café, piñata, £12.50, €42` in Regular, Bold, Italic, and Bold Italic. Confirm the family and style in the font picker. Coverage follows the Recursive source fonts; add a suitable fallback when using unsupported scripts.

## Pen and type reference

One SVG unit corresponds to one Flutter logical pixel. These are defaults, not restrictions on custom themes.

| Token                   | Value or rule                                                                                                        |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------- |
| Pen                     | 2.4 px; round caps and joins                                                                                         |
| Default outline         | `#1A2B3C`                                                                                                            |
| Default fill            | `#FEFEFE`; specimens leave unfilled interiors transparent                                                            |
| Default text            | Black                                                                                                                |
| Stable geometry         | Seed 1; reset the generator for each drawing. Keep seed and bounds fixed across repaints and press states            |
| Gentle                  | Roughness 1.25; offset 1.2; line wobble 0; font deformation strength 18 at 1,000 units/em                            |
| Playful                 | Roughness 1.5; offset 1.6; line wobble 0.65; font deformation strength 27 at 1,000 units/em                          |
| Expressive, default     | Roughness 1.8; offset 2; line wobble 1; font deformation strength 36 at 1,000 units/em                               |
| Reserved bleed per edge | `strokeWidth / 2 + 1 + maxRandomnessOffset * roughness`: 3.7 / 4.6 / 5.8 px for the three presets                    |
| Divider ink extent      | Twice the bleed: 7.4 / 9.2 / 11.6 px                                                                                 |
| Lettering               | Static outlines. Repeated letters retain the same shape; geometry roughness and font deformation use different units |

See the [theme system](https://openbudgetfun.github.io/skribble/core/theme-system) for overrides and the [motion guide](https://openbudgetfun.github.io/skribble/core/motion) for animation ownership.

## Editable specimens and layout

Import SVGs from `specimens/`. Each file has an `ink` group containing editable paths and a separate, invisible `layout-bounds` rectangle. Some importers discard invisible geometry. Use the root SVG size or `manifest.json` to recreate the layout frame. Do not shrink the hit region to the visible stroke bounds.

| Specimen            | Layout frame   | Ink box before bleed     | Meaning                                                                          |
| ------------------- | -------------- | ------------------------ | -------------------------------------------------------------------------------- |
| Button              | 160 × 48       | 160 × 42, y = 3          | Current 42 px button ink height and 6 px corners inside a suggested 48 px target |
| Button pressed      | Same as button | Same geometry and seed   | Pen width reaches 3 px, or 125 percent                                           |
| Field               | 280 × 56       | Full frame               | Square field outline; actual input height depends on content                     |
| Card                | 280 × 130      | Full frame               | Unfilled card outline at its current default height                              |
| Focus ring          | 168 × 56       | Full frame, 8 px corners | Suggested outer ring around the button frame; custom design treatment            |
| Selected navigation | 72 × 80        | 56 × 28 at x = 8, y = 17 | Current destination and indicator sizes, 14 px corners, hatching with gap 2      |

These are pen specimens, not complete widget exports. They contain no text, icons, semantics, or layout engine. Field width, button width, the 48 px button target, and focus ring placement are handoff choices. The current `WiredButton` does not automatically enlarge its hit region to 48 px. Add adequate target space in the consuming layout. Focus treatment is a proposal for custom controls, not a new library-wide focus API.

Add labels as editable text after loading the fonts. Preserve the ink's aspect ratio; rerun the generator with revised specimen dimensions when a different size is needed. Stretching an exported path also stretches its pen and wobble.

## Motion and reduced motion

| State                             | Contract                                                                | Static equivalent                                                  |
| --------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Rest                              | Completed ink with stable seed                                          | `*-button.svg`                                                     |
| Press                             | 120 ms ink pressure response; up to 25 percent stronger pen             | `*-button-pressed.svg`                                             |
| Entry reveal                      | `WiredDraw` defaults to a 650 ms draw on entry; replay must be explicit | Completed specimen for that control                                |
| Reduced motion or disabled motion | Completed ink with decorative pressure suppressed                       | Same resting SVG; `reducedMotionFile` in the manifest points to it |

Keep label position, layout, and hit regions fixed. Do not add scale, bounce, or a fresh random seed on press. Reveal applies to outlines and patterned fills; labels, semantics, and solid backgrounds remain available. Focus and selected state must remain distinguishable when decorative motion is disabled. A reduced-motion specimen deliberately reuses the resting paths rather than maintaining another copy.

## Notices

The TTF files derive from Recursive and use the SIL Open Font License 1.1. Keep `fonts/OFL.txt` with redistributed fonts. The source notice names The Recursive Project Authors. Skribble source code and these generated pen specimens use the repository MIT license included as `LICENSE`. This kit contains no third-party icon or emoji artwork.

## Screenshot selection

Use the current documentation font comparison and newly verified notebook captures as visual references. Archived `.screenshots/inputs/` captures may predate the font fixes and show missing-glyph boxes. They are local historical artifacts, not public documentation assets. Check the rendered glyphs, theme, viewport, and settled first frame before publishing a screenshot. See [screenshot guidance](https://openbudgetfun.github.io/skribble/guides/screenshots).
