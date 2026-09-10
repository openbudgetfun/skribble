---
title: Rough Decorations
description: How to use RoughBoxDecoration as a drop-in replacement for BoxDecoration to add sketchy borders and fill patterns to any Flutter container.
---

# Rough Decorations

`RoughBoxDecoration` is a drop-in replacement for Flutter's `BoxDecoration` that renders hand-drawn borders and fill patterns. Use it anywhere you would normally use `BoxDecoration` -- on `Container`, `DecoratedBox`, `AnimatedContainer`, and any other widget that accepts a `Decoration`.

## Replace BoxDecoration with RoughBoxDecoration

Standard Flutter:

```dart
// Live example: decoration-usage-1
Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Standard'),
    );
  },
)
```

Skribble equivalent:

```dart
// Live example: decoration-usage-2
Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.roundedRectangle,
        borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Sketchy'),
    );
  },
)
```

The constructor parameters control different aspects:

| Parameter      | Type                 | Purpose                                                 |
| -------------- | -------------------- | ------------------------------------------------------- |
| `shape`        | `RoughBoxShape`      | The geometric shape to draw                             |
| `borderStyle`  | `RoughDrawingStyle?` | Stroke color, width, gradient, blendMode for the border |
| `fillStyle`    | `RoughDrawingStyle?` | Stroke color, width, gradient, blendMode for the fill   |
| `drawConfig`   | `DrawConfig?`        | Roughness, bowing, seed, and other drawing parameters   |
| `filler`       | `Filler?`            | Fill pattern algorithm instance                         |
| `borderRadius` | `BorderRadius?`      | Corner radii (only used with `roundedRectangle`)        |

## RoughBoxShape options

`RoughBoxShape` is an enum with four values:

### rectangle

Draws a rough rectangle with wobbly edges and overshooting corners:

```dart
// Static example: configuration
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
)
```

### roundedRectangle

Adds rough rounded corners. The `borderRadius` parameter controls corner radii:

```dart
// Static example: configuration
RoughBoxDecoration(
  shape: RoughBoxShape.roundedRectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
  borderRadius: BorderRadius.circular(16),
)
```

You can use different radii per corner:

```dart
// Static example: configuration
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
// Live example: decoration-usage-3
Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      width: 100,
      height: 100,
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.circle,
        borderStyle: const RoughDrawingStyle(
          width: 2,
          color: Color(0xff456c5c),
        ),
      ),
    );
  },
)
```

### ellipse

Draws a rough ellipse that fills the full width and height:

```dart
// Live example: decoration-usage-4
Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      width: 160,
      height: 80,
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.ellipse,
        borderStyle: const RoughDrawingStyle(
          width: 2,
          color: Color(0xffb2533d),
        ),
      ),
    );
  },
)
```

## RoughDrawingStyle for border and fill

`RoughDrawingStyle` configures the paint used to render border strokes or fill strokes:

```dart
// Static example: configuration
RoughDrawingStyle(
  width: 2,                         // stroke width
  color: Colors.black,              // stroke color
  gradient: LinearGradient(...),    // optional gradient (overrides color)
  blendMode: BlendMode.multiply,    // optional blend mode
)
```

Use separate `borderStyle` and `fillStyle` to give the border and fill different appearances:

```dart
// Static example: configuration
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
// Static example: configuration
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
// Static example: configuration
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

| roughness | Effect                                          |
| --------- | ----------------------------------------------- |
| `0`       | Perfectly straight lines (no hand-drawn effect) |
| `0.5`     | Subtle wobble                                   |
| `1`       | Default hand-drawn look                         |
| `2`       | Noticeably rough                                |
| `3+`      | Very exaggerated sketchy style                  |

### Deterministic rendering

The `seed` parameter controls the random number generator. The same seed produces the same wobbly lines every time, so widgets render consistently across rebuilds. Change the seed to get a different "handwriting" for the same shape.

## Filler for fill patterns

The `filler` parameter accepts an instance of a `Filler` subclass. Each filler produces a different visual pattern inside the shape.

### NoFiller (default)

No fill pattern. Only the border is drawn:

```dart
// Static example: configuration
RoughBoxDecoration(
  shape: RoughBoxShape.rectangle,
  borderStyle: RoughDrawingStyle(width: 2, color: Colors.black),
  filler: NoFiller(),
)
```

### HachureFiller

Parallel diagonal strokes:

```dart
// Static example: configuration
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
// Static example: configuration
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
// Static example: configuration
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
// Static example: configuration
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
// Static example: configuration
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
// Static example: configuration
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
// Static example: configuration
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
// Live example: decoration-usage-5
Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      width: 200,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),
      ),
      child: const Text('Hello, Skribble!'),
    );
  },
)
```

## Using with AnimatedContainer

`RoughBoxDecoration` works with `AnimatedContainer`, but the decoration itself does not interpolate (it swaps instantly). The container size and padding still animate:

```dart
// Live example: expanding-decoration
HookBuilder(
  builder: (context) {
    final expanded = useState(false);
    return Column(
      children: [
        WiredButton(
          onPressed: () => expanded.value = !expanded.value,
          child: Text(expanded.value ? 'Make it smaller' : 'Make room'),
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration:
              MediaQuery.disableAnimationsOf(context) ||
                  !WiredTheme.of(context).motionEnabled
              ? Duration.zero
              : const Duration(milliseconds: 300),
          width: expanded.value ? 260 : 150,
          height: expanded.value ? 180 : 100,
          alignment: Alignment.center,
          decoration: RoughBoxDecoration(
            shape: RoughBoxShape.roundedRectangle,
            drawConfig: WiredTheme.of(context).drawConfig,
            borderStyle: RoughDrawingStyle(
              width: 2.4,
              color: WiredTheme.of(context).borderColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Room for ideas'),
        ),
      ],
    );
  },
)
```

## Gallery: Common decoration patterns

### Card-like container

```dart
// Live example: decoration-usage-6
Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.roundedRectangle,
        borderStyle: const RoughDrawingStyle(
          width: 1.5,
          color: Color(0xff716275),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card Title', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Card body text goes here.'),
        ],
      ),
    );
  },
)
```

### Highlighted callout

```dart
// Live example: decoration-usage-7
Builder(
  builder: (context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RoughBoxDecoration(
        borderStyle: const RoughDrawingStyle(
          width: 2,
          color: Color(0xff9b542d),
        ),
        fillStyle: const RoughDrawingStyle(width: 1, color: Color(0xfff6dfd5)),
        filler: HachureFiller(FillerConfig.build(hachureGap: 20)),
        drawConfig: DrawConfig.build(roughness: 1.5, seed: 7),
      ),
      child: const Row(
        children: [
          WiredIcon(
            icon: IconData(0xe33d, fontFamily: 'MaterialIcons'),
            color: Color(0xff9b542d),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('This is an important note.')),
        ],
      ),
    );
  },
)
```

### Circular avatar frame

```dart
// Static example: external-asset
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
// Live example: decoration-usage-8
Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.roundedRectangle,
        borderStyle: const RoughDrawingStyle(
          width: 1,
          color: Color(0xff456c5c),
        ),
        fillStyle: const RoughDrawingStyle(
          width: 0.5,
          color: Color(0xffeef1df),
        ),
        filler: SolidFiller(FillerConfig.defaultConfig),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'flutter',
        style: TextStyle(color: Color(0xff456c5c), fontSize: 12),
      ),
    );
  },
)
```

## Integration with WiredTheme

When building widgets that need to respect the Skribble theme, read colors from `WiredTheme.of(context)`:

```dart
// Static example: configuration
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
