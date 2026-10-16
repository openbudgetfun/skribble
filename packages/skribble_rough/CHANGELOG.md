# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## [0.3.2](https://github.com/openbudgetfun/skribble/releases/tag/v0.3.2) (2026-10-16)

### Features

#### Move the rough engine into the pure-Dart skribble_rough package

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #247](https://github.com/openbudgetfun/skribble/pull/247)

The Flutter-free half of the rough engine (`DrawConfig`, `Generator`, the fillers, `RoughPen`, `InkStroke`, `DrawableInk`, geometry, and the op-set data structures) now lives in the new `skribble_rough` package, which depends on nothing but the Dart SDK. Command-line tools, servers, and web frameworks can draw the same seeded shapes as the Flutter widgets without pulling in Flutter.

`skribble` depends on `skribble_rough` and re-exports exactly the names it exported before, so `import 'package:skribble/skribble.dart'` keeps working unchanged. The `dart:ui` painting layer (`RoughDrawing`, the `Rough` canvas extension, and `RoughBoxDecoration`) stays in `skribble`. Code that imported the engine's private `package:skribble/src/rough/...` files should import `package:skribble_rough/skribble_rough.dart` instead.

#### Serialize rough drawables to scalable SVG path data

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #247](https://github.com/openbudgetfun/skribble/pull/247)

`skribble_rough` adds `opSetToSvgPath`, which writes one `OpSet` as an SVG `d` attribute, and `RoughSvg.fromDrawable`, which splits a `Drawable` into the three groups the Flutter painter uses: the stroked outline, the stroked sketch fill, and the filled solid polygon. `RoughSvg.toPathElements` renders them as `<path>` elements, optionally with `vector-effect="non-scaling-stroke"` so strokes stay crisp when the SVG stretches. The new `RoughFillStyle` enum names each fill pattern and builds its `Filler` from a seeded `FillerConfig`.

Coordinates are rounded to two decimals, so the same seed always produces the same markup and server-rendered pages stay byte-stable between builds.
