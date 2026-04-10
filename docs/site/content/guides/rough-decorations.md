---
title: Rough Decorations
description: How to use RoughBoxDecoration as a drop-in replacement for BoxDecoration to add sketchy borders and fill patterns to any Flutter container.
---

# Rough Decorations

`RoughBoxDecoration` is a drop-in replacement for Flutter's `BoxDecoration` that renders hand-drawn borders and fill patterns. Use it anywhere you would normally use `BoxDecoration` -- on `Container`, `DecoratedBox`, `AnimatedContainer`, and any other widget that accepts a `Decoration`.

## Replace BoxDecoration with RoughBoxDecoration

Standard Flutter:

```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.black, width: 2),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Standard'),
)
```

Skribble equivalent:

```dart
Container(
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.roundedRectangle,
    borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text('Sketchy'),
)
```

The constructor parameters control different aspects:

| Parameter | Type | Purpose |
|---|---|---|
| `shape` | `RoughBoxShape` | The geometric shape to draw |
| `borderStyle` | `RoughDrawingStyle?` | Stroke color, width, gradient, blendMode for the border |
| `fillStyle` | `RoughDrawingStyle?` | Stroke color, width, gradient, blendMode for the fill |
| `drawConfig` | `DrawConfig?` | Roughness, bowing, seed, and other drawing parameters |
| `filler` | `Filler?` | Fill pattern algorithm instance |
| `borderRadius` | `BorderRadius?` | Corner radii (only used with `roundedRectangle`) |

## RoughBoxShape options

`RoughBoxShape` is an enum with four values:

### rectangle

Draws a rough rectangle with wobbly edges and overshooting corners:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
)
```

### roundedRectangle

Adds rough rounded corners. The `borderRadius` parameter controls corner radii:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.roundedRectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
  borderRadius: BorderRadius.circular(16),
)
```

You can use different radii per corner:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.roundedRectangle,
  borderStyle: RoughDrawingStyle(width: 1.5, color: Colors.indigo),
  borderRadius: const BorderRadius.only(
    topLeft: Radius.circular(20),
    topRight: Radius.circular(4),
    bottomRight: Radius.circular(20),
    bottomLeft: Radius.circular(4),
  ),
)
```

### circle

Draws a rough circle inscribed in the shorter dimension of the container:

```dart
Container(
  width: 100,
  height: 100,
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.circle,
    borderStyle: RoughDrawingStyle(width: 2, color: Colors.teal),
  ),
)
```

### ellipse

Draws a rough ellipse that fills the full width and height:

```dart
Container(
  width: 160,
  height: 80,
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.ellipse,
    borderStyle: RoughDrawingStyle(width: 2, color: Colors.deepOrange),
  ),
)
```

## RoughDrawingStyle for border and fill

`RoughDrawingStyle` configures the paint used to render border strokes or fill strokes:

```dart
RoughDrawingStyle(
  width: 2,                         // stroke width
  color: Colors.black,              // stroke color
  gradient: LinearGradient(...),    // optional gradient (overrides color)
  blendMode: BlendMode.multiply,    // optional blend mode
)
```

Use separate `borderStyle` and `fillStyle` to give the border and fill different appearances:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(
    width: 2,
    color: Colors.black,
  ),
  fillStyle: RoughDrawingStyle(
    width: 1,
    color: Colors.amber.shade100,
  ),
  filler: HachureFiller(FillerConfig.defaultConfig),
)
```

When `fillStyle` is omitted, the border paint is reused for the fill.

## DrawConfig for controlling roughness

`DrawConfig` controls how wobbly and imprecise the drawn lines appear:

```dart
DrawConfig.build(
  maxRandomnessOffset: 2,    // maximum random displacement of points
  roughness: 1,              // overall roughness multiplier
  bowing: 1,                 // midpoint bulge of lines
  curveFitting: 0.95,        // how closely curves follow control points
  curveTightness: 0,         // tension on curve segments
  curveStepCount: 9,         // segments per curve
  seed: 1,                   // RNG seed for deterministic output
)
```

Pass it to the decoration:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
  drawConfig: DrawConfig.build(
    roughness: 2.5,        // extra wobbly
    bowing: 2,             // exaggerated midpoint bulge
    seed: 42,              // fixed seed for reproducible output
  ),
)
```

### Roughness levels

| roughness | Effect |
|---|---|
| `0` | Perfectly straight lines (no hand-drawn effect) |
| `0.5` | Subtle wobble |
| `1` | Default hand-drawn look |
| `2` | Noticeably rough |
| `3+` | Very exaggerated sketchy style |

### Deterministic rendering

The `seed` parameter controls the random number generator. The same seed produces the same wobbly lines every time, so widgets render consistently across rebuilds. Change the seed to get a different "handwriting" for the same shape.

## Filler for fill patterns

The `filler` parameter accepts an instance of a `Filler` subclass. Each filler produces a different visual pattern inside the shape.

### NoFiller (default)

No fill pattern. Only the border is drawn:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
  filler: NoFiller(),
)
```

### HachureFiller

