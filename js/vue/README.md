# @skribble.dev/vue

Hand-drawn SVG sketches for Vue 3, drawn by [`@skribble.dev/rough`](https://github.com/openbudgetfun/skribble/tree/main/js/rough), skribble's rough engine. Sketches use a fixed seed, so server rendering and hydration agree.

```bash
npm install @skribble.dev/vue
```

## `<Sketch>`

```html
<script setup>
import { Sketch } from "@skribble.dev/vue";
</script>

<template>
  <Sketch
    :width="120"
    :height="60"
    :shape="{ type: 'curve', points: [[4, 50], [40, 10], [80, 40], [116, 12]], arrowhead: true }"
    label="Points to the sign-up form"
    style="color: tomato"
  />
</template>
```

- `shape` is any [`@skribble.dev/rough` shape](https://github.com/openbudgetfun/skribble/tree/main/js/rough#sketch-a-shape), or an array of them.
- `width` and `height` set the intrinsic size; `viewBox` overrides the default `"0 0 width height"` viewport, to crop, zoom, or draw shapes with coordinates outside the positive quadrant.
- Every [sketch option](https://github.com/openbudgetfun/skribble/tree/main/js/rough#options) is a prop (`seed`, `pen`, `fill`, `fill-style`, ...). The sketch recomputes only when the shape or an option changes; presentational attributes like `class` and `style` fall through without redrawing.
- Colours default to `currentColor`. Without a `label`, `title`, or `description` the sketch is decorative; otherwise it is `role="img"` — `label` sets `aria-label`, `title` renders a `<title>` element (the browser's hover tooltip), and `description` renders a `<desc>`.
- Other attributes fall through to the `<svg>`.
- The `SketchProps` interface is exported for wrapper components.

## `useSketch`

`useSketch(shape, options)` takes values, refs, or getters and returns a computed ref of the drawing.

```js
const seed = ref(1);
const drawing = useSketch({ type: "circle", x: 50, y: 50, diameter: 80 }, () => ({ seed: seed.value }));
```

## License

MIT
