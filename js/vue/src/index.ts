/**
 * Hand-drawn SVG sketches for Vue.
 *
 * `<Sketch>` draws one shape (or several) with skribble's rough engine into
 * an inline `<svg>`, and `useSketch` exposes the same drawing as a computed
 * ref. Drawing uses a fixed seed, so server rendering and hydration agree,
 * and a sketch only recomputes when the shape or an option changes — not
 * when presentational attributes do.
 *
 * @packageDocumentation
 */
import {
  pickSketchOptions,
  sketch,
  sketchOptionKeys,
  type RoughFillStyle,
  type RoughPen,
  type RoughPenName,
  type RoughPenOptions,
  type Shape,
  type Sketch as SketchResult,
  type SketchOptions,
} from "@skribble.dev/rough";
import { computed, defineComponent, h, toValue, type ComputedRef, type MaybeRefOrGetter, type PropType } from "vue";

export type { PointLike, RoughFillStyle, RoughPenName, Shape, SketchOptions, SketchPath } from "@skribble.dev/rough";

/** Sketches [shape] with [options] as a computed ref that follows both. */
export function useSketch(
  shape: MaybeRefOrGetter<Shape | readonly Shape[]>,
  options: MaybeRefOrGetter<SketchOptions> = {},
): ComputedRef<SketchResult> {
  return computed(() => sketch(toValue(shape), toValue(options)));
}

const numberProp = { type: Number, default: undefined };

/** Sketch options, all optional, for the {@link Sketch} props declaration. */
const optionProps = {
  maxRandomnessOffset: numberProp,
  roughness: numberProp,
  bowing: numberProp,
  lineWobble: numberProp,
  curveFitting: numberProp,
  curveTightness: numberProp,
  curveStepCount: numberProp,
  seed: { type: [Number, BigInt] as PropType<number | bigint>, default: undefined },
  pen: { type: [String, Object] as PropType<RoughPen | RoughPenName | RoughPenOptions>, default: undefined },
  fillStyle: { type: String as PropType<RoughFillStyle>, default: undefined },
  fill: { type: String, default: undefined },
  stroke: { type: String, default: undefined },
  strokeWidth: numberProp,
  sketchWidth: numberProp,
  fillWeight: numberProp,
  hachureAngle: numberProp,
  hachureGap: numberProp,
  dashOffset: numberProp,
  dashGap: numberProp,
  zigzagOffset: numberProp,
  // An explicit undefined default stops Vue from casting a missing flag to false.
  ink: { type: Boolean, default: undefined },
} satisfies Record<(typeof sketchOptionKeys)[number], unknown>;

/**
 * Props of {@link Sketch}: a `shape` at a `width` and `height`, every sketch
 * option, and the accessibility props below. Other attributes fall through
 * to the `<svg>`.
 */
export interface SketchProps extends SketchOptions {
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

/**
 * A standalone hand-drawn doodle at an explicit size.
 *
 * ```vue
 * <Sketch
 *   :width="120"
 *   :height="60"
 *   :shape="{ type: 'curve', points: [[4, 50], [40, 10], [80, 40], [116, 12]], arrowhead: true }"
 *   label="Points to the sign-up form"
 * />
 * ```
 *
 * Colours default to `currentColor`, so CSS `color` themes the ink. Other
 * attributes fall through to the `<svg>` without redrawing the sketch.
 */
export const Sketch = defineComponent({
  name: "SkribbleSketch",
  props: {
    /** What to draw, in the sketch's own coordinates. */
    shape: { type: [Object, Array] as PropType<Shape | readonly Shape[]>, required: true },
    /** Intrinsic width and `viewBox` width. */
    width: { type: Number, required: true },
    /** Intrinsic height and `viewBox` height. */
    height: { type: Number, required: true },
    /**
     * The SVG viewport, `"minX minY width height"`. Defaults to
     * `"0 0 width height"`; set it to crop, zoom, or draw shapes with
     * coordinates outside the positive quadrant.
     */
    viewBox: { type: String, default: undefined },
    /** An accessible description. Without one the sketch is decorative. */
    label: { type: String, default: undefined },
    /**
     * An accessible name rendered as a `<title>` element, which browsers
     * also show as a hover tooltip. Without it or a `label` the sketch is
     * decorative.
     */
    title: { type: String, default: undefined },
    /** A longer accessible description rendered as a `<desc>` element. */
    description: { type: String, default: undefined },
    ...optionProps,
  },
  setup(props) {
    // Only the option keys are read here, so changing a presentational prop
    // (class, style, handlers) never recomputes the drawing.
    const drawing = useSketch(
      () => props.shape,
      () => pickSketchOptions(props),
    );
    return () => {
      const named = props.label !== undefined || props.title !== undefined || props.description !== undefined;
      const a11y = named
        ? { role: "img", ...(props.label === undefined ? {} : { "aria-label": props.label }) }
        : { "aria-hidden": "true", focusable: "false" };
      return h(
        "svg",
        {
          xmlns: "http://www.w3.org/2000/svg",
          width: props.width,
          height: props.height,
          viewBox: props.viewBox ?? `0 0 ${props.width} ${props.height}`,
          ...a11y,
        },
        [
          ...(props.title === undefined ? [] : [h("title", props.title)]),
          ...(props.description === undefined ? [] : [h("desc", props.description)]),
          ...drawing.value.paths.map((path) =>
            path.stroke === "none"
              ? h("path", { key: path.key, d: path.d, fill: path.fill, stroke: "none" })
              : h("path", {
                  key: path.key,
                  d: path.d,
                  fill: path.fill,
                  stroke: path.stroke,
                  "stroke-width": path.strokeWidth,
                  "stroke-linecap": "round",
                  "stroke-linejoin": "round",
                }),
          ),
        ],
      );
    };
  },
});

export default Sketch;
