---
title: Architecture
description: skribble's architectural direction, dependency rule, layers, transitional Material debt, and settled decisions.
---

# Architecture

skribble is a **standalone hand-drawn design system for Flutter** — a peer of `package:material_ui` and `package:cupertino_ui`. It is not a theme, not a wrapper, and not a skin over Material widgets. This page is the source of truth for the library's architecture and direction. The repository-root `PLANNING.md` is a historical, rolling progress tracker: useful for understanding how the library got here, but not authoritative for current status. When the two disagree, this page wins.

## What skribble is

- A design system library. `packages/skribble` owns its widgets, its tokens, its painting stack, and its hand-drawn engine. Flutter's framework is its platform, not its visual identity.
- A peer of `material_ui` and `cupertino_ui`. The three can live in one app, but skribble does not need either of the others to render, theme, or lay out. `WiredScaffold`, `WiredAppBar`, and the rest are real implementations, not re-skinned Material classes.
- A package with a hard dependency rule: `packages/skribble/lib` imports `flutter/widgets.dart` and below, never Material or Cupertino. Its public API is exposed through `lib/skribble.dart`; the main library's runtime dependencies are `flutter_hooks` and `path_parsing`. The rule is the target; the current violations are tracked below.

It is not:

- **A theme for Material.** `WiredThemeData.toThemeData()` exists only so standard Material widgets inside a migrating app do not clash with skribble during the transition. It is bridge surface, not the product.
- **A wrapper.** Some Wired widgets still wrap Material widgets today; that is tracked debt (see [Where the transitional debt is](#where-the-transitional-debt-is)), not the design.
- **A skin.** A skin inherits another system's visuals and release schedule. A peer does not.

## The dependency rule

> `packages/skribble/lib` may import `package:flutter/widgets.dart` and the libraries below it. It must never import `package:flutter/material.dart` or `package:flutter/cupertino.dart` in new code.

Allowed:

```dart
// Static example: setup
import 'package:flutter/widgets.dart';
```

Not allowed in new code:

```dart
// Static example: pseudocode
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
```

### Why the rule exists

A library that builds on `flutter/material.dart` is a skin, and a skin inherits:

- **Material's visuals.** Material 3 default elevation, surface tints, ripples, and typography leak into widgets even when they are meant to look hand-drawn. Fighting defaults is a tax on every widget.
- **Material's versioning.** A Material deprecation or redesign becomes skribble's problem, forcing coordinated releases and migrations the library does not control.
- **Material's breaking changes.** Every Flutter release can change a Material widget's internals underneath a wrapper. Wrapping `Scaffold` means inheriting `Scaffold`'s lifecycle, not just its constructor.
- **Material's bundle.** `flutter/material.dart` is a large library, and its fonts and icons are heavy. An app that wants a hand-drawn button should not pay for Material's theming stack to get one.
- **Material's API constraints.** A public constructor that accepts `ThemeMode` or `ColorScheme` cannot be used by an app that does not depend on Material. Material types must not be part of skribble's public surface where a widgets-level type will do.

The destination is zero: when the audit reaches `0 of 137`, a CI gate will fail any pull request that reintroduces a Material or Cupertino import into `packages/skribble/lib`.

## The layering

The library is organized in layers. Dependencies point downward only: a layer may import the layers below it, never the layers above.

```
App shell          WiredMaterialApp (transitional)  ->  a WidgetsApp-based shell
      |
Theme / tokens     WiredThemeData, WiredTheme, WiredRoughness, WiredPalette, WiredFont
      |
Widgets            Wired* (HookWidget, one file per widget)
      |
Painting           WiredCanvas, WiredPainter, WiredPainterBase
and composition    wired_base.dart (WiredBase, WiredBaseWidget, WiredRepaintMixin,
                   buildWiredElement, concrete shape painters)
      |
Rough engine       lib/src/rough (Generator, Filler, Drawable, DrawConfig,
                   RoughBoxDecoration, renderer, geometry)
```

Motion (`lib/src/motion`) is cross-cutting: it sits beside painting rather than above it, owns animation lifecycle, and is consumed by widgets through `WiredDraw`, `WiredInkResponse`, and `WiredMotion`.

### 1. Rough engine (`lib/src/rough`)

The foundation is a Dart port of [rough.js](https://roughjs.com/). It imports only `dart:ui`, `package:flutter/animation.dart`, and `package:flutter/painting.dart` — no widgets, no Material. It provides:

- `DrawConfig` for roughness, bowing, and seeded randomness
- `Generator` for producing `Drawable` shapes (rectangle, circle, polygon, arc, and more)
- `Filler` subclasses for fill patterns (hachure, zigzag, dots, dashed, solid)
- `RoughBoxDecoration`, a drop-in `BoxDecoration` replacement built on the engine

Every hand-drawn line in skribble ultimately passes through this layer.

### 2. Painting and composition (`lib/src/canvas`, `wired_base.dart`)

`WiredPainterBase` is the abstract class every shape painter implements. Concrete painters (`WiredRectangleBase`, `WiredCircleBase`, `WiredLineBase`, `WiredRoundedRectangleBase`, `WiredInvertedTriangleBase`) override `paintRough(Canvas, Size, DrawConfig, Filler)` to generate a `Drawable` and render it through the engine. This layer may import the rough engine and theme tokens; it must not import widgets.

`WiredCanvas` is a `HookWidget` that composes a painter with a `RoughFilter` (filler type) and optional configuration. It delegates to `WiredPainter`, a `CustomPainter` that resets the randomizer seed before each paint so the sketchy output is deterministic.

`wired_base.dart` wraps the painting layer with composition and repaint isolation: `WiredBase` paint helpers, `WiredBaseWidget`, `WiredRepaintMixin`, and the `buildWiredElement()` helper.

### 3. Widgets (`lib/src/wired_*.dart`)

The public widget layer: 80+ components named with the `Wired` prefix. Widgets import the painting layer, the rough engine, and the theme; they never import `material.dart` or `cupertino.dart` in the target architecture. Today many of them still do — that is the transitional debt described below.

### 4. Theme and tokens (`wired_theme.dart` and friends)

`WiredThemeData` centralizes border color, fill color, text color, stroke width, roughness, font choice, motion policy, and an optional `DrawConfig`. The `WiredTheme` scope (an `InheritedTheme`) makes the data available through `WiredTheme.of(context)`. `WiredRoughness`, `WiredPalette`, and `WiredFont` provide the coordinated token sets. A widget never hardcodes a color; it reads the theme.

### 5. App shell

`WiredMaterialApp` (and its `.router()` variant) is the **transitional shell**: it wraps `MaterialApp`, converts `WiredThemeData` into a Material `ThemeData` via `toThemeData()`, and injects a `WiredTheme` ancestor so a migrating app gets Wired theming without rewriting its shell.

The destination is a `WidgetsApp`-based skribble shell that provides navigation, overlays, and localization without Material. Until that shell ships, `WiredMaterialApp` is the supported entry point, and it remains as a compatibility wrapper afterwards. See [Material bridge](/core/material-bridge) for the interoperability details and the migration path.

## Where the transitional debt is

The Material decoupling is tracked, not vibes-based.

- **Report:** `docs/material-dependency-audit.txt` — the current snapshot.
- **Tool:** `tool/audit_material_dependencies.dart` regenerates it. Run `dart run tool/audit_material_dependencies.dart` from the repository root, or pass `--json` for machine-readable output.

The tool classifies every file that imports Material or Cupertino:

| Class       | Meaning                                                                                 | Work required                         |
| ----------- | --------------------------------------------------------------------------------------- | ------------------------------------- |
| **skin**    | The file constructs or wraps a Material/Cupertino widget (e.g. `Scaffold`, `TextField`) | A real rewrite onto `flutter/widgets` |
| **helpers** | The file only uses constants, geometry, or theme values from Material                   | Mechanical import swaps               |

Snapshot from 2026-09-13: **94 of 137 files import Material or Cupertino — 70 skin, 24 helpers.** The skin count grew from 57 to 70 (against 94 of 109 files) as parity widgets landed: seven new widgets were added, seven helper files were reclassified as skins, and one skin (`wired_loading_indicator.dart`) was rewritten off Material. The hard debt grew while the mechanical debt shrank; the trend is expected to reverse as the leaf-input rewrites begin.

### Rewrite order

1. **Leaf inputs** — the button family, `WiredCheckbox`, `WiredSwitch`, `WiredSlider`, and the text fields. Small public surfaces, well-tested, and they carry most of the semantics.
2. **Containers and navigation** — `WiredScaffold`, `WiredAppBar`, tabs, bottom navigation, dialogs, overlays.
3. **App shell** — a `WidgetsApp`-based shell, with `WiredMaterialApp` retained as a thin compatibility bridge for consumers.
4. **Localization** — replace the Material localizations dependency with `flutter_localizations` direct use or a skribble-owned delegate.

Each skin rewrite must preserve the widget's accessibility semantics, which today often come from the Material widget being removed. See [Accessibility testing](/reference/accessibility-testing).

## The compatibility promise

The bridge is a product surface, not an embarrassment. While the rewrite is in progress:

- `WiredMaterialApp`, `WiredTheme`, and `WiredThemeData.toThemeData()` keep working and keep their documented behavior. They are not deprecated today.
- They remain supported until the standalone shell ships and consumers have a migration path. Removal is a breaking change that follows the normal release process (changeset, changelog, migration guide) — never a silent side effect of a rewrite PR.
- New widgets are built on `flutter/widgets` primitives even while the bridge exists. Compatibility with the bridge is a consequence of the widgets-level stack, not a reason to add Material dependencies.
- Public API parity with Material and Cupertino constructor signatures is intentional where it eases migration, but parity never justifies a new Material import.

## Decision records

These decisions are settled. Do not relitigate them in pull requests; propose a superseding decision here instead.

### D1 — Material is a bus stop, not the destination

Interoperating with Material during migration is fine and temporary. Every Material import in `packages/skribble/lib` is debt with an owner and a rewrite order. "It works with Material" is not a feature; "it works without Material" is the goal.

### D2 — `WiredMaterialApp` is a transitional bridge, not the app-level abstraction

The app-level abstraction is a skribble-owned shell built on `WidgetsApp`. `WiredMaterialApp` is how existing apps adopt skribble before that shell exists. Documentation must frame it as a compatibility layer, not as skribble's answer to `MaterialApp`. See [Material bridge](/core/material-bridge).

### D3 — No new Material or Cupertino imports

New code in `packages/skribble/lib` must import `flutter/widgets.dart` (or a lower-level Flutter library) only. This applies to widget code, tools, and generated helpers. Existing violations are grandfathered by the audit snapshot; new ones are rejected in review. When the audit reaches 0, CI enforces the rule automatically.

### D4 — Motion lifecycle lives in `lib/src/motion`

Motion code uses standard Flutter `State`, ticker providers, and `InheritedWidget` scopes. It does not use `flutter_hooks`, and it does not wrap widgets into hooks. Its public API accepts `Animation<double>` values owned by the caller. Widgets opt into motion; motion never reaches up into the widget layer. See [Ink motion](/core/motion).

### D5 — The barrel export is the public contract

A class in `lib/src` is internal until it appears in `packages/skribble/lib/skribble.dart`. Do not document, test, or rely on unexported classes as public API. If a file is not exported and not referenced, it is dead code and must be removed or finished — exporting it is a deliberate API decision, not a cleanup step.

### D6 — API familiarity is a migration aid, not an implementation strategy

`WiredButton` accepting `child` and `onPressed`, and `WiredMaterialApp` accepting `MaterialApp`-shaped parameters, lower the cost of trying skribble. That familiarity does not extend to implementation: Wired widgets must be built from `flutter/widgets` primitives, and widget-specific helper types must not be Material types where a widgets-level equivalent exists.

## Package structure

```
skribble/
  packages/
    skribble/                 # Main UI component library
      lib/
        skribble.dart         # Public barrel export
        src/
          rough/              # Rough drawing engine
          canvas/             # WiredPainterBase, WiredCanvas, WiredPainter
          motion/             # Ink motion lifecycle (hooks-independent)
          wired_*.dart        # Individual widget files
      test/                   # Widget and unit tests
      tool/                   # Icon generation, design kit, audits
    skribble_lints/           # Shared lint rules (analysis_options.yaml)
    skribble_icons/           # Curated hand-drawn icon set
    skribble_icons_custom/    # Custom hand-drawn icon font generation
    skribble_emoji/           # Hand-drawn emoji from OpenMoji
  apps/
    skribble_storybook/       # Showcase / demo app with every widget
      integration_test/       # Integration tests
  docs/
    site/                     # Documentation site (Flutter)
    design/                   # Figma handover notes
  tool/
    audit_material_dependencies.dart  # Material decoupling tracker
```

The workspace uses [Melos](https://melos.invertase.dev/) for multi-package management. Common commands:

```bash
melos run analyze       # Run dart analyze on all packages
melos run flutter-test  # Run widget tests
melos run format        # Format all Dart files
melos run screenshot    # Capture widget screenshots
```

## Rendering pipeline

When a Wired widget paints, data flows through these steps:

1. **Theme resolution** — the widget calls `WiredTheme.of(context)` to obtain `WiredThemeData`, which supplies colors, stroke width, and roughness values.
2. **Painter construction** — the widget creates a concrete `WiredPainterBase` subclass (for example, `WiredRectangleBase`) with the resolved theme values.
3. **Generator creation** — inside `paintRough`, the painter instantiates a `Generator` with the active `DrawConfig` and `Filler`.
4. **Drawable generation** — `Generator` calls the appropriate shape method (`rectangle`, `circle`, `polygon`, and so on), which returns a `Drawable` containing one or more `OpSet` lists of drawing operations.
5. **Canvas rendering** — the `drawRough` extension on `Canvas` iterates over each `OpSet`. Path operations draw the outline; fill operations draw the hachure, dot, or zigzag pattern or a solid fill.

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

### Widget layer stack

Every Wired widget follows the same structural pattern. Here is the full stack from bottom to top:

```dart
// Static example: pseudocode
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

## Design principles

### Hooks for widgets

Every widget uses `HookWidget` from the `flutter_hooks` package, giving composable state management (`useState`, `useMemoized`, `useEffect`) without lifecycle boilerplate.

The motion layer is the deliberate exception: `lib/src/motion` uses standard `State`, ticker providers, and `InheritedWidget` scopes so its public API stays usable from any Flutter widget, hooks or not.

```dart
// Static example: pseudocode
// Correct
class WiredSlider extends HookWidget { ... }

// Never do this for a widget
class WiredSlider extends StatefulWidget { ... }
```

### RepaintBoundary isolation

Every Wired widget wraps its painted content with `RepaintBoundary` to prevent expensive rough-drawing repaints from propagating up the tree. The `WiredBaseWidget` abstract class and the standalone `buildWiredElement()` function both handle this automatically.

```dart
// Static example: pseudocode
// WiredBaseWidget handles it:
class MyWidget extends WiredBaseWidget {
  @override
  Widget buildWiredElement() => /* painted content */;
}

// Or use the helper directly:
return buildWiredElement(child: paintedContent);
```

### Theme-driven colors

Widgets never hardcode colors. They read from `WiredTheme.of(context)` at build time. This makes global rebranding a single `WiredThemeData` change.

<!-- {=docsThemeReadPattern} -->

```dart
// Static example: custom-class
@override
Widget build(BuildContext context) {
  final theme = WiredTheme.of(context);

  // Use theme values for all visual properties
  final borderColor = theme.borderColor;
  final fillColor = theme.fillColor;
  final textColor = theme.textColor;
  final strokeWidth = theme.strokeWidth;
  final roughness = theme.roughness;
  final drawConfig = theme.drawConfig;
  final inkExtent = theme.inkExtent;
  // ...
}
```

<!-- {/docsThemeReadPattern} -->

### Deterministic randomness

The rough engine uses a seeded `Randomizer` that is reset on every paint call. Given the same `DrawConfig.seed`, the same sketchy output is produced. This avoids visual jitter during hot reload and animation frames while keeping the hand-drawn appearance.

```dart
// Static example: pseudocode
// The randomizer resets before each paint:
drawConfig.randomizer!.reset();
painter.paintRough(canvas, size, drawConfig, filler);
```

## Maps and charts

The optional `skribble_maps` and `skribble_charts` packages depend on skribble, with independent public barrels and release versions. Apps can use the core widgets without either dependency.

Maps delegates geographic projection and the basemap to MapLibre. Flutter paints and hit-tests the app-owned pins, routes, and areas. Online basemaps need a network connection; the docs also provide an offline pin demonstration.

Charts keeps exact decimal market data separate from screen coordinates. Its controller merges timestamped revisions and owns the viewport. A separate annotation controller owns drawing history, so live ticks never enter undo/redo. The widget borrows these controllers; the host disposes them. `WiredChartFeed` coordinates a host-supplied snapshot and update stream without selecting an exchange or transport.

Chart painters use visible data, cached indicator results, and separate repaint boundaries for the crosshair. Candle bodies and wicks preserve their price coordinates. Seeded hatching and bounded sideways pen variation add texture. Chart rendering uses Flutter canvas directly because general rough outlines would move exact price endpoints.

See [Charts](/widgets/charts) and [Maps](/widgets/maps) for public examples.
