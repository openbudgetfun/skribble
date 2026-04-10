---
title: Painters
description: Guide to WiredPainterBase, all concrete shape painters, WiredCanvas, WiredBase utilities, RepaintBoundary isolation, and creating custom painters.
---

# Painters

The painter layer sits between the raw rough engine and the finished Wired widgets. It defines a simple contract -- `paintRough(Canvas, Size, DrawConfig, Filler)` -- that each shape implements. Understanding painters is essential for creating custom Wired widgets or modifying how existing shapes render.

## WiredPainterBase

`WiredPainterBase` is the abstract class all shape painters extend. It lives in `packages/skribble/lib/src/canvas/wired_painter_base.dart`.

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

Parameters:

| Parameter | Purpose |
|---|---|
| `canvas` | The Flutter `Canvas` to draw on |
| `size` | The available area for the shape |
| `drawConfig` | Controls roughness, bowing, seed, and other engine parameters |
| `filler` | The fill algorithm (hachure, dots, solid, etc.) |

Every concrete painter follows the same three-step pattern inside `paintRough`:

1. Create a `Generator` from the `drawConfig` and `filler`
2. Call a `Generator` shape method to produce a `Drawable`
3. Render the `Drawable` with `canvas.drawRough(drawable, pathPaint, fillPaint)`

## Concrete Painters

All concrete painters live in `packages/skribble/lib/src/wired_base.dart`.

### WiredRectangleBase

Draws an axis-aligned rectangle with optional left and right indents.

```dart
class WiredRectangleBase extends WiredPainterBase {
  final double leftIndent;
  final double rightIndent;
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  WiredRectangleBase({
    this.leftIndent = 0.0,
    this.rightIndent = 0.0,
    this.fillColor = const Color(0xFFFEFEFE),
    this.borderColor = const Color(0xFF1A2B3C),
    this.strokeWidth = 2,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final Drawable figure = generator.rectangle(
      0 + leftIndent,
      0,
      size.width - leftIndent - rightIndent,
      size.height,
    );
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}
```

Usage:

```dart
WiredCanvas(
  painter: WiredRectangleBase(
    fillColor: Colors.white,
    borderColor: Colors.black,
    strokeWidth: 2,
    leftIndent: 10,
    rightIndent: 10,
  ),
  fillerType: RoughFilter.hachureFiller,
)
```

### WiredCircleBase

Draws a circle centered in the available area. The `diameterRatio` controls how much of the available space the circle fills.

```dart
class WiredCircleBase extends WiredPainterBase {
  final double diameterRatio;
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  WiredCircleBase({
    this.diameterRatio = 1,
    this.fillColor = const Color(0xFFFEFEFE),
    this.borderColor = const Color(0xFF1A2B3C),
    this.strokeWidth = 2,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final Drawable figure = generator.circle(
      size.width / 2,
      size.height / 2,
      size.width > size.height
          ? size.width * diameterRatio
          : size.height * diameterRatio,
    );
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}
```

Usage:

```dart
SizedBox(
  width: 80,
  height: 80,
  child: WiredCanvas(
    painter: WiredCircleBase(
      diameterRatio: 0.9,
      fillColor: Colors.amber,
    ),
    fillerType: RoughFilter.solidFiller,
  ),
)
```

### WiredLineBase

Draws a single line between two points, clamped to the available size.

```dart
class WiredLineBase extends WiredPainterBase {
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final Color borderColor;
  final double strokeWidth;

  WiredLineBase({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    this.borderColor = const Color(0xFF1A2B3C),
    this.strokeWidth = 1,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    // Coordinates are clamped to [0, size.width] and [0, size.height]
    var lx1 = x1.clamp(0, size.width);
    var ly1 = y1.clamp(0, size.height);
    var lx2 = x2.clamp(0, size.width);
    var ly2 = y2.clamp(0, size.height);

    final Generator generator = Generator(drawConfig, filler);
    final Drawable figure = generator.line(lx1, ly1, lx2, ly2);
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(borderColor),
    );
  }
}
```

Usage:

```dart
SizedBox(
  width: 200,
  height: 2,
  child: WiredCanvas(
    painter: WiredLineBase(
      x1: 0,
      y1: 1,
      x2: 200,
      y2: 1,
      borderColor: Colors.grey,
    ),
    fillerType: RoughFilter.noFiller,
  ),
)
```

### WiredRoundedRectangleBase

Draws a rectangle with individually configurable corner radii.

