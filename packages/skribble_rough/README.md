# skribble_rough

The pure-Dart hand-drawn rendering engine behind [skribble](https://openbudgetfun.github.io/skribble/). It turns ideal geometry into lines that wobble like they were drawn by hand, fills shapes with sketched hachure, and serializes the result to SVG path data. It has no Flutter dependency.

## Why it exists

skribble's widgets paint with a Dart port of [rough.js](https://roughjs.com/). Keeping that engine free of `dart:ui` lets the same seeded shapes render wherever Dart runs:

- **Server-rendered sites.** [`skribble_jaspr`](../skribble_jaspr) draws its components with this package at build time, so pages ship static SVG and no drawing JavaScript.
- **Command-line exporters.** Design-kit and icon tools write SVG from the exact geometry the Flutter widgets paint.
- **Flutter apps.** `package:skribble` depends on this package and re-exports it, so nothing changes for Flutter code.

## Draw a shape

```dart
import 'package:skribble_rough/skribble_rough.dart';

void main() {
  const seed = 7;
  final generator = Generator(
    DrawConfig.build(seed: seed, roughness: 1.2),
    RoughFillStyle.hachure.filler(
      FillerConfig.build(drawConfig: DrawConfig.build(seed: seed)),
    ),
  );
  final svg = RoughSvg.fromDrawable(generator.rectangle(4, 4, 192, 92));

  print(
    '<svg viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg">'
    '${svg.toPathElements(stroke: "#1f1f1f", fill: "#f4c542")}'
    '</svg>',
  );
}
```

## SVG output

- `opSetToSvgPath(set)` writes one `OpSet` as an SVG `d` attribute. Solid fills are closed with `Z`.
- `RoughSvg.fromDrawable(drawable)` splits a drawable the way the Flutter painter paints it: `outline` (stroked with the ink colour), `sketch` (sketched fills, stroked with the fill colour), and `solid` (filled with the fill colour). `toPathElements()` renders the non-empty groups as `<path>` elements in paint order.
- `DrawableInk(drawable, ...).svgPaths()` exports the pen's tapered ink as filled outlines instead. Use it for fixed-size artwork; use `RoughSvg` when the SVG stretches with its container.

## Determinism

The same seed always draws the same shape. `DrawConfig.build(seed: n)` owns a fresh random stream, so build a new configuration for every shape (and for its filler) instead of sharing one. Coordinates are written with two decimals, so server-rendered markup is byte-stable between builds on the same Dart SDK. The stream comes from `dart:math`'s seeded `Random`, whose sequence the Dart SDK does not promise to keep across releases.

## Documentation

- [Rough engine](https://openbudgetfun.github.io/skribble/core/rough-engine): configuration, generator shapes, fillers, and pens.
- [Using skribble on Jaspr](https://openbudgetfun.github.io/skribble/guides/jaspr): server-rendered components built on this package.
