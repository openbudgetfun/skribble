# @skribble.dev/react

Hand-drawn SVG sketches for React 19 and newer, drawn by [`@skribble.dev/rough`](https://github.com/openbudgetfun/skribble/tree/main/js/rough), skribble's rough engine. Sketches are drawn during render from a fixed seed, so server rendering and hydration produce the same markup, and `<Sketch>` is memoised on what it draws: re-rendering a parent costs nothing until the shape, an option, or an SVG attribute changes. Inline shape and option objects are compared by value, so props do not need to be memoised.

```bash
npm install @skribble.dev/react
```

## `<Sketch>`

```jsx
import { Sketch } from "@skribble.dev/react";

export function Callout() {
  return (
    <Sketch
      width={120}
      height={60}
      shape={{ type: "curve", points: [[4, 50], [40, 10], [80, 40], [116, 12]], arrowhead: true }}
      label="Points to the sign-up form"
      style={{ color: "tomato" }}
    />
  );
}
```

- `shape` is any [`@skribble.dev/rough` shape](https://github.com/openbudgetfun/skribble/tree/main/js/rough#sketch-a-shape), or an array of them, in the sketch's own coordinates.
- `width` and `height` set the intrinsic size, so CSS can resize the sketch.
- `viewBox` overrides the default `"0 0 width height"` viewport, to crop, zoom, or draw shapes with coordinates outside the positive quadrant.
- Every [sketch option](https://github.com/openbudgetfun/skribble/tree/main/js/rough#options) is a prop: `seed`, `roughness`, `pen`, `fill`, `fillStyle`, `stroke`, `strokeWidth`, and the rest.
- Colours default to `currentColor`, so CSS `color` themes the ink.
- Without a `label`, `title`, or `description` the sketch is decorative (`aria-hidden`). With `label` it becomes `role="img"` with that `aria-label`; `title` renders a `<title>` element (the browser's hover tooltip and a fallback accessible name) and `description` renders a `<desc>`.
- Any other SVG attribute (`className`, `style`, `data-*`) passes through to the `<svg>`.

Requires React 19 or newer; `ref` behaves as a normal prop.

## `useSketch`

`useSketch(shape, options)` returns the drawing (`paths`, `drawable`, `style`) and recomputes only when the shape or options would draw something different. Use it to paint the paths yourself, for example inside a larger SVG.

```jsx
const { paths } = useSketch({ type: "circle", x: 50, y: 50, diameter: 80 }, { seed: 3, fill: "gold" });
```

## License

MIT
