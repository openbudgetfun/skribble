# @skribble.dev/svelte

Hand-drawn SVG sketches for Svelte 5, drawn by [`@skribble.dev/rough`](https://github.com/openbudgetfun/skribble/tree/main/js/rough), skribble's rough engine. Sketches use a fixed seed, so server rendering and hydration agree.

```bash
npm install @skribble.dev/svelte
```

## `<Sketch>`

```html
<script>
  import { Sketch } from "@skribble.dev/svelte";
</script>

<Sketch
  width={120}
  height={60}
  shape={{ type: "curve", points: [[4, 50], [40, 10], [80, 40], [116, 12]], arrowhead: true }}
  label="Points to the sign-up form"
  style="color: tomato"
/>
```

- `shape` is any [`@skribble.dev/rough` shape](https://github.com/openbudgetfun/skribble/tree/main/js/rough#sketch-a-shape), or an array of them.
- `width` and `height` set the intrinsic size; `viewBox` overrides the default `"0 0 width height"` viewport, to crop, zoom, or draw shapes with coordinates outside the positive quadrant.
- Every [sketch option](https://github.com/openbudgetfun/skribble/tree/main/js/rough#options) is a prop. Props are reactive: change `seed` or `shape` and the sketch redraws — while changes to presentational attributes such as `class` and `style` pass through without redrawing.
- Colours default to `currentColor`. Without a `label`, `title`, or `description` the sketch is decorative; otherwise it is `role="img"` — `label` sets `aria-label`, `title` renders a `<title>` element (the browser's hover tooltip), and `description` renders a `<desc>`.
- Other attributes pass through to the `<svg>`.

The package also re-exports `sketch()` for drawing paths yourself.

Requires Svelte 5 (the component uses runes) and ships as compiled ESM source, the distribution every Svelte bundler consumes.

## License

MIT
