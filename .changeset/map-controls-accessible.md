---
skribble_maps: patch
---

# Map zoom buttons and attribution work from a keyboard and a screen reader

- **Screen readers can press them.** The zoom buttons and a linked `WiredMapAttribution` excluded their gesture semantics without supplying their own tap action, so assistive technology announced a button it could not activate. Both now expose `onTap` to semantics.
- **Keyboards can reach them.** Both are focusable, activate with Enter or Space, and draw a heavier line while focused. A zoom button at its limit leaves the focus order.
- **Zoom buttons always show a glyph.** Their plus and minus came from the rough Material icon catalog, so an app that had not registered `skribble_icons_material` got two empty boxes. They now draw their own glyphs when no catalog provides them.
- **The attribution badge keeps the ink padding.** Its default padding is now `kWiredInkPadding` (12 at the sides, 8 above and below) instead of 8 by 4, which crowded a two-line credit against its outline. The credit also wraps onto as many lines as it needs instead of being cut to two lines with an ellipsis, since providers require the whole attribution.
- **Release builds skip short features.** A polyline with fewer than two points or a polygon with fewer than three, rejected by an assert in debug, threw from the painter in release builds. They are now skipped.
- Adds a runnable `example/example.dart`, and the maps guide notes that pin category glyphs need a registered icon catalog.
- The committed route golden image is replaced by a geometry check: both roughness levels render identical pixels, every segment centre is route ink, and no ink leaves the stroke.
