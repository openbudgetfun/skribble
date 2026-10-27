/**
 * Hand-drawn sketches for React Native.
 *
 * `<Sketch>` draws one shape (or several) with skribble's rough engine and
 * paints it with `react-native-svg`. The same seed draws the same ink as the
 * web and Flutter versions of skribble, and the component is memoised on
 * what it draws, so re-rendering a parent with unchanged sketch props costs
 * nothing.
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
import { memo, useMemo } from "react";
import { Path, Svg, type SvgProps } from "react-native-svg";

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

/** Props for {@link Sketch}. Other `react-native-svg` props pass through. */
export interface SketchProps
  extends SketchOptions,
    Omit<SvgProps, keyof SketchOptions | "children" | "width" | "height" | "viewBox"> {
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
   * An accessible description. Without one the sketch is hidden from screen
   * readers. `react-native-svg` has no `<title>` element, so description
   * belongs in `label`.
   */
  label?: string;
}

const optionKeys = new Set<string>(sketchOptionKeys);

/**
 * The passthrough `<Svg>` props of [props]. Reads the props it needs without
 * going through `splitSketchOptions`, so the memo comparator stays
 * independent of the render path.
 */
function svgAttributes(props: SketchProps): Omit<SketchProps, keyof SketchOptions | "shape" | "width" | "height" | "viewBox" | "label"> {
  const { shape: _shape, width: _width, height: _height, viewBox: _viewBox, label: _label, ...rest } = props;
  const attributes: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(rest)) {
    if (!optionKeys.has(key)) attributes[key] = value;
  }
  return attributes as Omit<SketchProps, keyof SketchOptions | "shape" | "width" | "height" | "viewBox" | "label">;
}

function shallowEqual(a: object, b: object): boolean {
  const aKeys = Object.keys(a);
  for (const key of aKeys) {
    if ((a as Record<string, unknown>)[key] !== (b as Record<string, unknown>)[key]) return false;
  }
  return aKeys.length === Object.keys(b).length;
}

/**
 * Re-renders only when the drawing or the `<Svg>` props change: inline shape
 * and option objects compare by value through `sketchKey`, so callers do not
 * have to memoise their props.
 */
function sketchPropsEqual(prev: SketchProps, next: SketchProps): boolean {
  if (prev === next) return true;
  if (
    prev.width !== next.width ||
    prev.height !== next.height ||
    prev.viewBox !== next.viewBox ||
    prev.label !== next.label
  ) {
    return false;
  }
  if (sketchKey(prev.shape, pickSketchOptions(prev)) !== sketchKey(next.shape, pickSketchOptions(next))) return false;
  return shallowEqual(svgAttributes(prev), svgAttributes(next));
}

function SketchImpl(props: SketchProps) {
  const { shape, width, height, viewBox, label, ...rest } = props;
  const [options, svgProps] = splitSketchOptions(rest);
  const { paths } = useSketch(shape, options);
  const a11y: Partial<SvgProps> =
    label === undefined
      ? { accessibilityElementsHidden: true, importantForAccessibility: "no-hide-descendants" }
      : { accessible: true, accessibilityRole: "image", accessibilityLabel: label };

  return (
    <Svg width={width} height={height} viewBox={viewBox ?? `0 0 ${width} ${height}`} {...a11y} {...(svgProps as SvgProps)}>
      {paths.map((path) =>
        path.stroke === "none" ? (
          <Path key={path.key} d={path.d} fill={path.fill} stroke="none" />
        ) : (
          <Path
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
    </Svg>
  );
}

/**
 * A standalone hand-drawn doodle at an explicit size.
 *
 * Ink and fill default to `currentColor`; set the `color` prop to theme
 * them, or pass `stroke` and `fill` directly.
 *
 * ```tsx
 * <Sketch width={120} height={60} color="#1f1d1a" shape={{ type: "circle", x: 60, y: 30, diameter: 50 }} />
 * ```
 */
export const Sketch = memo(SketchImpl, sketchPropsEqual);
