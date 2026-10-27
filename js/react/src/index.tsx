/**
 * Hand-drawn SVG sketches for React 19 and newer.
 *
 * `<Sketch>` draws one shape (or several) with skribble's rough engine into
 * an inline `<svg>`. Drawing happens during render with a fixed seed, so
 * server rendering and hydration produce the same markup, and the component
 * is memoised on what it draws, so re-rendering a parent with unchanged
 * sketch props costs nothing.
 *
 * @packageDocumentation
 */
import {
  pickSketchOptions,
  sketch,
  sketchKey,
  sketchOptionKeys,
  splitSketchOptions,
  type Shape,
  type Sketch as SketchResult,
  type SketchOptions,
} from "@skribble.dev/rough";
import { memo, useMemo, type SVGProps } from "react";

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
   * The SVG viewport, `"minX minY width height"`. Defaults to
   * `"0 0 width height"`; set it to crop, zoom, or draw shapes with
   * coordinates outside the positive quadrant.
   */
  viewBox?: string;
  /**
   * An accessible description. Without one the sketch is decorative and
   * hidden from assistive technology.
   */
  label?: string;
  /**
   * An accessible name rendered as a `<title>` element, which browsers also
   * show as a hover tooltip. Without it or a {@link label} the sketch is
   * decorative.
   */
  title?: string;
  /** A longer accessible description rendered as a `<desc>` element. */
  description?: string;
}

const optionKeys = new Set<string>(sketchOptionKeys);

/**
 * The passthrough `<svg>` attributes of [props]. Reads the props it needs
 * without going through `splitSketchOptions`, so the memo comparator stays
 * independent of the render path.
 */
function svgAttributes(
  props: SketchProps,
): Omit<SketchProps, keyof SketchOptions | "shape" | "width" | "height" | "viewBox" | "label" | "title" | "description"> {
  const {
    shape: _shape,
    width: _width,
    height: _height,
    viewBox: _viewBox,
    label: _label,
    title: _title,
    description: _description,
    ...rest
  } = props;
  const attributes: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(rest)) {
    if (!optionKeys.has(key)) attributes[key] = value;
  }
  return attributes as Omit<
    SketchProps,
    keyof SketchOptions | "shape" | "width" | "height" | "viewBox" | "label" | "title" | "description"
  >;
}

function shallowEqual(a: object, b: object): boolean {
  const aKeys = Object.keys(a);
  for (const key of aKeys) {
    if ((a as Record<string, unknown>)[key] !== (b as Record<string, unknown>)[key]) return false;
  }
  return aKeys.length === Object.keys(b).length;
}

/**
 * Re-renders only when the drawing or the `<svg>` attributes change: inline
 * shape and option objects compare by value through `sketchKey`, so callers
 * do not have to memoise their props.
 */
function sketchPropsEqual(prev: SketchProps, next: SketchProps): boolean {
  if (prev === next) return true;
  if (
    prev.width !== next.width ||
    prev.height !== next.height ||
    prev.viewBox !== next.viewBox ||
    prev.label !== next.label ||
    prev.title !== next.title ||
    prev.description !== next.description
  ) {
    return false;
  }
  if (sketchKey(prev.shape, pickSketchOptions(prev)) !== sketchKey(next.shape, pickSketchOptions(next))) return false;
  return shallowEqual(svgAttributes(prev), svgAttributes(next));
}

function SketchImpl(props: SketchProps) {
  const { shape, width, height, viewBox, label, title, description, ...rest } = props;
  const [options, svgProps] = splitSketchOptions(rest);
  const { paths } = useSketch(shape, options);
  const named = label !== undefined || title !== undefined || description !== undefined;
  const a11y = named
    ? { role: "img" as const, ...(label === undefined ? {} : { "aria-label": label }) }
    : { "aria-hidden": true, focusable: false };

  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={width}
      height={height}
      viewBox={viewBox ?? `0 0 ${width} ${height}`}
      {...a11y}
      {...(svgProps as SVGProps<SVGSVGElement>)}
    >
      {title === undefined ? undefined : <title>{title}</title>}
      {description === undefined ? undefined : <desc>{description}</desc>}
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
export const Sketch = memo(SketchImpl, sketchPropsEqual);
