/**
 * Hand-drawn SVG sketches for Svelte 5.
 *
 * `<Sketch>` draws one shape (or several) with skribble's rough engine into
 * an inline `<svg>`. Drawing uses a fixed seed, so server rendering and
 * hydration agree.
 *
 * @packageDocumentation
 */
import type { ComponentProps } from "svelte";
import Sketch from "./Sketch.svelte";

export { Sketch };
export { sketch } from "@skribble.dev/rough";

/**
 * Props of {@link Sketch}: a `shape` at a `width` and `height`, every sketch
 * option, the accessibility props, and any other `<svg>` attribute. Use it
 * to type wrapper components.
 */
export type SketchProps = ComponentProps<typeof Sketch>;
export type { PointLike, RoughFillStyle, RoughPenName, Shape, SketchOptions, SketchPath } from "@skribble.dev/rough";
