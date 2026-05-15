---
skribble: patch
---

# Split icon rendering into two packages: `skribble_icons` (pre-computed,
10-18x faster) with `SkribbleIcon` widget using roughened paths baked in at
build time, and `skribble_icons_dynamic` with `SkribbleDynamicIcon` using
runtime roughening via `WiredSvgIcon` for per-icon roughness and fill control.
Both share the same API surface and identifiers. Includes benchmark app
comparing both approaches across single icon, grid, and scrolling scenarios.
