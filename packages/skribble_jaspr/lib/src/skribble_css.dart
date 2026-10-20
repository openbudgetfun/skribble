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
/// It positions the SVG ink behind each component, maps the ink to theme
/// custom properties, and adds hover, focus, and reduced-motion behaviour.
/// Theme a page, or any subtree, by overriding the properties:
///
/// | Property                  | Used for                                   |
/// | ------------------------- | ------------------------------------------ |
/// | `--skribble-ink`          | Outlines, pen highlights, button labels    |
/// | `--skribble-paper`        | The `.skribble-page` background            |
/// | `--skribble-accent`       | Default fills, primary buttons, markers    |
/// | `--skribble-on-accent`    | Text on accent fills                       |
/// | `--skribble-stroke-width` | Outline width at every size                |
/// | `--skribble-font`         | Button labels and `.skribble-page`         |
///
/// Components also read `--skribble-fill` (set by their `fill` argument)
/// and `--skribble-highlight` (set by `WiredHighlight.color`). Defaults are
/// declared with `:where(:root)`, so any rule of yours overrides them, and
/// switch to a dark palette under `prefers-color-scheme: dark`.
///
/// The stylesheet loads no fonts. Self-host the skribble font files and
/// declare `@font-face` for the `Skribble` family to use the bundled
/// lettering; otherwise the font stack falls back to the system's casual
/// faces.
const String skribbleCss = '''
:where(:root) {
  --skribble-ink: #1f1d1a;
  --skribble-paper: #fffdf6;
  --skribble-accent: #ffd43b;
  --skribble-on-accent: #1f1d1a;
  --skribble-stroke-width: 2px;
  --skribble-font: "Skribble", "Segoe Print", "Bradley Hand", "Comic Sans MS", cursive;
}

@media (prefers-color-scheme: dark) {
  :where(:root) {
    --skribble-ink: #f2efe6;
    --skribble-paper: #1b1a17;
    --skribble-accent: #e3b62f;
    --skribble-on-accent: #1b1a17;
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
  padding: 0.55em 1.3em;
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
  transition: transform 0.18s ease-out;
}

@media (hover: hover) {
  .skribble-wobble:hover > .skribble-ink {
    transform: rotate(-1deg) scale(1.02);
  }

  .skribble-button:not(:disabled):hover > .skribble-ink {
    animation: skribble-boil-a 0.36s steps(1, end) infinite;
  }

  .skribble-button:not(:disabled):hover > .skribble-ink + .skribble-ink {
    animation-name: skribble-boil-b;
  }
}

.skribble-button:active > .skribble-ink,
.skribble-button:active > .skribble-button__label {
  transform: translate(1px, 1px);
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
  fill: var(--skribble-highlight, var(--skribble-accent));
  opacity: 0.75;
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
  color: var(--skribble-on-accent);
}

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

@media (prefers-reduced-motion: reduce) {
  .skribble-wobble > .skribble-ink {
    transition: none;
  }

  .skribble-wobble:hover > .skribble-ink,
  .skribble-button:active > .skribble-ink,
  .skribble-button:active > .skribble-button__label {
    transform: none;
  }

  .skribble-button:hover > .skribble-ink {
    animation: none;
  }
}
''';
