---
title: Using skribble from JavaScript
description: Draw skribble's hand-drawn shapes in browsers, Node, React, React Native, Vue, and Svelte with the @skribble.dev npm packages, a modern replacement for rough.js.
---

# Using skribble from JavaScript

The `@skribble.dev` npm packages bring skribble's rough engine to the JavaScript ecosystem. [`@skribble.dev/rough`](https://github.com/openbudgetfun/skribble/tree/main/js/rough) is a TypeScript port of the pure-Dart [rough engine](../core/rough-engine), with no dependencies. The same seed draws the same SVG path data as the Flutter widgets and the [Jaspr components](jaspr), so a design reads the same on every platform.

It also replaces [rough.js](https://github.com/rough-stuff/rough), whose last release was in 2023. The API keeps rough.js's `rough.canvas()`, `rough.svg()`, and `rough.generator()` entry points, and adds pen-shaped ink, rounded rectangles, arrowheads, and deterministic output.

| Package                      | Use it for                                         |
| ---------------------------- | -------------------------------------------------- |
| `@skribble.dev/rough`        | Plain browsers, Node, workers, canvas, SVG strings |
| `@skribble.dev/react`        | React and React DOM, including server rendering    |
| `@skribble.dev/react-native` | React Native, painted with `react-native-svg`      |
| `@skribble.dev/vue`          | Vue 3, including server rendering                  |
| `@skribble.dev/svelte`       | Svelte 5, including server rendering               |

The packages live in the repository's `js/` folder and are not on npm yet.

## Draw in a plain browser

`sketch()` returns the paths that paint a shape. `toSvgString()` wraps them in an `<svg>`:

```js
import { sketch, toSvgString } from "@skribble.dev/rough";

const box = sketch(
  { type: "rectangle", x: 4, y: 4, width: 192, height: 92 },
  { seed: 7, fill: "#ffd43b", fillStyle: "hachure" },
);

document.querySelector("#hero").innerHTML = toSvgString(box, { width: 200, height: 100 });
```

Shapes are plain objects: `rectangle`, `roundedRectangle`, `ellipse`, `circle`, `line`, `linearPath`, `polygon`, `arc`, and `curve`. Lines and curves take `arrowhead: true`. Pass an array to draw several shapes from one random stream.

Every option from the [rough engine](../core/rough-engine) is available: `seed`, `roughness`, `bowing`, `lineWobble`, `pen`, `fillStyle`, `hachureGap`, `hachureAngle`, and the rest. Colours default to `currentColor`, so CSS `color` themes the ink.

## Draw on a canvas or migrate from rough.js

```js
import rough from "@skribble.dev/rough";

const rc = rough.canvas(document.querySelector("canvas"));
rc.rectangle(10, 10, 200, 100, { fill: "red" });
rc.ellipse(120, 160, 160, 80, { fillStyle: "dots", fill: "teal" });
```

Existing rough.js calls mostly work unchanged. The differences:

- Shapes without a `seed` take consecutive seeds instead of random ones, so pages draw the same way on every load.
- Outlines are pen-shaped ink with tapered ends. Use `pen: "uniform"` for constant-width strokes.
- `sketchWidth` sets the width of hachure lines; `fillWeight` sizes dots.
- `path()` from SVG path data and `zigzag-line` fills are not available yet.

## Use a framework component

Each framework package exports a `<Sketch>` component that takes a `shape`, an intrinsic `width` and `height`, and any option as a prop. Without a `label` a sketch is decorative and hidden from assistive technology; with one it is an image with that name.

```jsx
import { Sketch } from "@skribble.dev/react";

<Sketch
  width={120}
  height={60}
  shape={{ type: "curve", points: [[4, 50], [40, 10], [80, 40], [116, 12]], arrowhead: true }}
  label="Points to the sign-up form"
/>;
```

The React Native component has the same props and paints with `react-native-svg`; set its `color` prop to theme `currentColor`. The Vue and Svelte components take the same props in their own syntax. React and React Native also export a `useSketch` hook, and Vue a `useSketch` composable, for painting the paths yourself.

## Pens and ink

By default outlines and sketched fills are drawn as filled pen shapes: a light touchdown, gentle pressure swells, a lift that thins out, and a lighter second pass. Choose a preset with `pen: "fineliner"`, `"ink"`, `"brush"`, or `"uniform"`, or pass your own pen values.

Ink is drawn at a fixed size. For drawings that stretch with their container, pass `ink: false` to paint plain centrelines, and add `vector-effect="non-scaling-stroke"` to keep strokes even.

## Parity with Dart

`@skribble.dev/rough` reproduces the Dart VM's seeded random stream bit for bit and follows the Dart engine operation for operation. Its tests replay fixtures written by `packages/skribble_rough/tool/js_parity_fixtures.dart` and expect byte-identical SVG for every shape, fill style, and pen. When the Dart engine changes, regenerate the fixtures:

```bash
dart run packages/skribble_rough/tool/js_parity_fixtures.dart > js/rough/test/fixtures/dart-parity.json
pnpm install && pnpm run check
```

The TypeScript port must then match the new output before CI passes.
