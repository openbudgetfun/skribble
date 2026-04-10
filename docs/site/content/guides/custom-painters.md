---
title: Custom Painters
description: How to create custom shape painters that plug into Skribble's rough-drawing engine, from extending WiredPainterBase to composing shapes with WiredCanvas.
---

# Custom Painters

Skribble's rendering pipeline is built on a small set of composable primitives. When the built-in rectangle, circle, line, and rounded rectangle painters do not cover your shape, you can create a custom painter that plugs into the same rough engine.

## Architecture overview

The rendering stack has three layers:

1. **`WiredPainterBase`** -- abstract class that defines the `paintRough()` contract
2. **`Generator`** -- creates `Drawable` objects from geometric parameters
3. **`WiredCanvas`** -- a `HookWidget` that wires a painter to a `Filler` and renders via `CustomPaint`

When you build a custom painter, you implement layer 1 and use layer 2 inside it. Layer 3 handles the rest.

## Step 1: Extend WiredPainterBase

`WiredPainterBase` has a single method to implement:

```dart
abstract class WiredPainterBase {
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  );
}
```

- **`canvas`** -- the Flutter `Canvas` to draw on
- **`size`** -- the available size from the parent widget
- **`drawConfig`** -- roughness, bowing, curveFitting, seed, and other drawing parameters
- **`filler`** -- the fill pattern algorithm (hachure, zigzag, dots, etc.)

## Step 2: Use Generator to create Drawables

Inside `paintRough()`, create a `Generator` from the config and filler, then call its shape methods:

```dart
final generator = Generator(drawConfig, filler);
```

The generator provides these shape constructors:

| Method                                                   | Parameters                      |
| -------------------------------------------------------- | ------------------------------- |
| `generator.rectangle(x, y, width, height)`               | Top-left origin and dimensions  |
| `generator.circle(cx, cy, diameter)`                     | Center point and diameter       |
| `generator.ellipse(cx, cy, width, height)`               | Center point and radii          |
| `generator.line(x1, y1, x2, y2)`                         | Start and end points            |
| `generator.polygon(List<PointD>)`                        | Closed polygon from vertex list |
| `generator.arc(x, y, w, h, start, stop, closed)`         | Arc segment                     |
| `generator.roundedRectangle(x, y, w, h, tl, tr, br, bl)` | Rounded corners                 |

Each returns a `Drawable` that holds the rough path data.

## Step 3: Render with canvas.drawRough()

The `drawRough()` extension method on `Canvas` renders a `Drawable` with separate border and fill paints:

```dart
canvas.drawRough(drawable, borderPaint, fillPaint);
```

Use `WiredBase.pathPainter()` and `WiredBase.fillPainter()` for standard paint objects:

```dart
canvas.drawRough(
  figure,
  WiredBase.pathPainter(strokeWidth, color: borderColor),
  WiredBase.fillPainter(fillColor),
);
```

## Step 4: Compose with WiredCanvas

`WiredCanvas` is a `HookWidget` that takes a `WiredPainterBase` and handles filler creation, `CustomPaint` wiring, and lifecycle:

```dart
WiredCanvas(
  painter: MyCustomPainter(),
  fillerType: RoughFilter.hachureFiller,
  drawConfig: DrawConfig.defaultValues,
  fillerConfig: FillerConfig.defaultConfig,
  size: Size(200, 200),
)
```

## Complete example: Star painter

Here is a full custom painter that draws a five-pointed star:

```dart
import 'dart:math' as math;
import 'dart:ui';

import 'package:skribble/skribble.dart';

/// Draws a hand-drawn five-pointed star.
class WiredStarPainter extends WiredPainterBase {
  final Color borderColor;
  final Color fillColor;
  final double strokeWidth;

  WiredStarPainter({
    this.borderColor = const Color(0xFF1A2B3C),
    this.fillColor = const Color(0xFFFEFEFE),
    this.strokeWidth = 2,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final generator = Generator(drawConfig, filler);

    // Compute star vertices
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerRadius = math.min(cx, cy) * 0.95;
    final innerRadius = outerRadius * 0.38;
    final points = <PointD>[];

    for (var i = 0; i < 5; i++) {
      // Outer vertex
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      points.add(PointD(
        cx + outerRadius * math.cos(outerAngle),
        cy + outerRadius * math.sin(outerAngle),
      ));

      // Inner vertex
      final innerAngle = ((i * 72) + 36 - 90) * math.pi / 180;
      points.add(PointD(
        cx + innerRadius * math.cos(innerAngle),
        cy + innerRadius * math.sin(innerAngle),
      ));
    }

    final figure = generator.polygon(points);
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}
```

Use it in a widget:

```dart
WiredCanvas(
  painter: WiredStarPainter(
    borderColor: Colors.orange,
    fillColor: Colors.amber.shade100,
  ),
  fillerType: RoughFilter.hachureFiller,
  size: const Size(120, 120),
)
```

## Complete example: Wave painter

This painter draws a rough sine wave line:

```dart
import 'dart:math' as math;
import 'dart:ui';

import 'package:skribble/skribble.dart';

/// Draws a hand-drawn sine wave across the available width.
class WiredWavePainter extends WiredPainterBase {
  final Color color;
  final double strokeWidth;
  final int cycles;
  final double amplitude;

  WiredWavePainter({
    this.color = const Color(0xFF1A2B3C),
    this.strokeWidth = 2,
    this.cycles = 3,
    this.amplitude = 0.3,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final generator = Generator(drawConfig, filler);
    final segmentCount = cycles * 12;
    final midY = size.height / 2;
    final waveHeight = size.height * amplitude;

    // Draw the wave as a series of connected line segments
    for (var i = 0; i < segmentCount; i++) {
      final x1 = size.width * (i / segmentCount);
      final x2 = size.width * ((i + 1) / segmentCount);
      final y1 = midY + waveHeight *
          math.sin(2 * math.pi * cycles * (i / segmentCount));
      final y2 = midY + waveHeight *
          math.sin(2 * math.pi * cycles * ((i + 1) / segmentCount));

      final segment = generator.line(x1, y1, x2, y2);
      canvas.drawRough(
        segment,
        WiredBase.pathPainter(strokeWidth, color: color),
        WiredBase.fillPainter(color),
      );
    }
  }
}
```

## Built-in painters reference

Skribble ships these painters in `wired_base.dart`:

### WiredRectangleBase

```dart
WiredRectangleBase(
  leftIndent: 0.0,    // inset from the left edge
  rightIndent: 0.0,   // inset from the right edge
  fillColor: fillColor,
  borderColor: borderColor,
  strokeWidth: 2,
)
```

### WiredCircleBase

```dart
WiredCircleBase(
  diameterRatio: 1,   // multiplier on the bounding dimension
  fillColor: fillColor,
  borderColor: borderColor,
  strokeWidth: 2,
)
```

### WiredLineBase

```dart
WiredLineBase(
  x1: 0, y1: 0,       // start point
  x2: 100, y2: 100,   // end point
  borderColor: borderColor,
  strokeWidth: 1,
)
```

### WiredRoundedRectangleBase

```dart
WiredRoundedRectangleBase(
  borderRadius: BorderRadius.all(Radius.circular(12)),
  fillColor: fillColor,
  borderColor: borderColor,
  strokeWidth: 2,
)
```

### WiredInvertedTriangleBase

```dart
WiredInvertedTriangleBase(
  borderColor: borderColor,
  strokeWidth: 2,
)
```

## Advanced: Combining multiple generators

A single `paintRough()` call can draw multiple shapes. Each `Generator` call creates an independent `Drawable`:

```dart
@override
void paintRough(Canvas canvas, Size size, DrawConfig drawConfig, Filler filler) {
  final generator = Generator(drawConfig, filler);
  final paint = WiredBase.pathPainter(2, color: borderColor);
  final fill = WiredBase.fillPainter(fillColor);

  // Draw a rectangle body
  final body = generator.rectangle(10, 10, size.width - 20, size.height - 30);
  canvas.drawRough(body, paint, fill);

  // Draw a circle highlight in the top-right corner
  final dot = generator.circle(size.width - 20, 20, 16);
  canvas.drawRough(dot, paint, fill);

  // Draw a divider line across the middle
  final divider = generator.line(10, size.height / 2, size.width - 10, size.height / 2);
  canvas.drawRough(divider, paint, fill);
}
```

## Advanced: Custom fill patterns

Control fill behavior by adjusting `FillerConfig`:

```dart
WiredCanvas(
  painter: WiredStarPainter(),
  fillerType: RoughFilter.zigZagFiller,
  fillerConfig: FillerConfig.build(
    hachureAngle: 45,       // angle of fill strokes in degrees
    hachureGap: 8,          // spacing between fill strokes
    dashOffset: 10,         // dash offset for dashed filler
    dashGap: 3,             // gap between dashes
    zigzagOffset: 6,        // zigzag displacement
  ),
)
```

Available `RoughFilter` values:

| Filter          | Description               |
| --------------- | ------------------------- |
| `noFiller`      | No fill, border only      |
| `hachureFiller` | Parallel diagonal strokes |
| `zigZagFiller`  | Zigzag strokes            |
| `hatchFiller`   | Cross-hatched strokes     |
| `dotFiller`     | Dot pattern               |
| `dashedFiller`  | Dashed strokes            |
| `solidFiller`   | Solid fill                |

## Using a custom painter in a widget

The typical pattern stacks `WiredCanvas` behind content using a `Stack`:

```dart
class WiredStarBadge extends HookWidget {
  final Widget child;

  const WiredStarBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return buildWiredElement(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredStarPainter(
                  borderColor: theme.borderColor,
                  fillColor: theme.fillColor,
                ),
                fillerType: RoughFilter.hachureFiller,
              ),
            ),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
```

This is the same pattern used by `WiredCard`, `WiredToggle`, and other built-in widgets.
