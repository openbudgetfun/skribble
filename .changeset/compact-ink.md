---
rust:skribble_rough: minor
skribble_leptoskit: patch
---

# Compact ink for drawings that ship to a browser

`skribble_rough` can write pen-shaped ink compactly: `CompactSvgInkOutline`, `InkStroke::compact_svg_path_data`, `DrawableInk::compact_svg_paths`, and `SketchOptions::tolerance`. The pen samples a stroke about every pen width, which keeps the taper smooth but writes far more points than a screen shows. Compact ink drops the samples within the tolerance of the line through their neighbours, draws through the rest with the same midpoint curves, and writes two decimals. The default output is unchanged, so ink still matches the Dart and TypeScript engines.

`skribble_leptoskit`'s `Sketch` now draws compact ink within a quarter of a logical pixel. Its paths are about a sixth of their old size: a server-rendered page of sketches dropped from 1.2 MB to 370 KB.
