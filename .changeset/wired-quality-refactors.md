---
skribble: patch
---

# Deduplicate wired base, button, tile, and doodle internals

Internal-only refactor with no behaviour or API change:

- `wired_base.dart` is split into `wired_paint.dart` (paint factories), `wired_element.dart` (repaint isolation), and `wired_painter_bases.dart` (shape painter bases); `wired_base.dart` re-exports them so existing imports keep working.
- The button family shares one internal `WiredButtonBase`; the checkbox, switch, and radio list tiles share an internal `WiredControlListTile`; both switches share the `useWiredThumbOffset` hook (with new RTL thumb-travel regression tests).
- The logo, loader, and doodle widgets rasterize `DoodleStroke` geometry through one shared `walkDoodleStroke`/`doodleStrokePath` implementation in `doodles/doodle_raster.dart`.
