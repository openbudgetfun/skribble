/**
 * Hand-drawn sketches for React Native.
 *
 * `<Sketch>` draws one shape (or several) with skribble's rough engine and
 * paints it with `react-native-svg`. The same seed draws the same ink as the
 * web and Flutter versions of skribble.
 *
 * @packageDocumentation
 */
import { sketch, sketchKey, splitSketchOptions, type Shape, type Sketch as SketchResult, type SketchOptions } from "@skribble/rough";
import { useMemo } from "react";
import { Path, Svg, type SvgProps } from "react-native-svg";

export type { PointLike, RoughFillStyle, RoughPenName, Shape, SketchOptions, SketchPath } from "@skribble/rough";

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
   * An accessible description. Without one the sketch is hidden from screen
   * readers.
   */
  label?: string;
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
export function Sketch(props: SketchProps) {
  const { shape, width, height, label, ...rest } = props;
  const [options, svgProps] = splitSketchOptions(rest);
  const { paths } = useSketch(shape, options);
  const a11y: Partial<SvgProps> =
    label === undefined
      ? { accessibilityElementsHidden: true, importantForAccessibility: "no-hide-descendants" }
      : { accessible: true, accessibilityRole: "image", accessibilityLabel: label };

  return (
    <Svg width={width} height={height} viewBox={`0 0 ${width} ${height}`} {...a11y} {...(svgProps as SvgProps)}>
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
