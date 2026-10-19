<!--
  @component
  A standalone hand-drawn doodle at an explicit size, drawn by skribble's
  rough engine. Colours default to `currentColor`, so CSS `color` themes the
  ink. Other attributes pass through to the `<svg>`.

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
  import { sketch, splitSketchOptions, type Shape, type SketchOptions } from "@skribble.dev/rough";
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
    /** An accessible description. Without one the sketch is decorative. */
    label?: string;
  }

  let { shape, width, height, label, ...rest }: Props = $props();

  const split = $derived(splitSketchOptions(rest));
  const drawing = $derived(sketch(shape, split[0]));
  const a11y = $derived(
    label === undefined
      ? { "aria-hidden": "true" as const, focusable: "false" as const }
      : { role: "img", "aria-label": label },
  );
</script>

<svg
  xmlns="http://www.w3.org/2000/svg"
  {width}
  {height}
  viewBox="0 0 {width} {height}"
  {...a11y}
  {...split[1]}
>
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
