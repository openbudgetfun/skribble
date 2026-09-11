---
skribble: minor
---

# Preserve source colours through the roughened rendering pipeline

`WiredSvgPrimitive` carries `fillColor`, `strokeColor`, and `strokeWidth`, SVG paint attributes parse with group inheritance, and every primitive paints with its own colour — rough solid fill for enclosed areas (now the icon default, replacing hachure) and wobbled outlines for strokes. Rough engine parameters were amplified for a clearly hand-drawn look at any size: maxRandomnessOffset 3x, roughness 2.4, bowing 2.2, curveFitting 0 for jagged polylines, fill wobble amplitude up to shortestSide/8, and a double-pass canvas translate that layers pen strokes on per-colour primitives while keeping visible centres in small circular controls.
