# @skribble/rough

The hand-drawn rendering engine behind [skribble](https://openbudgetfun.github.io/skribble/), for every JavaScript runtime. It turns ideal geometry into lines that wobble like they were drawn by hand, fills shapes with sketched hachure, dots, dashes, or zig-zags, and lays the result down as pen-shaped ink with tapered ends. It has no dependencies and runs in browsers, Node, Deno, Bun, workers, and React Native.

It is a TypeScript port of the Dart package [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/packages/skribble_rough), so **the same seed draws the same SVG path data as skribble's Flutter widgets and Jaspr components**. It also works as a modern replacement for [rough.js](https://github.com/rough-stuff/rough), with a rough.js-style API for canvas and SVG.

Framework bindings build on it:

| Package                                                                                         | For                                   |
| ----------------------------------------------------------------------------------------------- | ------------------------------------- |
| [`@skribble/react`](https://github.com/openbudgetfun/skribble/tree/main/js/react)               | React and React DOM, including SSR    |
| [`@skribble/react-native`](https://github.com/openbudgetfun/skribble/tree/main/js/react-native) | React Native through react-native-svg |
| [`@skribble/vue`](https://github.com/openbudgetfun/skribble/tree/main/js/vue)                   | Vue 3, including SSR                  |
| [`@skribble/svelte`](https://github.com/openbudgetfun/skribble/tree/main/js/svelte)             | Svelte 5, including SSR               |

## Install

```bash
npm install @skribble/rough
```

The package is ESM-only and ships its TypeScript types.

## Sketch a shape

`sketch()` describes a drawing as data that any renderer can paint: one entry per SVG `<path>`, with its colours and widths.

```js
import { sketch, toSvgString } from "@skribble/rough";

const box = sketch(
  { type: "rectangle", x: 4, y: 4, width: 192, height: 92 },
  { seed: 7, fill: "#ffd43b", fillStyle: "hachure" },
);

document.body.innerHTML = toSvgString(box, { width: 200, height: 100, label: "A sketched box" });
```

Shapes are plain objects:

| `type`             | Fields                                                                  |
| ------------------ | ----------------------------------------------------------------------- |
| `rectangle`        | `x`, `y`, `width`, `height`                                             |
| `roundedRectangle` | `x`, `y`, `width`, `height`, `radius` (one number or four corners)      |
| `ellipse`          | centre `x`, `y`, `width`, `height`                                      |
| `circle`           | centre `x`, `y`, `diameter`                                             |
| `line`             | `x1`, `y1`, `x2`, `y2`, optional `arrowhead`                            |
| `linearPath`       | `points`, optional `closed`                                             |
| `polygon`          | `points`                                                                |
| `arc`              | centre `x`, `y`, `width`, `height`, `start`, `stop` (radians), `closed` |
| `curve`            | `points` (at least two), optional `arrowhead`                           |

Points are `[x, y]` pairs or `{ x, y }` objects. Pass an array of shapes to draw several from one random stream.

## Options

| Option                | Default        | What it does                                                                  |
| --------------------- | -------------- | ----------------------------------------------------------------------------- |
| `seed`                | `1`            | Chooses the wobble. The same seed always draws the same shape.                |
| `roughness`           | `1.8`          | Scales every random displacement.                                             |
| `bowing`              | `1`            | How far straight edges bow away from their chord.                             |
| `lineWobble`          | `1`            | Local wandering along long edges; `0` keeps softly bowed lines.               |
| `maxRandomnessOffset` | `2`            | Largest endpoint displacement before roughness.                               |
| `curveFitting`        | `0.95`         | How closely ellipses follow their ideal radius.                               |
| `curveTightness`      | `0`            | Catmull-Rom tension for curves.                                               |
| `curveStepCount`      | `9`            | Minimum points used for a full ellipse.                                       |
| `pen`                 | `"ink"`        | `"uniform"`, `"fineliner"`, `"ink"`, `"brush"`, a `RoughPen`, or pen options. |
| `ink`                 | `true`         | Paint pen-shaped ink. `false` strokes plain centrelines, which scale cleanly. |
| `stroke`              | `currentColor` | Ink colour.                                                                   |
| `strokeWidth`         | `1.5`          | Outline width.                                                                |
| `fill`                | `currentColor` | Fill colour. Setting it without `fillStyle` picks `"hachure"`.                |
| `fillStyle`           | `"none"`       | `"hachure"`, `"cross-hatch"`, `"zigzag"`, `"dashed"`, `"dots"`, or `"solid"`. |
| `sketchWidth`         | `1`            | Width of sketched fill lines.                                                 |
| `hachureAngle`        | `320`          | Angle of hachure lines, in degrees.                                           |
| `hachureGap`          | `8`            | Distance between hachure lines.                                               |
| `fillWeight`          | `1`            | Dot diameter, and how far solid fill corners wander.                          |
| `dashOffset`          | `15`           | Dash length in dashed fills.                                                  |
| `dashGap`             | `2`            | Gap between dashes.                                                           |
| `zigzagOffset`        | `5`            | Offset of zig-zag turns.                                                      |

## Coming from rough.js

`rough.canvas()`, `rough.svg()`, and `rough.generator()` work the way they do in rough.js:

```js
import rough from "@skribble/rough";

const rc = rough.canvas(document.querySelector("canvas"));
rc.rectangle(10, 10, 200, 100, { fill: "red" });
rc.circle(80, 120, 50, { fillStyle: "cross-hatch", fill: "teal" });

const rs = rough.svg(svgElement);
svgElement.appendChild(rs.line(10, 10, 200, 60, { pen: "brush", strokeWidth: 3 }));
```

What is different:

- **Deterministic by default.** Shapes without a `seed` take consecutive seeds (1, 2, 3, ...) instead of random ones, so a page draws the same way on every load and on the server.
- **Ink, not strokes.** Outlines are drawn as filled pen shapes with tapered ends and a lighter second pass. Pass `pen: "uniform"` (or `ink: false`) for rough.js-style constant-width strokes.
- **Fill options.** The width of hachure lines is `sketchWidth`; `fillWeight` sizes dots and solid-fill wander instead. `zigzag-line` fills and `path()` from SVG path data are not available yet.
- **Defaults** follow skribble: `roughness` 1.8, `hachureAngle` 320, `hachureGap` 8, `strokeWidth` 1.5, and `currentColor` for every colour. Canvas resolves `currentColor` from the canvas element's CSS `color`.
- **`linearPath`** is open, as in rough.js. The low-level `Generator.linearPath` closes the path by default to match the Dart engine.

## Paint anywhere

- **SVG strings:** `toSvgString(sketch, { width, height })`, or `pathsToSvgElements(paths)` for just the `<path>` elements.
- **DOM:** `createSvgGroup(paths, document)` returns an SVG `<g>`.
- **Canvas:** `drawOnCanvas(ctx, drawable, style)` paints on any 2D context, including `OffscreenCanvas` and Node canvas libraries.
- **Your own renderer:** every `SketchPath` has `d`, `fill`, `stroke`, and `strokeWidth`, so a framework only maps it to its own path element. That is all the React, React Native, Vue, and Svelte packages do.

## The low-level engine

The Dart engine's classes are exported unchanged in spirit: `DrawConfig`, `Generator`, `FillerConfig` and the fillers, `RoughPen`, `InkStroke`, `DrawableInk`, `opSetToSvgPath`, and `toSvgPaths`/`toPathElements` (Dart's `RoughSvg`).

```js
import { DrawConfig, FillerConfig, Generator, createFiller, toPathElements, toSvgPaths } from "@skribble/rough";

const config = () => DrawConfig.build({ seed: 7, roughness: 1.2 });
const generator = new Generator(config(), createFiller("hachure", FillerConfig.build({ drawConfig: config() })));
const svg = toSvgPaths(generator.rectangle(4, 4, 192, 92));
console.log(toPathElements(svg, { stroke: "#1f1f1f", fill: "#f4c542" }));
```

Build a fresh `DrawConfig` for every shape and for its filler: each owns a random stream, and sharing one advances it across shapes.

`InkStroke.writeOutline(sink, distance)` draws only the first `distance` of a stroke, which is how skribble animates ink being drawn on. `canvasInkSink(ctx)` adapts a canvas context or `Path2D` as the sink.

## Determinism and parity with Dart

The random stream reproduces the Dart VM's `Random(seed)` bit for bit, and the engine follows the Dart code operation for operation, including Dart's rounding and sort order. The test suite replays fixtures generated by `packages/skribble_rough/tool/js_parity_fixtures.dart` and expects byte-identical SVG for every shape, fill style, and pen. Coordinates are written with two decimals (three for ink outlines), so server-rendered markup is stable between builds.

`sin` and `cos` can differ in their last bit between JavaScript engines and C libraries. That never showed up in the rounded output the fixtures cover, but a coordinate that lands exactly on a rounding boundary could print one hundredth differently on another platform.

## License

MIT