Parallel diagonal strokes:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
  fillStyle: RoughDrawingStyle(width: 1, color: Colors.grey.shade300),
  filler: HachureFiller(FillerConfig.build(
    hachureAngle: 320,
    hachureGap: 15,
  )),
)
```

### ZigZagFiller

Zigzag strokes instead of straight lines:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.circle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.purple),
  fillStyle: RoughDrawingStyle(width: 1, color: Colors.purple.shade100),
  filler: ZigZagFiller(FillerConfig.build(
    hachureGap: 10,
    zigzagOffset: 4,
  )),
)
```

### HatchFiller

Cross-hatched strokes (two overlapping hachure passes at different angles):

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.brown),
  fillStyle: RoughDrawingStyle(width: 0.8, color: Colors.brown.shade200),
  filler: HatchFiller(FillerConfig.build(
    hachureGap: 12,
  )),
)
```

### DotFiller

Dot pattern fill:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.ellipse,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.blue),
  fillStyle: RoughDrawingStyle(width: 1, color: Colors.blue.shade200),
  filler: DotFiller(FillerConfig.build(
    hachureGap: 8,
  )),
)
```

### DashedFiller

Dashed stroke pattern:

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.green),
  fillStyle: RoughDrawingStyle(width: 1, color: Colors.green.shade200),
  filler: DashedFiller(FillerConfig.build(
    dashOffset: 15,
    dashGap: 3,
  )),
)
```

### SolidFiller

Solid fill (no visible stroke pattern):

```dart
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.red),
  fillStyle: RoughDrawingStyle(width: 1, color: Colors.red.shade100),
  filler: SolidFiller(FillerConfig.defaultConfig),
)
```

## FillerConfig reference

`FillerConfig` controls the parameters of the fill algorithm:

```dart
FillerConfig.build(
  fillWeight: 1,         // weight/thickness of fill strokes
  hachureAngle: 320,     // angle of hachure lines in degrees
  hachureGap: 15,        // gap between parallel fill lines
  dashOffset: 15,        // offset of dashes along their line
  dashGap: 2,            // gap between dashes
  zigzagOffset: 5,       // lateral displacement of zigzag peaks
)
```

## Using with Container

The most common use case is a `Container` with rough borders:

```dart
Container(
  width: 200,
  height: 100,
  padding: const EdgeInsets.all(16),
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.rectangle,
    borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
  ),
  child: Text('Hello, Skribble!'),
)
```

## Using with AnimatedContainer

`RoughBoxDecoration` works with `AnimatedContainer`, but the decoration itself does not interpolate (it swaps instantly). The container size and padding still animate:

```dart
class ExpandingBox extends HookWidget {
  const ExpandingBox({super.key});

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

    return GestureDetector(
      onTap: () => expanded.value = !expanded.value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: expanded.value ? 300 : 150,
        height: expanded.value ? 200 : 100,
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.roundedRectangle,
          borderStyle: RoughDrawingStyle(
            width: 2,
            color: expanded.value ? Colors.green : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text('Tap me')),
      ),
    );
  }
}
```

## Gallery: Common decoration patterns

### Card-like container

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.roundedRectangle,
    borderStyle: RoughDrawingStyle(width: 1.5, color: Colors.grey.shade700),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Card Title', style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      Text('Card body text goes here.'),
    ],
  ),
)
```

### Highlighted callout

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.rectangle,
    borderStyle: RoughDrawingStyle(width: 2, color: Colors.orange),
    fillStyle: RoughDrawingStyle(width: 1, color: Colors.orange.shade50),
    filler: HachureFiller(FillerConfig.build(hachureGap: 20)),
    drawConfig: DrawConfig.build(roughness: 1.5, seed: 7),
  ),
  child: Row(
    children: [
      Icon(Icons.info_outline, color: Colors.orange),
      SizedBox(width: 12),
      Expanded(child: Text('This is an important note.')),
    ],
  ),
)
```

### Circular avatar frame

```dart
Container(
  width: 80,
  height: 80,
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.circle,
    borderStyle: RoughDrawingStyle(width: 2.5, color: Colors.indigo),
  ),
  child: ClipOval(
    child: Image.network('https://example.com/avatar.jpg', fit: BoxFit.cover),
  ),
)
```

### Tag / pill shape

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
  decoration: RoughBoxDecoration(
    shape: RoughBoxShape.roundedRectangle,
    borderStyle: RoughDrawingStyle(width: 1, color: Colors.teal),
    fillStyle: RoughDrawingStyle(width: 0.5, color: Colors.teal.shade50),
    filler: SolidFiller(FillerConfig.defaultConfig),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text('flutter', style: TextStyle(color: Colors.teal, fontSize: 12)),
)
```

## Integration with WiredTheme

When building widgets that need to respect the Skribble theme, read colors from `WiredTheme.of(context)`:

```dart
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  return Container(
    decoration: RoughBoxDecoration(
      shape: RoughBoxShape.rectangle,
      borderStyle: RoughDrawingStyle(
        width: theme.strokeWidth,
        color: theme.borderColor,
      ),
      fillStyle: RoughDrawingStyle(
        width: 1,
        color: theme.fillColor,
      ),
      drawConfig: theme.drawConfig,
    ),
    child: child,
  );
}
```

This is the pattern used by `WiredButton`, `WiredCard`, and all other built-in widgets.
