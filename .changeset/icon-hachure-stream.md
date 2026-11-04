---
skribble: patch
---

# Hatched icons draw the same strokes wherever they appear

`WiredSvgIconPainter` jitters its hachure and cross-hatch lines from a private copy of its `DrawConfig`'s random stream. Icons that share one `DrawConfig`, such as an app passing the same `drawConfig` to every `WiredSvgIcon`, used to continue each other's stream, so an icon's strokes changed with whichever icon happened to paint first. Icons with the theme's own config draw exactly as before.

A `hachureGap` of zero or less no longer throws `UnsupportedError`; gaps below half a pixel draw at half a pixel.
