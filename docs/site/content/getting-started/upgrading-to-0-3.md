---
title: Upgrading to 0.3
description: How to migrate an app to skribble 0.3, where every line is inked by a pen and the rough engine's configuration types lost their nullable fields.
---

# Upgrading to 0.3

skribble 0.3 changes how lines _look_ more than how widgets are used. Every border, fill stroke, and icon is now laid down by a pen, with tapered ends, gentle pressure, lighter second passes, and loops that close by overshooting. Most apps upgrade by changing the version number and looking at their screens.

The breaking changes are in the rough engine's public types, which custom painters and design tooling use directly.

## Do I have to migrate?

Only if you touch the rough engine yourself: custom `WiredPainterBase` subclasses, direct `Generator` or `DrawConfig` use, or `Filler` subclasses. Apps that only use `Wired*` widgets and `WiredThemeData` keep compiling.

## Lines are inked by a pen

Each `WiredRoughness` level now brings a `RoughPen`: gentle draws with `RoughPen.fineliner`, playful with `RoughPen.ink`, and expressive with `RoughPen.brush`. To keep the 0.2 constant-width look, ask for the uniform pen:

```dart
// Static example: configuration
final theme = WiredThemeData(pen: RoughPen.uniform);
```

Painters reserve `strokeWidth * pen.reach` as bleed instead of half the stroke width, so ink stays inside clipped parents when pressure swells. Shapes drawn with an inking pen sit very slightly further inside their bounds than in 0.2.

`Canvas.drawRough` now paints through a `RoughDrawing`, so it inks with the drawable's pen too. A drawable without options, or one built with `RoughPen.uniform`, paints exactly as before.

## `DrawConfig`, `FillerConfig`, `Filler`, and `Generator` are non-nullable

Every `DrawConfig` field now has a value, so the `!` and `??` you needed before become warnings:

```dart
// Static example: configuration
// Before
final amplitude = config.roughness! * (config.maxRandomnessOffset ?? 1);
config.randomizer?.reset();

// After
final amplitude = config.roughness * config.maxRandomnessOffset;
config.randomizer.reset();
```

The same applies to:

| Type           | What changed                                                                                      |
| -------------- | ------------------------------------------------------------------------------------------------- |
| `DrawConfig`   | All fields non-null; new `pen`; `copyWith` no longer accepts a `randomizer` and always reseeds    |
| `FillerConfig` | All fields non-null, including `drawConfig`                                                       |
| `Filler`       | `config` is a non-null `FillerConfig`; `buildFillLines` requires a config instead of falling back |
| `Generator`    | `drawConfig` and `filler` are non-null fields                                                     |
| `Op`           | `Op.move` takes an optional `pass`; contours with `pass: 1` are repeat strokes                    |

If you subclassed `Filler`, read `config` instead of the private `_config`.

## Long edges bow less

Line bowing used to grow without limit along very long edges, which could push a 1,440-pixel card border past the bleed its painter reserves. Bowing is now capped at `maxRandomnessOffset`. Long borders are a touch straighter; short ones are unchanged.

## Design exports carry the real ink

`dart run packages/skribble/tool/design_kit.dart` now exports filled ink outlines, matching what the app paints, instead of centreline strokes. If you import the specimens into Figma, re-import them after upgrading. Build your own exports with `DrawableInk(...).svgPaths()`; see [Pens](/core/rough-engine#pens).
