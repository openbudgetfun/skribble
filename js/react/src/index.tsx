/**
 * Hand-drawn SVG sketches for React.
 *
 * `<Sketch>` draws one shape (or several) with skribble's rough engine into
 * an inline `<svg>`. Drawing happens during render with a fixed seed, so
 * server rendering and hydration produce the same markup.
 *
 * @packageDocumentation
 */
import { sketch, sketchKey, splitSketchOptions, type Shape, type Sketch as SketchResult, type SketchOptions } from "@skribble.dev/rough";
import { useMemo, type SVGProps } from "react";

export type { PointLike, RoughFillStyle, RoughPenName, Shape, SketchOptions, SketchPath } from "@skribble.dev/rough";

/**
 * Sketches [shape] with [options], recomputing only when what they draw
 * changes.
 */
export function useSketch(shape: Shape | readonly Shape[], options: SketchOptions = {}): SketchResult {
  const key = sketchKey(shape, options);
  // The key captures everything sketch() reads from shape and options.
  return useMemo(() => sketch(shape, options), [key]);
}

/** Props for {@link Sketch}. Other SVG attributes pass through to the `<svg>`. */
export interface SketchProps
  extends SketchOptions,
    Omit<SVGProps<SVGSVGElement>, keyof SketchOptions | "children" | "width" | "height" | "viewBox"> {
  /** What to draw, in the sketch's own coordinates. */
  shape: Shape | readonly Shape[];
  /** Intrinsic width and `viewBox` width. */
  width: number;
  /** Intrinsic height and `viewBox` height. */
  height: number;
  /**
   * An accessible description. Without one the sketch is decorative and
   * hidden from assistive technology.
   */
  label?: string;
}

/**
 * A standalone hand-drawn doodle at an explicit size.
 *
 * ```tsx
 * <Sketch
 *   width={120}
 *   height={60}
 *   shape={{ type: "curve", points: [[4, 50], [40, 10], [80, 40], [116, 12]], arrowhead: true }}
 *   label="Points to the sign-up form"
 * />
 * ```
 *
 * Colours default to `currentColor`, so CSS `color` themes the ink.
 */
export function Sketch(props: SketchProps) {
  const { shape, width, height, label, ...rest } = props;
  const [options, svgProps] = splitSketchOptions(rest);
  const { paths } = useSketch(shape, options);
  const a11y = label === undefined ? { "aria-hidden": true, focusable: false } : { role: "img", "aria-label": label };

  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={width}
      height={height}
      viewBox={`0 0 ${width} ${height}`}
      {...a11y}
      {...(svgProps as SVGProps<SVGSVGElement>)}
    >
      {paths.map((path) =>
        path.stroke === "none" ? (
          <path key={path.key} d={path.d} fill={path.fill} stroke="none" />
        ) : (
          <path
            key={path.key}
            d={path.d}
            fill={path.fill}
            stroke={path.stroke}
            strokeWidth={path.strokeWidth}
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        ),
      )}
    </svg>
  );
}
