---
skribble_jaspr: minor
---

# Add hand-drawn Jaspr components that render with zero client JavaScript

The new `skribble_jaspr` package brings skribble to Jaspr sites. `WiredBox`, `WiredCard`, `WiredCircle`, `WiredButton`, `WiredHighlight`, `WiredDivider`, and `WiredSketch` draw their rough ink on the server into inline SVG, so static and server-rendered pages ship no drawing JavaScript and the same `seed` always produces the same markup.

Each overlay stretches to its element with `preserveAspectRatio="none"` and keeps strokes crisp with `vector-effect="non-scaling-stroke"`. The `skribbleCss` stylesheet themes everything through CSS custom properties (`--skribble-ink`, `--skribble-paper`, `--skribble-accent`, `--skribble-stroke-width`, `--skribble-font`), switches palettes for dark mode, draws a dashed keyboard focus ring, and adds a hover tilt and two-frame "line boil" on buttons that stop under `prefers-reduced-motion`. Ink is decorative and hidden from assistive technology; buttons and links keep native semantics.
