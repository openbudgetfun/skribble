# skribble_rough

The hand-drawn rendering engine behind [skribble](https://openbudgetfun.github.io/skribble/), for Rust. It turns ideal geometry into lines that wobble like they were drawn by hand, fills shapes with sketched hachure, dots, dashes, or zig-zags, and lays the result down as pen-shaped ink with tapered ends. It has no dependencies and builds for every target, including `wasm32-unknown-unknown`.

It is a Rust port of the Dart package [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/packages/skribble_rough), so **the same seed draws the same SVG path data** as skribble's Flutter widgets, its Jaspr components, and the [`@skribble.dev/rough`](https://github.com/openbudgetfun/skribble/tree/main/js/rough) npm package. [`skribble_leptoskit`](https://github.com/openbudgetfun/skribble/tree/main/rust/leptoskit) draws its components with it.

## Install

The crate is not on crates.io yet. Depend on it from Git, pinned to a commit:

```toml
[dependencies]
skribble_rough = { git = "https://github.com/openbudgetfun/skribble", rev = "<commit>" }
```

## Sketch a shape

`sketch` describes a drawing as SVG paths any renderer can paint, each with its colours and widths:

```rust
use skribble_rough::{sketch, FillStyle, Shape, SketchOptions};

let options = SketchOptions {
	fill: Some("#ffd43b".to_owned()),
	fill_style: Some(FillStyle::Hachure),
	..SketchOptions::default()
};
let card = sketch(&[Shape::rectangle(4.0, 4.0, 192.0, 92.0)], &options)?;
let svg = card.to_svg_string(200.0, 100.0, Some("A sketched box"));
```

| `Shape`            | Draws                                                                    |
| ------------------ | ------------------------------------------------------------------------ |
| `Rectangle`        | A rectangle from its top-left corner                                     |
| `RoundedRectangle` | A rectangle with four corner radii, clockwise from the top left          |
| `Ellipse`          | An ellipse around its centre                                             |
| `Circle`           | A circle around its centre                                               |
| `Line`             | A straight line, optionally ending in an arrowhead                       |
| `LinearPath`       | Straight segments through points, open or closed                         |
| `Polygon`          | A closed, fillable polygon                                               |
| `Arc`              | An elliptical arc between two angles, optionally closed as a pie slice   |
| `Curve`            | A smooth curve through at least two points, optionally with an arrowhead |

Pass several shapes to draw them from one random stream. `sketch` returns an error for a shape it cannot draw: a NaN or infinite number, an arc whose stop angle is not after its start, or a curve with fewer than two points. `Shape::validate` checks one shape without drawing it.

## Options

`SketchOptions` holds three groups: `draw` (`DrawOptions`), `pattern` (`FillOptions`), and the paint.

| Option                       | Default         | What it does                                                                     |
| ---------------------------- | --------------- | -------------------------------------------------------------------------------- |
| `draw.seed`                  | `1`             | Chooses the wobble. The same seed always draws the same shape.                   |
| `draw.roughness`             | `1.1`           | Scales every random displacement.                                                |
| `draw.bowing`                | `1`             | How far straight edges bow away from their chord.                                |
| `draw.line_wobble`           | `0.35`          | Local wandering along long edges; `0` keeps softly bowed lines.                  |
| `draw.max_randomness_offset` | `1.2`           | Largest endpoint displacement before roughness.                                  |
| `draw.curve_fitting`         | `0.95`          | How closely ellipses follow their ideal radius.                                  |
| `draw.curve_tightness`       | `0`             | Catmull-Rom tension for curves.                                                  |
| `draw.curve_step_count`      | `9`             | Minimum points used for a full ellipse.                                          |
| `draw.pen`                   | `RoughPen::INK` | `UNIFORM`, `FINELINER`, `INK`, `BRUSH`, or your own `RoughPen`.                  |
| `pattern.hachure_angle`      | `320`           | Angle of hachure lines, in degrees.                                              |
| `pattern.hachure_gap`        | `8`             | Distance between hachure lines.                                                  |
| `pattern.fill_weight`        | `1`             | Dot diameter, and how far solid fill corners wander.                             |
| `pattern.dash_offset`        | `15`            | Dash length in dashed fills.                                                     |
| `pattern.dash_gap`           | `2`             | Gap between dashes.                                                              |
| `pattern.zigzag_offset`      | `5`             | Offset of zig-zag turns.                                                         |
| `fill_style`                 | `None`          | The `FillStyle`; `None` picks hachure when `fill` is set, and no fill otherwise. |
| `fill`                       | `None`          | Fill colour, as any SVG paint; `None` paints `currentColor`.                     |
| `stroke`                     | `currentColor`  | Ink colour.                                                                      |
| `stroke_width`               | `1.5`           | Outline width.                                                                   |
| `sketch_width`               | `1`             | Width of sketched fill lines.                                                    |
| `ink`                        | `true`          | Paint pen-shaped ink. `false` strokes plain centrelines, which scale cleanly.    |

## The low-level engine

The Dart engine's types are all here: `DrawConfig` and `DrawOptions`, `Generator`, `Filler` and `FillStyle`, `RoughPen`, `InkStroke`, `DrawableInk`, `op_set_to_svg_path`, and `RoughSvgPaths` (Dart's `RoughSvg`).

```rust
use skribble_rough::{DrawConfig, DrawOptions, FillOptions, FillStyle, Filler, Generator, RoughSvgPaths};

let options = DrawOptions { seed: 7, roughness: 1.2, ..DrawOptions::default() };
let filler = Filler::new(FillStyle::Hachure, FillOptions::default(), DrawConfig::new(options));
let mut generator = Generator::new(DrawConfig::new(options), filler);
let paths = RoughSvgPaths::from_drawable(&generator.rectangle(4.0, 4.0, 192.0, 92.0));
```

Give the generator and its filler a `DrawConfig` each: every configuration owns a random stream, and drawing advances it.

`InkStroke::write_outline(sink, distance)` draws only the first `distance` of a stroke, which is how skribble animates ink being drawn on. Implement `InkOutlineSink` to send the outline to your own canvas.

## Determinism and parity with Dart

The random stream reproduces the Dart VM's `Random(seed)` bit for bit, and the engine follows the Dart code operation for operation, including Dart's rounding and sort order. The tests replay the fixtures `packages/skribble_rough/tool/js_parity_fixtures.dart` writes, the same ones the npm package uses, and expect identical SVG for every shape, fill style, and pen. Coordinates are written with two decimals (three for ink outlines), so server-rendered markup is stable between builds.

`sin` and `cos` can differ in their last bit between platforms' maths libraries. That has never shown in the rounded output, but a coordinate that lands exactly on a rounding boundary could print one hundredth differently on another platform.

## License

MIT
