# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.4.0](https://github.com/openbudgetfun/skribble/releases/tag/v0.4.0) (2026-10-21)

### Features

#### Add hand-drawn Jaspr components that render with zero client JavaScript

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #247](https://github.com/openbudgetfun/skribble/pull/247)

The new `skribble_jaspr` package brings skribble to Jaspr sites. `WiredBox`, `WiredCard`, `WiredCircle`, `WiredButton`, `WiredHighlight`, `WiredDivider`, and `WiredSketch` draw their rough ink on the server into inline SVG, so static and server-rendered pages ship no drawing JavaScript and the same `seed` always produces the same markup.

Each overlay stretches to its element with `preserveAspectRatio="none"` and keeps strokes crisp with `vector-effect="non-scaling-stroke"`. The `skribbleCss` stylesheet themes everything through CSS custom properties (`--skribble-ink`, `--skribble-paper`, `--skribble-accent`, `--skribble-stroke-width`, `--skribble-font`), switches palettes for dark mode, draws a dashed keyboard focus ring, and adds a hover tilt and two-frame "line boil" on buttons that stop under `prefers-reduced-motion`. Ink is decorative and hidden from assistive technology; buttons and links keep native semantics.

### Fixes

- **Circle and marker highlights cover their whole word under an `svg` reset.** Many sites reset `svg { max-width: 100% }`. That capped the ink of a `WiredHighlight` at the width of its text, so a circle was drawn to the left of its word and a marker stopped short of the last letter. `skribbleCss` now gives every ink overlay `max-width: none`, so highlights keep their margin around the text whatever the page's own resets. _Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #257](https://github.com/openbudgetfun/skribble/pull/257)
