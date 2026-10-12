---
skribble_rough: minor
---

# Serialize rough drawables to scalable SVG path data

`skribble_rough` adds `opSetToSvgPath`, which writes one `OpSet` as an SVG `d` attribute, and `RoughSvg.fromDrawable`, which splits a `Drawable` into the three groups the Flutter painter uses: the stroked outline, the stroked sketch fill, and the filled solid polygon. `RoughSvg.toPathElements` renders them as `<path>` elements, optionally with `vector-effect="non-scaling-stroke"` so strokes stay crisp when the SVG stretches. The new `RoughFillStyle` enum names each fill pattern and builds its `Filler` from a seeded `FillerConfig`.

Coordinates are rounded to two decimals, so the same seed always produces the same markup and server-rendered pages stay byte-stable between builds.
