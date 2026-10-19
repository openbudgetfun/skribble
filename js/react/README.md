# @skribble/react

Hand-drawn SVG sketches for React, drawn by [`@skribble/rough`](https://github.com/openbudgetfun/skribble/tree/main/js/rough), skribble's rough engine. Sketches are drawn during render from a fixed seed, so server rendering and hydration produce the same markup.

```bash
npm install @skribble/react
```

## `<Sketch>`

```jsx
import { Sketch } from "@skribble/react";

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

- `shape` is any [`@skribble/rough` shape](https://github.com/openbudgetfun/skribble/tree/main/js/rough#sketch-a-shape), or an array of them, in the sketch's own coordinates.
- `width` and `height` set the intrinsic size and the `viewBox`, so CSS can resize the sketch.
- Every [sketch option](https://github.com/openbudgetfun/skribble/tree/main/js/rough#options) is a prop: `seed`, `roughness`, `pen`, `fill`, `fillStyle`, `stroke`, `strokeWidth`, and the rest.
- Colours default to `currentColor`, so CSS `color` themes the ink.
- Without a `label` the sketch is decorative (`aria-hidden`). With one it becomes `role="img"` with that `aria-label`.
- Any other SVG attribute (`className`, `style`, `data-*`) passes through to the `<svg>`.

## `useSketch`

`useSketch(shape, options)` returns the drawing (`paths`, `drawable`, `style`) and recomputes only when the shape or options would draw something different. Use it to paint the paths yourself, for example inside a larger SVG.

```jsx
const { paths } = useSketch({ type: "circle", x: 50, y: 50, diameter: 80 }, { seed: 3, fill: "gold" });
```

## License

MIT
