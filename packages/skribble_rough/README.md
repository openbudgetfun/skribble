# skribble_rough

The pure-Dart hand-drawn rendering engine behind [skribble](https://openbudgetfun.github.io/skribble/). It turns ideal geometry into lines that wobble like they were drawn by hand, fills shapes with sketched hachure, and serializes the result to SVG path data. It has no Flutter dependency.

## Why it exists

skribble's widgets paint with a Dart port of [rough.js](https://roughjs.com/). Keeping that engine free of `dart:ui` lets the same seeded shapes render wherever Dart runs:

- **Command-line exporters.** Design-kit and icon tools write SVG from the exact geometry the Flutter widgets paint.
- **Flutter apps.** `package:skribble` depends on this package and re-exports it, so nothing changes for Flutter code.

## Determinism

The same seed always draws the same shape. `DrawConfig.build(seed: n)` owns a fresh random stream, so build a new configuration for every shape (and for its filler) instead of sharing one. The stream comes from `dart:math`'s seeded `Random`, whose sequence the Dart SDK does not promise to keep across releases.

## Documentation

- [Rough engine](https://openbudgetfun.github.io/skribble/core/rough-engine): configuration, generator shapes, fillers, and pens.
