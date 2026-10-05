# skribble emoji art

Every emoji in `skribble_emoji` is drawn for skribble, in this folder, as a small SVG. The generator compiles the SVGs into Dart, and the app inks them live with the theme pen: outlines taper and swell, fills sit a hair off the line like marker, and the whole drawing wavers with the theme's roughness. Draw clean geometry. The hand-drawn feel comes from the renderer, not from wobbly paths.

## The file

- One emoji per file. The file name is the **art key**: the Unicode short name in kebab case (`smiling-face-with-heart-eyes.svg`). Gendered emoji share one file named after the concept (`technologist.svg` draws the person, man, and woman technologist). Flags are `flag-<iso>.svg`; keycaps are `keycap-<key>.svg`.
- Put files in the folder for their Unicode group: `smileys`, `people`, `animals`, `food`, `travel`, `activities`, `objects`, `symbols`, `flags`. Reusable pieces go in `shared`.
- Root element, always:

  ```xml
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 36 36" stroke-linecap="round" stroke-linejoin="round">
  ```

- Elements: `path`, `circle`, `ellipse`, `rect` (give both `rx` and `ry`), `line`, `polyline`, `polygon`, `g`, `clipPath` in `defs`. Transforms are fine. No gradients, filters, masks, text, opacity, or `use`.

## Colour

Paint with **tokens**, never hex (flags are the only exception). Tokens let one drawing serve every skin tone and let apps restyle the whole set.

| Token                                                                | Use                                                     |
| -------------------------------------------------------------------- | ------------------------------------------------------- |
| `ink`                                                                | Every outline and dark detail.                          |
| `paper`                                                              | Eye whites, teeth, glints, highlights.                  |
| `white`, `black`                                                     | Snow, clouds, keys, fur, night.                         |
| `yellow` / `yellow-shade`                                            | Faces, stars, sunshine, gold.                           |
| `orange` / `orange-shade`, `red` / `red-shade`, `coral`              | Warm things: fire, fruit, hearts.                       |
| `pink` / `pink-shade`, `magenta`, `purple` / `purple-shade`, `lilac` | Flowers, sweets, magic.                                 |
| `blue` / `blue-shade`, `sky`, `teal`                                 | Water, ice, glass, clothes.                             |
| `green` / `green-shade`, `leaf`, `lime`, `mint`                      | Plants, nature.                                         |
| `brown` / `brown-shade`, `tan`, `cream`                              | Wood, bread, earth, animals.                            |
| `grey` / `grey-shade`, `silver`                                      | Metal, stone, machines.                                 |
| `cheek`                                                              | Blush on happy faces.                                   |
| `skin` / `skin-shade`, `hair`                                        | The person. Never colour a person's skin any other way. |
| `skin2` / `skin2-shade`, `hair2`                                     | The second person in two-person emoji.                  |

Faces in Smileys & Emotion are always `yellow`, never `skin`: they do not take skin tones.

## Line

| Width         | For                                                       |
| ------------- | --------------------------------------------------------- |
| `2` (default) | The main silhouette.                                      |
| `1.75`        | Secondary shapes and people.                              |
| `1.5`         | Interior details: folds, seams, whiskers, small features. |
| `1.25`        | The smallest details. Never thinner than `1`.             |

Outlines use `stroke="ink"`. Coloured strokes (a red stripe, a white tick) are fine for marks that are part of the design.

## Layering and volume

Paint order is document order. Give big shapes volume with one shade, drawn _between_ the fill and the outline so the ink stays on top:

```xml
<circle cx="18" cy="18" r="15" fill="yellow"/>
<path d="…crescent on the lower right…" fill="yellow-shade"/>
<circle cx="18" cy="18" r="15" fill="none" stroke="ink"/>
```

- Light comes from the upper left. Shade sits on the lower right, as a crescent hugging the edge. One shade per big shape; small shapes need none.
- Glossy things (hearts, balls, bottles) may get one short `paper` stroke highlight on the upper left, `stroke-width="1.75"`, no fill.
- Shapes with no shade can carry fill and stroke on one element: `fill="green" stroke="ink"`.

## Composition

- Draw inside `2–34`. The subject should fill about 28–32 units of the square, centred, so every emoji reads at the same size.
- Fewer shapes read better. Aim for 3–15 elements. Every emoji must be recognisable at **24 pixels**, so prefer a bold silhouette and two or three telling details over many small ones.
- Charm over accuracy: friendly proportions, rounded corners, a little personality (a glint in an eye, a sticker on a laptop). Never mean, never gory.
- Things that face a direction face **left** unless Unicode or common emoji convention says otherwise. "Facing right" emoji are mirrored automatically.

## Parts

Name groups that could move: `<g id="eyes">`, `mouth`, `brows`, `hand`, `tail`, `wings`, `flame`, `tears`, `hair`. On a single element use `data-part="mouth"`. Animations later move, turn, and scale parts as rigid groups, so put each movable thing in its own part and keep its pieces together.

## Shared pieces

Include another drawing with `<g data-include="key"/>`. The include's transform applies to the included shapes.

- **`face`**: the yellow smiley face with its shade and outline. Every face emoji starts with it. Standard eyes are ellipses at `(12.6, 13.8)` and `(23.4, 13.8)`, `rx="1.9" ry="2.7"`, with `paper` glints `r="0.6"` offset up-right. Mouths centre on `x = 18` around `y = 20–28`.
- **`head`**: a person's head at `(18, 13.6)`, radius `7.4`, with eyes, blush, a smile, and three hair variants. People art draws the neck and body first, includes the head, then draws props on top.
- **`keycap`**: the key for keycap emoji; draw the glyph in `x 8–28, y 7–25`.

### Variants

Gendered emoji share one drawing. The included `head` already switches hair between person, man, and woman. When something else differs (a beard, a dress), give it `data-variant="man"`, `"woman"`, or `"person"`; unmarked shapes always draw.

To include a head as one fixed variant, as families and couples need, add `data-as`: `<g data-include="head" data-as="woman" transform="…"/>`.

### Two people

The second person uses the `2` tokens. Remap them on the include:

```xml
<g data-include="head" data-as="man" data-tokens="skin:skin2,skin-shade:skin2-shade,hair:hair2" transform="translate(7 2) scale(0.8)"/>
```

### Flags

Flag files set `data-warp="flag"` on the root and draw the flat flag in the rectangle `x 2–34, y 8–28` with **hex colours** from the official flag. The generator waves the cloth, clips the design to it, and adds the outline. Simplify coats of arms to a recognisable emblem in a few shapes.

## Checking your work

From `packages/skribble_emoji`:

```bash
EMOJI_GALLERY=animals flutter test test/art_gallery_test.dart
```

renders contact sheets to `.screenshots/emoji/` at the repository root: each drawing at 72 and 24 pixels, with skin tones or variants beside it. `EMOJI_GALLERY` takes `all`, a folder name, or comma-separated art keys. The same test fails on any art that breaks these rules.

Before you call a drawing done:

- It is recognisable at 24 pixels.
- Outlines are `ink`, at the widths above, never under `1`.
- It fills the square like its neighbours and sits centred.
- Shade is on the lower right, under the outline.
- People use `skin` and `hair`; second people use the `2` tokens.
- Movable things are named parts.
