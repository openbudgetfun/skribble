<!--
  @component
  A standalone hand-drawn doodle at an explicit size, drawn by skribble's
  rough engine. Colours default to `currentColor`, so CSS `color` themes the
  ink. Other attributes pass through to the `<svg>` without redrawing the
  sketch.

  ```svelte
  <Sketch
    width={120}
    height={60}
    shape={{ type: "curve", points: [[4, 50], [40, 10], [80, 40], [116, 12]], arrowhead: true }}
    label="Points to the sign-up form"
  />
  ```
-->
<script lang="ts">
  import { pickSketchOptions, sketch, splitSketchOptions, type Shape, type SketchOptions } from "@skribble.dev/rough";
  import type { SVGAttributes } from "svelte/elements";

  interface Props
    extends SketchOptions,
      Omit<SVGAttributes<SVGSVGElement>, keyof SketchOptions | "width" | "height" | "viewBox" | "children"> {
    /** What to draw, in the sketch's own coordinates. */
    shape: Shape | readonly Shape[];
    /** Intrinsic width and `viewBox` width. */
    width: number;
    /** Intrinsic height and `viewBox` height. */
    height: number;
    /**
     * The SVG viewport, `"minX minY width height"`. Defaults to
     * `"0 0 width height"`; set it to crop, zoom, or draw shapes with
     * coordinates outside the positive quadrant.
     */
    viewBox?: string;
    /** An accessible description. Without one the sketch is decorative. */
    label?: string;
    /**
     * An accessible name rendered as a `<title>` element, which browsers also
     * show as a hover tooltip. Without it or a `label` the sketch is
     * decorative.
     */
    title?: string;
    /** A longer accessible description rendered as a `<desc>` element. */
    description?: string;
  }

  let { shape, width, height, viewBox, label, title, description, ...rest }: Props = $props();

  // Only the option keys are read for the drawing, so changing a
  // presentational prop (class, style, handlers) never recomputes it.
  const options = $derived(pickSketchOptions(rest));
  const attrs = $derived(splitSketchOptions(rest)[1]);
  const drawing = $derived(sketch(shape, options));
  const a11y = $derived.by(() => {
    if (label !== undefined) return { role: "img" as const, "aria-label": label };
    if (title !== undefined || description !== undefined) return { role: "img" as const };
    return { "aria-hidden": "true" as const, focusable: "false" as const };
  });
</script>

<svg
  xmlns="http://www.w3.org/2000/svg"
  {width}
  {height}
  viewBox={viewBox ?? `0 0 ${width} ${height}`}
  {...a11y}
  {...attrs}
>
  {#if title !== undefined}
    <title>{title}</title>
  {/if}
  {#if description !== undefined}
    <desc>{description}</desc>
  {/if}
  {#each drawing.paths as path (path.key)}
    {#if path.stroke === "none"}
      <path d={path.d} fill={path.fill} stroke="none" />
    {:else}
      <path
        d={path.d}
        fill={path.fill}
        stroke={path.stroke}
        stroke-width={path.strokeWidth}
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    {/if}
  {/each}
</svg>
