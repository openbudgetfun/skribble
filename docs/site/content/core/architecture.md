---
title: Architecture
description: High-level overview of Skribble's layered architecture, package structure, rendering pipeline, and design principles.
---

# Architecture

Skribble is organized as a layered system where each layer builds on the one below it. Understanding this stack helps you decide where to make changes, whether you are customizing a single widget or creating an entirely new one.

## Library Layers

The rendering pipeline flows bottom-up through six layers:

```
WiredMaterialApp / WiredCupertinoScaffold   (app shell)
                  |
             WiredTheme                      (theme)
                  |
        Wired* widgets                       (widgets)
                  |
       WiredCanvas / WiredBaseWidget         (canvas)
                  |
      WiredPainterBase subclasses            (painters)
                  |
  Rough Engine (Generator, Filler, Drawable) (engine)
```

### 1. Rough Engine

The foundation is a Dart port of [rough.js](https://roughjs.com/). It provides `DrawConfig` for controlling randomness, `Generator` for producing `Drawable` shapes, and `Filler` subclasses for fill patterns (hachure, zigzag, dots, and more). Every hand-drawn line in Skribble ultimately passes through this engine.

### 2. Painters

`WiredPainterBase` is the abstract class that all shape painters implement. Each concrete painter -- `WiredRectangleBase`, `WiredCircleBase`, `WiredLineBase`, `WiredRoundedRectangleBase`, `WiredInvertedTriangleBase` -- overrides `paintRough(Canvas, Size, DrawConfig, Filler)` to generate a `Drawable` via `Generator` and render it to the canvas.

### 3. Canvas

`WiredCanvas` is a `HookWidget` that combines a `WiredPainterBase` with a `RoughFilter` (filler type) and optional configuration. It delegates to `WiredPainter`, a `CustomPainter` that resets the randomizer seed before each paint call so the sketchy output is deterministic.

### 4. Widgets

All 80+ Skribble widgets extend `HookWidget` (or `HookConsumerWidget` when Riverpod is needed). They read colors and stroke settings from `WiredTheme.of(context)`, compose painters and canvases, and wrap content with `RepaintBoundary` via `WiredBaseWidget` or the `buildWiredElement()` helper.

### 5. Theme

`WiredThemeData` centralizes border color, fill color, text color, stroke width, roughness, and an optional `DrawConfig`. The `WiredTheme` `InheritedWidget` makes this data available to every descendant widget through `WiredTheme.of(context)`.

### 6. App Shell

`WiredMaterialApp` (and its `.router()` variant) wraps `MaterialApp`, converts `WiredThemeData` into a Material `ThemeData` via `toThemeData()`, and injects a `WiredTheme` ancestor. This keeps Material theming and Wired theming synchronized with zero manual wiring.

## Package Structure

```
skribble/
  packages/
    skribble/                 # Main UI component library
      lib/src/
        rough/                # Rough drawing engine
        canvas/               # WiredPainterBase, WiredCanvas, WiredPainter
        wired_*.dart          # Individual widget files
      test/                   # Widget and unit tests
    skribble_lints/           # Shared lint rules (analysis_options.yaml)
    skribble_icons_custom/    # Custom hand-drawn icon font generation
  apps/
    skribble_storybook/       # Showcase / demo app with every widget
      integration_test/       # Integration tests
```

The workspace uses [Melos](https://melos.invertase.dev/) for multi-package management. Common commands:

```bash
melos run analyze       # Run dart analyze on all packages
melos run flutter-test  # Run widget tests
melos run format        # Format all Dart files
melos run screenshot    # Capture widget screenshots
```

## Widget Layer Stack

Every Wired widget follows the same structural pattern. Here is the full stack from bottom to top:

```dart
// 1. Painter -- generates the rough shape
class WiredRectangleBase extends WiredPainterBase {
  @override
  void paintRough(Canvas canvas, Size size, DrawConfig drawConfig, Filler filler) {
    final generator = Generator(drawConfig, filler);
    final drawable = generator.rectangle(0, 0, size.width, size.height);
    canvas.drawRough(
      drawable,
      WiredBase.pathPainter(strokeWidth, color: borderColor),
      WiredBase.fillPainter(fillColor),
    );
  }
}

// 2. Canvas -- renders the painter via CustomPaint
WiredCanvas(
  painter: WiredRectangleBase(
    fillColor: theme.fillColor,
    borderColor: theme.borderColor,
  ),
  fillerType: RoughFilter.hachureFiller,
)

// 3. Widget -- composes canvas with child content
class WiredCard extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Stack(children: [
        WiredCanvas(painter: WiredRectangleBase(...), fillerType: ...),
        child,
      ]),
    );
  }
}
```

## Rendering Pipeline

When a Wired widget paints, data flows through these steps:

1. **Theme resolution** -- the widget calls `WiredTheme.of(context)` to obtain `WiredThemeData`, which supplies colors, stroke width, and roughness values.

2. **Painter construction** -- the widget creates a concrete `WiredPainterBase` subclass (e.g., `WiredRectangleBase`) with the resolved theme values.

3. **Generator creation** -- inside `paintRough`, the painter instantiates a `Generator` with the active `DrawConfig` and `Filler`.

4. **Drawable generation** -- `Generator` calls the appropriate shape method (`rectangle`, `circle`, `polygon`, etc.) which returns a `Drawable` containing one or more `OpSet` lists of drawing operations.

5. **Canvas rendering** -- the `drawRough` extension on `Canvas` iterates over each `OpSet`. Path operations draw the outline; fill operations draw the hachure/dot/zigzag pattern or solid fill.

```
WiredTheme.of(context)
    |
    v
WiredThemeData { borderColor, fillColor, strokeWidth, roughness, drawConfig }
    |
    v
WiredPainterBase.paintRough(canvas, size, drawConfig, filler)
    |
    v
Generator(drawConfig, filler).rectangle(x, y, w, h)
    |
    v
Drawable { sets: [OpSet(path), OpSet(fillSketch)] }
    |
    v
canvas.drawRough(drawable, pathPaint, fillPaint)
```

## Design Principles

### Hooks Only

Every widget uses `HookWidget` from the `flutter_hooks` package. No `StatefulWidget` or `StatelessWidget` exists in the codebase. This gives composable state management (via `useState`, `useMemoized`, `useEffect`, etc.) without lifecycle boilerplate.

```dart
// Correct
class WiredSlider extends HookWidget { ... }

// Never do this
class WiredSlider extends StatefulWidget { ... }
```

### RepaintBoundary Isolation

Every Wired widget wraps its painted content with `RepaintBoundary` to prevent expensive rough-drawing repaints from propagating up the tree. The `WiredBaseWidget` abstract class and the standalone `buildWiredElement()` function both handle this automatically.

```dart
// WiredBaseWidget handles it:
class MyWidget extends WiredBaseWidget {
  @override
  Widget buildWiredElement() => /* painted content */;
}

// Or use the helper directly:
return buildWiredElement(child: paintedContent);
```

### Theme-Driven Colors

Widgets never hardcode colors. They read from `WiredTheme.of(context)` at build time. This makes global rebranding a single `WiredThemeData` change.

<!-- {=docsThemeReadPattern} -->

```dart
final theme = WiredTheme.of(context);
// Use theme.borderColor, theme.fillColor, theme.textColor, etc.
```

<!-- {/docsThemeReadPattern} -->

### Familiar APIs

Wired widgets mirror Material and Cupertino constructor signatures wherever possible. `WiredButton` takes `child` and `onPressed` just like `TextButton`. `WiredMaterialApp` accepts the same parameters as `MaterialApp`. This minimizes the learning curve for Flutter developers.

### Deterministic Randomness

The rough engine uses a seeded `Randomizer` that is reset on every paint call. Given the same `DrawConfig.seed`, the same sketchy output is produced. This avoids visual jitter during hot reload and animation frames while keeping the hand-drawn appearance.

```dart
// The randomizer resets before each paint:
drawConfig.randomizer!.reset();
painter.paintRough(canvas, size, drawConfig, filler);
```
