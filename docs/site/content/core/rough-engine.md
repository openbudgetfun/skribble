---
title: Rough Engine
description: Complete guide to Skribble's Dart port of rough.js -- DrawConfig, Generator, Filler system, Drawable data structures, and canvas rendering.
---

# Rough Engine

Skribble's hand-drawn aesthetic comes from a Dart port of [rough.js](https://roughjs.com/). The engine lives in `packages/skribble/lib/src/rough/` and is re-exported through `package:skribble/skribble.dart`. Every wobbly border, hachure fill, and imperfect line in Skribble passes through this engine.

## Overview

The engine has four core pieces:

| Concept              | Purpose                                                             |
| -------------------- | ------------------------------------------------------------------- |
| `DrawConfig`         | Controls randomness, roughness, bowing, and curve parameters        |
| `Generator`          | Produces `Drawable` shapes (rectangles, circles, polygons, etc.)    |
| `Filler`             | Fills polygon interiors with patterns (hachure, dots, zigzag, etc.) |
| `Drawable` / `OpSet` | Data structures holding drawing operations for the canvas           |

The typical flow is:

```dart
final config = DrawConfig.build(roughness: 1.5, seed: 42);
final filler = HachureFiller(FillerConfig.defaultConfig);
final generator = Generator(config, filler);
final drawable = generator.rectangle(0, 0, 200, 100);
canvas.drawRough(drawable, pathPaint, fillPaint);
```

## DrawConfig

`DrawConfig` describes how a shape is drawn. Every field controls a different aspect of the hand-drawn imperfection.

### Fields

| Field                 | Type         | Default | Description                                                          |
| --------------------- | ------------ | ------- | -------------------------------------------------------------------- |
| `maxRandomnessOffset` | `double`     | `2`     | Maximum pixel offset for random jitter                               |
| `roughness`           | `double`     | `1`     | Overall roughness multiplier -- higher values produce wobblier lines |
| `bowing`              | `double`     | `1`     | How much lines bow outward at the midpoint                           |
| `curveFitting`        | `double`     | `0.95`  | How closely curves follow the intended path (0 = loose, 1 = tight)   |
| `curveTightness`      | `double`     | `0`     | Tension of Catmull-Rom splines                                       |
| `curveStepCount`      | `double`     | `9`     | Number of steps when generating curved segments                      |
| `seed`                | `int`        | `1`     | Random seed for deterministic output                                 |
| `randomizer`          | `Randomizer` | seeded  | Pseudo-random number generator                                       |

### Creating a DrawConfig

Use `DrawConfig.build()` to create a config with defaults for any unspecified field:

```dart
// All defaults
final config = DrawConfig.defaultValues;

// Custom roughness and seed
final config = DrawConfig.build(
  roughness: 2.0,
  seed: 42,
);
```

Use `copyWith` to derive a new config from an existing one:

```dart
final smooth = DrawConfig.build(roughness: 0.5);
final rough = smooth.copyWith(roughness: 3.0);
```

### Offset Methods

`DrawConfig` exposes two helper methods used internally by the renderer:

```dart
// Random value between min and max, scaled by roughness
double value = config.offset(0, 10);

// Random value between -x and +x, scaled by roughness
double value = config.offsetSymmetric(5);
```

Both accept an optional `roughnessGain` parameter that further scales the output.

### Randomizer

The `Randomizer` class wraps Dart's `Random` with a resettable seed. Calling `reset()` replays the same sequence of random numbers, ensuring that a shape looks identical across rebuilds.

```dart
final randomizer = Randomizer(seed: 42);
print(randomizer.next()); // 0.548...
print(randomizer.next()); // 0.193...
randomizer.reset();
print(randomizer.next()); // 0.548... (same as first call)
```

The `WiredPainter` `CustomPainter` calls `drawConfig.randomizer!.reset()` before every paint, which is why shapes stay visually stable.

## Generator

`Generator` is the main entry point for producing rough shapes. It takes a `DrawConfig` and a `Filler`, and exposes methods for every supported shape.

```dart
final generator = Generator(drawConfig, filler);
```

### Shape Methods

#### line

Draws a single hand-drawn line between two points.

```dart
final drawable = generator.line(0, 0, 200, 100);
```

#### rectangle

Draws a rectangle with a filled interior.

```dart
final drawable = generator.rectangle(10, 10, 180, 80);
```

The fill points are the four corners of the rectangle, passed to the active `Filler`.

#### circle

Draws a circle as a special case of `ellipse` with equal width and height.

```dart
// Center at (100, 100), diameter 80
final drawable = generator.circle(100, 100, 80);
```

#### ellipse

Draws an ellipse with independent width and height.

```dart
final drawable = generator.ellipse(100, 100, 160, 80);
```

#### polygon

Draws an arbitrary closed polygon from a list of `PointD` vertices.

```dart
final drawable = generator.polygon([
  PointD(0, 0),
  PointD(100, 0),
  PointD(50, 80),
]);
```