```dart
class WiredRoundedRectangleBase extends WiredPainterBase {
  final BorderRadius borderRadius;
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  WiredRoundedRectangleBase({
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.fillColor = const Color(0xFFFEFEFE),
    this.borderColor = const Color(0xFF1A2B3C),
    this.strokeWidth = 2,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final Drawable figure = generator.roundedRectangle(
      0, 0, size.width, size.height,
      borderRadius.topLeft.x,
      borderRadius.topRight.x,
      borderRadius.bottomRight.x,
      borderRadius.bottomLeft.x,
    );
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}
```

Usage:

```dart
WiredCanvas(
  painter: WiredRoundedRectangleBase(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
    fillColor: Color(0xFFF5F0E1),
  ),
  fillerType: RoughFilter.noFiller,
)
```

### WiredInvertedTriangleBase

Draws a downward-pointing triangle (inverted triangle). Used internally for dropdown arrows and similar indicators.

```dart
class WiredInvertedTriangleBase extends WiredPainterBase {
  final Color borderColor;
  final double strokeWidth;

  WiredInvertedTriangleBase({
    this.borderColor = const Color(0xFF1A2B3C),
    this.strokeWidth = 2,
  });

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) {
    final Generator generator = Generator(drawConfig, filler);
    final points = [
      PointD(0, 0),
      PointD(size.width, 0),
      PointD(size.width / 2, size.height),
    ];
    final Drawable figure = generator.polygon(points);
    canvas.drawRough(
      figure,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(borderColor),
    );
  }
}
```

Usage:

```dart
SizedBox(
  width: 16,
  height: 10,
  child: WiredCanvas(
    painter: WiredInvertedTriangleBase(
      borderColor: theme.borderColor,
    ),
    fillerType: RoughFilter.solidFiller,
  ),
)
```

## WiredCanvas

`WiredCanvas` is the `HookWidget` that renders a `WiredPainterBase` via `CustomPaint`. It maps a `RoughFilter` enum value to a `Filler` instance and passes everything to `WiredPainter`.

```dart
class WiredCanvas extends HookWidget {
  final WiredPainterBase painter;
  final DrawConfig? drawConfig;
  final FillerConfig? fillerConfig;
  final RoughFilter fillerType;
  final Size? size;

  const WiredCanvas({
    super.key,
    required this.painter,
    required this.fillerType,
    this.drawConfig,
    this.fillerConfig,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final Filler filler = _filters[fillerType]!.call(
      fillerConfig ?? FillerConfig.defaultConfig,
    );
    return CustomPaint(
      size: size ?? Size.infinite,
      painter: WiredPainter(
        drawConfig ?? DrawConfig.defaultValues,
        filler,
        painter,
      ),
    );
  }
}
```

### Parameters

| Parameter | Required | Default | Description |
|---|---|---|---|
| `painter` | yes | -- | The shape painter to render |
| `fillerType` | yes | -- | Which fill algorithm to use (`RoughFilter` enum) |
| `drawConfig` | no | `DrawConfig.defaultValues` | Drawing configuration override |
| `fillerConfig` | no | `FillerConfig.defaultConfig` | Fill configuration override |
| `size` | no | `Size.infinite` | Custom canvas size |

### Minimal Example

```dart
SizedBox(
  width: 200,
  height: 100,
  child: WiredCanvas(
    painter: WiredRectangleBase(),
    fillerType: RoughFilter.hachureFiller,
  ),
)
```

### With Custom Configuration

```dart
WiredCanvas(
  painter: WiredCircleBase(
    fillColor: Colors.blue,
    borderColor: Colors.indigo,
  ),
  fillerType: RoughFilter.zigZagFiller,
  drawConfig: DrawConfig.build(roughness: 2, seed: 42),
  fillerConfig: FillerConfig.build(
    hachureGap: 8,
    hachureAngle: 60,
  ),
  size: Size(100, 100),
)
```

## WiredPainter (CustomPainter)

`WiredPainter` is the `CustomPainter` that `WiredCanvas` creates internally. It resets the randomizer before each paint call so shapes render deterministically:

```dart
class WiredPainter extends CustomPainter {
  final DrawConfig drawConfig;
  final Filler filler;
  final WiredPainterBase painter;

  WiredPainter(this.drawConfig, this.filler, this.painter);

  @override
  void paint(Canvas canvas, Size size) {
    drawConfig.randomizer!.reset();
    painter.paintRough(canvas, size, drawConfig, filler);
  }

  @override
  bool shouldRepaint(WiredPainter oldDelegate) {
    return oldDelegate.drawConfig != drawConfig ||
        oldDelegate.filler.runtimeType != filler.runtimeType ||
        oldDelegate.painter.runtimeType != painter.runtimeType;
  }
}
```

