/// The base stylesheet for skribble's Jaspr components.
///
/// Put it on every page that renders wired components, either inline or as
/// a file:
///
/// ```dart
/// Document(
///   head: [Component.element(tag: 'style', children: [RawText(skribbleCss)])],
///   body: App(),
/// )
/// ```
///
/// It positions the SVG ink behind each component, pads content clear of
/// the ink, maps the ink to theme custom properties, and adds hover, focus,
/// reduced-motion, and forced-colors behaviour. Hover and press motion only
/// runs under `prefers-reduced-motion: no-preference`.
/// Theme a page, or any subtree, by overriding the properties:
///
/// | Property                  | Used for                                   |
/// | ------------------------- | ------------------------------------------ |
/// | `--skribble-ink`          | Outlines, pen highlights, button labels    |
/// | `--skribble-paper`        | The `.skribble-page` background            |
/// | `--skribble-accent`       | Default fills and primary buttons          |
/// | `--skribble-on-accent`    | Text on accent fills                       |
/// | `--skribble-marker`       | Marker highlights                          |
/// | `--skribble-on-marker`    | Text on a marker highlight                 |
/// | `--skribble-wash-1` … `6` | Vivid washes for colour-coding content     |
/// | `--skribble-stroke-width` | Outline width at every size                |
/// | `--skribble-font`         | Button labels and `.skribble-page`         |
///
/// Components also read `--skribble-fill` (set by their `fill` argument)
/// and `--skribble-highlight` (set by `WiredHighlight.color`). The classes
/// `skribble-wash-1` to `skribble-wash-6` set `--skribble-fill` to one of
/// the washes, so `WiredBox(fillStyle: RoughFillStyle.solid, classes:
/// 'skribble-wash-3', ...)` colour-codes a box.
///
/// The defaults are skribble's sunny colourway: plum ink on warm paper, a
/// tomato accent, a highlighter-yellow marker, and sky, bubblegum, mint,
/// grape, and tangerine washes. Every wash reads with plum or night text.
///
/// Motion classes, which all stay still under `prefers-reduced-motion: reduce`:
///
/// | Class               | Effect                                                   |
/// | ------------------- | -------------------------------------------------------- |
/// | `skribble-draw`     | Outlines and hatching inside draw on with the pen, fills fade in, and highlights swipe in |
/// | `skribble-pop`      | Springs up into place, small and tilted, like a sticker   |
/// | `skribble-lift`     | Lifts and tilts on hover with a spring                   |
///
/// Stagger `skribble-draw` and `skribble-pop` with an inline `--i` (the
/// item's index, times 70ms) or `--skribble-delay`. Add the classes when
/// an element scrolls into view to play them there. Defaults are
/// declared with `:where(:root)`, so any rule of yours overrides them, and
/// switch to a dark palette under `prefers-color-scheme: dark`.
///
/// The stylesheet loads no fonts. Self-host `SkribbleNotoSketch-Regular.ttf`
/// from `skribble_font_noto_sketch` and declare `@font-face` for the
/// `SkribbleNotoSketch` family to use the default lettering. A locally
/// installed "Skribble Noto Sketch", then a self-hosted Recursive `Skribble`
/// family, are used next; otherwise the stack falls back to the system's
/// casual faces.
const String skribbleCss = '''
:where(:root) {
  --skribble-ink: #34283f;
  --skribble-paper: #fffaf0;
  --skribble-accent: #ff6b4a;
  --skribble-on-accent: #34283f;
  --skribble-marker: #ffd43b;
  --skribble-on-marker: #34283f;
  --skribble-wash-1: #ffd43b;
  --skribble-wash-2: #4cc3ff;
  --skribble-wash-3: #ff85c0;
  --skribble-wash-4: #3ddc97;
  --skribble-wash-5: #a98bff;
  --skribble-wash-6: #ff9f1c;
  --skribble-stroke-width: 2px;
  --skribble-font: "SkribbleNotoSketch", "Skribble Noto Sketch", "Skribble", "Segoe Print", "Bradley Hand", "Comic Sans MS", cursive;
}

@media (prefers-color-scheme: dark) {
  :where(:root) {
    --skribble-ink: #fffaf0;
    --skribble-paper: #292331;
    --skribble-on-accent: #292331;
    --skribble-on-marker: #292331;
  }
}

.skribble-page {
  background: var(--skribble-paper);
  color: var(--skribble-ink);
  font-family: var(--skribble-font);
}

.skribble-box,
.skribble-highlight,
.skribble-divider {
  position: relative;
  isolation: isolate;
}

/* Keep content at least 8px above and below and 12px beside the drawn
   line, which sits a few nominal units inside the box and wobbles. Cards,
   circles, and buttons set their own padding; :where() lets any rule of
   yours override this one. */
:where(.skribble-box) {
  padding: 0.75rem 1.25rem;
}

/* An absolutely positioned <svg> is a replaced element: it ignores
   left/right stretching, so every overlay states its width and height.
   Overlays such as the circle and marker are wider than their box, so a
   page reset like `svg { max-width: 100% }` must not cap them. */
.skribble-ink {
  position: absolute;
  inset: 0;
  z-index: -1;
  width: 100%;
  max-width: none;
  height: 100%;
  overflow: visible;
  pointer-events: none;
}

.skribble-ink-outline {
  stroke: var(--skribble-ink);
  stroke-width: var(--skribble-stroke-width);
}

.skribble-ink-hatch {
  stroke: var(--skribble-fill, var(--skribble-accent));
  stroke-width: calc(var(--skribble-stroke-width) * 0.75);
}

.skribble-ink-solid {
  fill: var(--skribble-fill, var(--skribble-accent));
}

.skribble-card {
  display: block;
  padding: 1.25rem 1.5rem;
}

.skribble-circle {
  padding: 1em 1.25em;
  text-align: center;
}

.skribble-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5em;
  min-height: 2.75rem;
  margin: 0;
  padding: 0.7em 1.3em;
  border: 0;
  background: none;
  color: var(--skribble-ink);
  font: inherit;
  font-family: var(--skribble-font);
  font-size: 1.05rem;
  line-height: 1.2;
  text-decoration: none;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
}

.skribble-button--primary {
  color: var(--skribble-on-accent);
}

.skribble-button > .skribble-ink + .skribble-ink {
  visibility: hidden;
}

.skribble-button:focus-visible {
  outline: 2px dashed var(--skribble-ink);
  outline-offset: 5px;
}

.skribble-button:focus-visible .skribble-ink-outline {
  stroke-width: calc(var(--skribble-stroke-width) * 1.5);
}

.skribble-button:disabled,
.skribble-button[aria-disabled="true"] {
  opacity: 0.55;
  cursor: not-allowed;
}

.skribble-wobble > .skribble-ink {
  transform-origin: 50% 50%;
}

/* All motion lives behind no-preference, so prefers-reduced-motion: reduce
   stops it whatever the specificity of a page's own rules. Disabled
   buttons and links stay still. */
@media (prefers-reduced-motion: no-preference) {
  .skribble-wobble > .skribble-ink {
    transition: transform 0.18s ease-out;
  }

  .skribble-button:not(:disabled):not([aria-disabled="true"]):active > .skribble-ink,
  .skribble-button:not(:disabled):not([aria-disabled="true"]):active > .skribble-button__label {
    transform: translate(1px, 1px);
  }
}

@media (hover: hover) and (prefers-reduced-motion: no-preference) {
  .skribble-wobble:not(:disabled):not([aria-disabled="true"]):hover > .skribble-ink {
    transform: rotate(-1deg) scale(1.02);
  }

  .skribble-button:not(:disabled):not([aria-disabled="true"]):hover > .skribble-ink {
    animation: skribble-boil-a 0.36s steps(1, end) infinite;
  }

  .skribble-button:not(:disabled):not([aria-disabled="true"]):hover > .skribble-ink + .skribble-ink {
    animation-name: skribble-boil-b;
  }
}

/* Ink that draws itself on. Stroked paths carry pathLength="1", so one
   dash covers each; the hatching follows the outline, and solid fills and
   highlighter swipes land last. */
@media (prefers-reduced-motion: no-preference) {
  .skribble-draw .skribble-ink-outline,
  .skribble-draw .skribble-ink-hatch {
    stroke-dasharray: 1 1;
    stroke-dashoffset: 1;
    animation: skribble-draw 0.8s cubic-bezier(0.45, 0.05, 0.2, 1) forwards;
    animation-delay: calc(var(--i, 0) * 70ms + var(--skribble-delay, 0s));
  }

  .skribble-draw .skribble-ink-hatch {
    animation-duration: 1.1s;
    animation-delay: calc(var(--i, 0) * 70ms + var(--skribble-delay, 0s) + 0.25s);
  }

  .skribble-draw .skribble-ink-solid {
    opacity: 0;
    animation: skribble-ink-in 0.5s ease-out forwards;
    animation-delay: calc(var(--i, 0) * 70ms + var(--skribble-delay, 0s) + 0.2s);
  }

  .skribble-draw .skribble-highlight > .skribble-ink,
  .skribble-highlight.skribble-draw > .skribble-ink {
    clip-path: inset(-20% 100% -20% 0);
    animation: skribble-swipe 0.6s cubic-bezier(0.45, 0.05, 0.2, 1) forwards;
    animation-delay: calc(var(--i, 0) * 70ms + var(--skribble-delay, 0s) + 0.3s);
  }

  .skribble-pop {
    animation: skribble-pop 0.72s cubic-bezier(0.3, 1.4, 0.5, 1) both;
    animation: skribble-pop 0.72s linear(0, 0.0314, 0.1111, 0.2202, 0.3438, 0.4702, 0.5911, 0.701, 0.7965, 0.8762, 0.94, 0.9887, 1.0238, 1.0473, 1.0611, 1.0673, 1.0676, 1.0639, 1.0574, 1.0495, 1.0409, 1.0324, 1.0244, 1.0174, 1.0113, 1.0064, 1.0025, 0.9996, 0.9976, 0.9963, 0.9956, 0.9954, 0.9958, 0.9969, 0.998, 0.999, 1) both;
    animation-delay: calc(var(--i, 0) * 70ms + var(--skribble-delay, 0s));
  }

  .skribble-lift {
    transition: transform 0.6s linear(0, 0.0651, 0.2261, 0.4354, 0.6529, 0.8497, 1.0074, 1.1182, 1.1821, 1.2049, 1.1959, 1.1654, 1.1234, 1.0786, 1.0371, 1.0032, 0.9788, 0.9642, 0.9582, 0.9591, 0.9648, 0.9731, 0.9824, 0.991, 0.9983, 1.0037, 1.007, 1.0085, 1.0058, 1.0021, 0.9994, 0.9983, 0.9987, 1);
  }
}

@media (hover: hover) and (prefers-reduced-motion: no-preference) {
  .skribble-lift:not(:disabled):not([aria-disabled="true"]):hover {
    transform: translateY(-4px) rotate(-1deg);
  }
}

@keyframes skribble-draw {
  to { stroke-dashoffset: 0; }
}

@keyframes skribble-ink-in {
  to { opacity: 1; }
}

@keyframes skribble-swipe {
  to { clip-path: inset(-20% -5% -20% 0); }
}

@keyframes skribble-pop {
  from {
    opacity: 0;
    transform: translateY(18px) scale(0.92) rotate(-2deg);
  }
}

@keyframes skribble-boil-a {
  0% { visibility: visible; }
  50% { visibility: hidden; }
}

@keyframes skribble-boil-b {
  0% { visibility: hidden; }
  50% { visibility: visible; }
}

.skribble-highlight {
  display: inline-block;
}

.skribble-highlight .skribble-ink-outline {
  stroke: var(--skribble-highlight, var(--skribble-ink));
}

.skribble-highlight .skribble-ink-solid {
  fill: var(--skribble-highlight, var(--skribble-marker));
  opacity: 0.9;
}

.skribble-highlight--underline > .skribble-ink {
  top: auto;
  bottom: -0.3em;
  height: 0.5em;
}

.skribble-highlight--strikethrough > .skribble-ink {
  top: calc(50% - 0.25em);
  z-index: 1;
  height: 0.5em;
}

.skribble-highlight--circle {
  margin-inline: 0.3em;
}

.skribble-highlight--circle > .skribble-ink {
  top: -0.35em;
  left: -0.55em;
  width: calc(100% + 1.1em);
  height: calc(100% + 0.7em);
}

.skribble-highlight--box {
  margin-inline: 0.3em;
}

.skribble-highlight--box > .skribble-ink {
  top: -0.18em;
  left: -0.3em;
  width: calc(100% + 0.6em);
  height: calc(100% + 0.36em);
}

.skribble-highlight--marker {
  color: var(--skribble-on-marker);
}

.skribble-wash-1 { --skribble-fill: var(--skribble-wash-1); }
.skribble-wash-2 { --skribble-fill: var(--skribble-wash-2); }
.skribble-wash-3 { --skribble-fill: var(--skribble-wash-3); }
.skribble-wash-4 { --skribble-fill: var(--skribble-wash-4); }
.skribble-wash-5 { --skribble-fill: var(--skribble-wash-5); }
.skribble-wash-6 { --skribble-fill: var(--skribble-wash-6); }

.skribble-highlight--marker > .skribble-ink {
  top: 0.08em;
  left: -0.2em;
  width: calc(100% + 0.4em);
  height: calc(100% - 0.08em);
}

.skribble-divider {
  display: block;
  height: 0.75rem;
  margin: 2rem 0;
}

.skribble-sketch {
  display: inline-block;
  max-width: 100%;
  height: auto;
  overflow: visible;
  vertical-align: middle;
}

/* Forced palettes such as Windows High Contrast repaint text but not SVG
   paint, which would leave forced text on the accent fill. Draw the ink in
   system colours instead. */
@media (forced-colors: active) {
  .skribble-ink-outline,
  .skribble-highlight .skribble-ink-outline {
    stroke: CanvasText;
  }

  .skribble-button .skribble-ink-outline {
    stroke: ButtonText;
  }

  .skribble-ink-hatch {
    stroke: GrayText;
  }

  .skribble-ink-solid {
    fill: none;
  }

  .skribble-highlight--marker {
    forced-color-adjust: none;
    color: HighlightText;
  }

  .skribble-highlight--marker .skribble-ink-solid {
    fill: Highlight;
    opacity: 1;
  }
}
''';