#### arc

Draws an arc segment, optionally closed.

```dart
import 'dart:math';

// Open arc
final drawable = generator.arc(100, 100, 80, 80, 0, pi);

// Closed arc (pie slice)
final drawable = generator.arc(100, 100, 80, 80, 0, pi, true);
```

#### linearPath

Draws an open path through a series of points (not closed like `polygon`).

```dart
final drawable = generator.linearPath([
  PointD(0, 50),
  PointD(50, 0),
  PointD(100, 50),
  PointD(150, 0),
]);
```

#### roundedRectangle

Draws a rectangle with individually configurable corner radii.

```dart
final drawable = generator.roundedRectangle(
  0,    // x
  0,    // y
  200,  // width
  100,  // height
  12,   // topLeft radius
  12,   // topRight radius
  12,   // bottomRight radius
  12,   // bottomLeft radius
);
```

Radii are automatically clamped to half the shortest side to prevent overlapping corners.

#### curvePath

Draws a smooth curve through a series of points.

```dart
final drawable = generator.curvePath([
  PointD(0, 50),
  PointD(50, 0),
  PointD(100, 50),
  PointD(150, 0),
]);
```

## Filler System

Fillers control how the interior of a closed shape is painted. Every `Filler` subclass implements `fill(List<PointD> points)` and returns an `OpSet` with the fill operations.

### FillerConfig

`FillerConfig` holds parameters shared across all filler types:

| Field          | Type         | Default                    | Description                          |
| -------------- | ------------ | -------------------------- | ------------------------------------ |
| `drawConfig`   | `DrawConfig` | `DrawConfig.defaultValues` | Base drawing config for fill strokes |
| `fillWeight`   | `double`     | `1`                        | Weight / thickness of fill strokes   |
| `hachureAngle` | `double`     | `320`                      | Angle of hachure lines in degrees    |
| `hachureGap`   | `double`     | `15`                       | Spacing between hachure lines        |
| `dashOffset`   | `double`     | `15`                       | Length of each dash in dashed fills  |
| `dashGap`      | `double`     | `2`                        | Gap between dashes                   |
| `zigzagOffset` | `double`     | `5`                        | Amplitude of zigzag lines            |

```dart
final fillerConfig = FillerConfig.build(
  hachureAngle: 45,
  hachureGap: 10,
  fillWeight: 2,
);
```

### Filler Subclasses

#### NoFiller

Produces no fill at all. Shapes render as outlines only.

```dart
final filler = NoFiller();
```

#### HachureFiller

Fills with parallel lines at the configured `hachureAngle`.

```dart
final filler = HachureFiller(FillerConfig.build(
  hachureAngle: 320,
  hachureGap: 15,
));
```

#### ZigZagFiller

Like hachure, but the fill lines connect end-to-end in a zigzag pattern.

```dart
final filler = ZigZagFiller(FillerConfig.build(
  hachureGap: 10,
));
```

#### HatchFiller

Cross-hatching: runs two perpendicular hachure passes (the second rotated 90 degrees from the first).

```dart
final filler = HatchFiller(FillerConfig.build(
  hachureAngle: 45,
));
```

#### DotFiller

Scatters small ellipses (dots) across the fill area.

```dart
final filler = DotFiller(FillerConfig.build(
  hachureGap: 12,
  fillWeight: 2,
));
```

#### DashedFiller

Fills with dashed line segments controlled by `dashOffset` and `dashGap`.

```dart
final filler = DashedFiller(FillerConfig.build(
  dashOffset: 10,
  dashGap: 3,
));
```

#### SolidFiller

Fills with a solid path (no pattern). The path is slightly offset by `fillWeight` for a hand-drawn feel.

```dart
final filler = SolidFiller();
```

### RoughFilter Enum

`RoughFilter` is a convenience enum that maps to `Filler` subclasses. `WiredCanvas` uses it to select the fill type without constructing a `Filler` instance directly.

```dart
enum RoughFilter {
  noFiller,       // -> NoFiller
  hachureFiller,  // -> HachureFiller
  zigZagFiller,   // -> ZigZagFiller
  hatchFiller,    // -> HatchFiller
  dotFiller,      // -> DotFiller
  dashedFiller,   // -> DashedFiller
  solidFiller,    // -> SolidFiller
}
```

Usage with `WiredCanvas`:

```dart
WiredCanvas(
  painter: WiredRectangleBase(),
  fillerType: RoughFilter.hachureFiller,
)
```

## Drawable and OpSet

### OpSet

An `OpSet` is a list of drawing operations (`Op`) with a type that tells the canvas how to render them:

```dart
class OpSet {
  OpSetType? type;
  List<Op>? ops;
}

enum OpSetType {
  path,       // Outline stroke
  fillPath,   // Solid fill (closed path)
  fillSketch, // Sketchy fill pattern (hachure, dots, etc.)
}
```

### Op

A single drawing operation -- move, lineTo, or curveTo:

```dart
class Op {
  final OpType op;
  final List<PointD> data;

  Op.move(PointD point);                                    // Move to point
  Op.lineTo(PointD point);                                  // Line to point
  Op.curveTo(PointD control1, PointD control2, PointD end); // Cubic bezier
}

enum OpType { move, curveTo, lineTo }
```

### Drawable

A `Drawable` is the output of a `Generator` shape method. It contains one or more `OpSet` instances (typically one for the outline and one for the fill) plus the `DrawConfig` that produced them.

```dart
class Drawable {
  String? shape;
  DrawConfig? options;
  List<OpSet>? sets;
}
```

### PointD

`PointD` extends `Point<double>` with polygon containment testing:

```dart
final point = PointD(50, 50);
final polygon = [PointD(0, 0), PointD(100, 0), PointD(100, 100), PointD(0, 100)];
print(point.isInPolygon(polygon)); // true
```

## Canvas Extension: drawRough

The `Rough` extension on `Canvas` renders a `Drawable` to the Flutter canvas:

```dart
extension Rough on Canvas {
  void drawRough(Drawable drawable, Paint pathPaint, Paint fillPaint);
}
```

It iterates over each `OpSet` in the `Drawable`:

- **`OpSetType.path`** -- draws the outline using `pathPaint`
- **`OpSetType.fillPath`** -- closes the path and fills it using `fillPaint` with `PaintingStyle.fill`
- **`OpSetType.fillSketch`** -- draws the sketchy fill pattern using `fillPaint`

### Full Rendering Example

```dart
import 'package:flutter/material.dart';
import 'package:skribble/skribble.dart';

class RoughDemoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final config = DrawConfig.build(roughness: 1.5, seed: 7);
    final filler = HachureFiller(FillerConfig.build(
      hachureAngle: 45,
      hachureGap: 8,
    ));
    final generator = Generator(config, filler);

    // Draw a filled rectangle
    final rect = generator.rectangle(20, 20, size.width - 40, size.height - 40);
    canvas.drawRough(
      rect,
      Paint()
        ..color = const Color(0xFF1A2B3C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

## RoughBoxDecoration

`RoughBoxDecoration` is a `Decoration` that replaces `BoxDecoration` for sketchy containers. Use it with any `Container` or `DecoratedBox`:

```dart
Container(
  width: 200,
  height: 100,
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.rectangle,
    borderStyle: RoughDrawingStyle(
      width: 2,
      color: Color(0xFF1A2B3C),
    ),
    fillStyle: RoughDrawingStyle(
      width: 1,
      color: Color(0xFFE8E8E8),
    ),
    drawConfig: DrawConfig.build(roughness: 1.5),
    filler: HachureFiller(),
  ),
  child: Center(child: Text('Sketchy box')),
)
```

### RoughBoxShape

The decoration supports four shapes:

```dart
enum RoughBoxShape {
  rectangle,        // Axis-aligned rectangle
  roundedRectangle, // Rectangle with configurable corner radii
  circle,           // Circle inscribed in the bounding box
  ellipse,          // Ellipse filling the bounding box
}
```

For rounded rectangles, pass a `borderRadius`:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.roundedRectangle,
  borderRadius: BorderRadius.circular(16),
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
)
```

### RoughDrawingStyle

Controls the paint properties for borders and fills:

| Field       | Type         | Description                       |
| ----------- | ------------ | --------------------------------- |
| `width`     | `double?`    | Stroke width in pixels            |
| `color`     | `Color?`     | Solid color                       |
| `gradient`  | `Gradient?`  | Gradient shader (overrides color) |
| `blendMode` | `BlendMode?` | Blend mode for the paint          |

## Low-Level Internals

### OpSetBuilder

`OpSetBuilder` is a static utility class that builds `OpSet` instances for each shape type. `Generator` delegates to it internally:

- `OpSetBuilder.buildLine(x1, y1, x2, y2, config)` -- single line segment
- `OpSetBuilder.buildPolygon(points, config)` -- closed polygon outline
- `OpSetBuilder.linearPath(points, close, config)` -- open or closed path
- `OpSetBuilder.ellipse(x, y, width, height, config)` -- ellipse outline
- `OpSetBuilder.arc(center, width, height, start, stop, closed, roughClosure, config)` -- arc segment
- `OpSetBuilder.curve(points, config)` -- smooth curve through points

### OpsGenerator

`OpsGenerator` produces raw `List<Op>` data used by `OpSetBuilder`:

- `OpsGenerator.doubleLine(x1, y1, x2, y2, config)` -- two overlapping line strokes for the hand-drawn look
- `OpsGenerator.curve(points, config)` -- Catmull-Rom spline through points
- `OpsGenerator.curveWithOffset(points, offset, config)` -- offset curve for wobble
- `OpsGenerator.arc(increment, cx, cy, rx, ry, start, stop, offset, config)` -- arc points

The "double line" technique -- drawing each edge twice with slightly different random offsets -- is what gives Skribble its characteristic sketchy stroke.