The `shouldRepaint` check compares `DrawConfig` by value equality and filler/painter by runtime type, so changes to any of these trigger a repaint.

## WiredBase Utility Class

`WiredBase` provides two static methods for creating `Paint` objects used throughout Skribble:

### fillPainter

Creates a stroke-style paint used for fill patterns:

```dart
static Paint fillPainter(Color color) {
  return Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = 2;
}
```

### pathPainter

Creates a stroke-style paint used for shape outlines:

```dart
static Paint pathPainter(
  double strokeWidth, {
  Color color = const Color(0xFF1A2B3C),
}) {
  return Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeWidth = strokeWidth;
}
```

Both paints use `PaintingStyle.stroke` -- even the fill paint. This is because sketchy fill patterns (hachure, dots, zigzag) are drawn as stroked lines, not solid fills. The `SolidFiller` switches the paint style to `PaintingStyle.fill` at render time via the `drawRough` extension.

## WiredBaseWidget and RepaintBoundary Isolation

Every Wired widget wraps its painted content in a `RepaintBoundary`. This prevents expensive rough-drawing repaints from propagating to parent widgets.

### WiredBaseWidget (abstract class)

Extend `WiredBaseWidget` when your widget is purely a painted shape with no external child:

```dart
abstract class WiredBaseWidget extends HookWidget {
  const WiredBaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: buildWiredElement());
  }

  Widget buildWiredElement();
}
```

Example:

```dart
class WiredDivider extends WiredBaseWidget {
  @override
  Widget buildWiredElement() {
    return SizedBox(
      height: 2,
      child: WiredCanvas(
        painter: WiredLineBase(x1: 0, y1: 1, x2: double.maxFinite, y2: 1),
        fillerType: RoughFilter.noFiller,
      ),
    );
  }
}
```

### buildWiredElement() Helper Function

For widgets that compose children with painted shapes, use the standalone helper:

```dart
Widget buildWiredElement({Key? key, required Widget child}) {
  return RepaintBoundary(key: key, child: child);
}
```

This is how most Wired widgets wrap their content:

```dart
class WiredButton extends HookWidget {
  final Widget child;
  final VoidCallback onPressed;

  const WiredButton({required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Container(
        height: kWiredButtonHeight,
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.rectangle,
          borderStyle: RoughDrawingStyle(width: 1, color: theme.borderColor),
        ),
        child: TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.textColor),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
```

### WiredRepaintMixin

An alternative mixin-based approach for classes that cannot extend `WiredBaseWidget`:

```dart
abstract mixin class WiredRepaintMixin {
  Widget buildWiredElement({Key? key, required Widget child}) {
    return RepaintBoundary(key: key, child: child);
  }
}
```

## Creating Custom Painters

To create a new shape painter, extend `WiredPainterBase` and implement `paintRough`.

### Step 1: Define the Painter

```dart
class WiredDiamondBase extends WiredPainterBase {
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  WiredDiamondBase({
    this.fillColor = const Color(0xFFFEFEFE),
    this.borderColor = const Color(0xFF1A2B3C),
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
    final points = [
      PointD(size.width / 2, 0),          // top
      PointD(size.width, size.height / 2), // right
      PointD(size.width / 2, size.height), // bottom
      PointD(0, size.height / 2),          // left
    ];
    final drawable = generator.polygon(points);
    canvas.drawRough(
      drawable,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}
```

### Step 2: Use it in a Widget

```dart
class WiredDiamond extends HookWidget {
  final Widget child;

  const WiredDiamond({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return buildWiredElement(
      child: Stack(
        children: [
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredDiamondBase(
                fillColor: theme.fillColor,
                borderColor: theme.borderColor,
                strokeWidth: theme.strokeWidth,
              ),
              fillerType: RoughFilter.hachureFiller,
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}
```

### Step 3: Use it in Your App

```dart
SizedBox(
  width: 120,
  height: 120,
  child: WiredDiamond(
    child: Icon(Icons.star),
  ),
)
```

### Guidelines for Custom Painters

1. **Always use `Generator`** -- do not call `OpSetBuilder` or `OpsGenerator` directly unless you need low-level control.
2. **Use `WiredBase.pathPainter` and `WiredBase.fillPainter`** -- they set the correct `PaintingStyle.stroke` and anti-aliasing for consistent rendering.
3. **Accept color and strokeWidth parameters** -- this lets the widget layer pass theme values through.
4. **Clamp coordinates** -- if your shape depends on input coordinates (like `WiredLineBase`), clamp them to `[0, size.width]` and `[0, size.height]`.
5. **Wrap with RepaintBoundary** -- use `buildWiredElement()` or `WiredBaseWidget` in the widget that hosts your painter.
