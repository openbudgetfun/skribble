---
skribble: minor
---

Preserve colours from source SVG artwork through the rough rendering pipeline:

- Add `fillColor`/`strokeColor`/`strokeWidth` to `WiredSvgPrimitive`
- Parse SVG paint attributes with group inheritance in `generate_emoji.dart`
- Paint each precomputed primitive with its own colour (rough solid fill for
  enclosed areas, wobbled outline for strokes) instead of a single ambient
  colour
- Regenerate all 1,820 emoji with their OpenMoji colour palettes flowing
  through
- Icon default fill changed from hachure to the new rough solid wire fill
- Amplify rough engine defaults (maxRandomnessOffset, roughness, bowing) for
  clearly visible hand-drawn wobble at any icon size
- Improve font roughening: 4× more aggressive jitter, silhouette displacement
  applied to both on-curve and off-curve Bézier control points
- Regenerate all 4 Skribble typeface variants with aggressive contour
  displacement across all 1,479 foreground contours
