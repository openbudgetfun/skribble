---
skribble: major
skribble_maps: patch
---

# Ink every line with a pressure-sensitive pen

The rough engine now separates where a line goes from how its ink lands. A new `RoughPen` turns each rough centreline into a variable-width stroke: a light touchdown that swells to full width, slow pressure changes, a thinner lift, lighter and partial repeat passes, and closed loops that overshoot their start and curl inward. Each `WiredRoughness` level brings a pen (`fineliner`, `ink`, `brush`), and `WiredThemeData(pen: RoughPen.uniform)` restores constant-width lines.

`DrawConfig`, `FillerConfig`, `Filler.config`, and `Generator` lost their nullable fields, `Op.move` records the pen pass, and `Canvas.drawRough` paints through `RoughDrawing` so it inks with the drawable's pen:

```dart
// Before
final amplitude = config.roughness! * (config.maxRandomnessOffset ?? 1);

// After
final amplitude = config.roughness * config.maxRandomnessOffset;
final theme = WiredThemeData(pen: RoughPen.brush);
```

The pen is pure Dart: `InkStroke` and `DrawableInk` export the painted ink as SVG path data, and the design kit now hands Figma filled ink outlines. Long-edge bowing is capped at `maxRandomnessOffset` so wide cards stay inside their reserved bleed.
