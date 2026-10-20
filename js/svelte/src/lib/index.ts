/**
 * Hand-drawn SVG sketches for Svelte 5.
 *
 * `<Sketch>` draws one shape (or several) with skribble's rough engine into
 * an inline `<svg>`. Drawing uses a fixed seed, so server rendering and
 * hydration agree.
 *
 * @packageDocumentation
 */
export { default as Sketch } from "./Sketch.svelte";
export { sketch } from "@skribble.dev/rough";
export type { PointLike, RoughFillStyle, RoughPenName, Shape, SketchOptions, SketchPath } from "@skribble.dev/rough";
