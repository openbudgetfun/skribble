import { type Shape, type SketchOptions } from "@skribble/rough";
import type { SVGAttributes } from "svelte/elements";
interface Props extends SketchOptions, Omit<SVGAttributes<SVGSVGElement>, keyof SketchOptions | "width" | "height" | "viewBox" | "children"> {
    /** What to draw, in the sketch's own coordinates. */
    shape: Shape | readonly Shape[];
    /** Intrinsic width and `viewBox` width. */
    width: number;
    /** Intrinsic height and `viewBox` height. */
    height: number;
    /** An accessible description. Without one the sketch is decorative. */
    label?: string;
}
/**
 * A standalone hand-drawn doodle at an explicit size, drawn by skribble's
 * rough engine. Colours default to `currentColor`, so CSS `color` themes the
 * ink. Other attributes pass through to the `<svg>`.
 *
 * ```svelte
 * <Sketch
 *   width={120}
 *   height={60}
 *   shape={{ type: "curve", points: [[4, 50], [40, 10], [80, 40], [116, 12]], arrowhead: true }}
 *   label="Points to the sign-up form"
 * />
 * ```
 */
declare const Sketch: import("svelte").Component<Props, {}, "">;
type Sketch = ReturnType<typeof Sketch>;
export default Sketch;
//# sourceMappingURL=Sketch.svelte.d.ts.map