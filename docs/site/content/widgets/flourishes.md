---
title: Flourishes and logo
description: Generate little hand-drawn butterflies, hearts, smiles, and other uplifting drawings.
---

# Little drawings, made by you

`WiredDoodle` generates smooth, slightly uneven curves for the corners of a page, an empty state, or a small thank-you. Choose a drawing and an integer seed. The same seed keeps the same shape across rebuilds.

## Choose a flourish

```dart
// Static example: api
WiredDoodle(
  kind: WiredDoodleKind.butterfly,
  seed: 8,
  size: 96,
  color: WiredPalette.ink,
  fillColor: WiredPalette.peach,
)
```

Available kinds are `butterfly`, `heart`, `smile`, `flower`, `sparkle`, `scribble`, `leaf`, `cloud`, `sun`, `moon`, `rainbow`, `comet`, `balloon`, `mushroom`, `cupcake`, `bird`, `sprout`, `wave`, and `confetti`. `fillColor` adds a solid wash only inside closed contours. The pen defaults to two logical pixels at the requested size. A smaller parent scales the whole drawing down without stretching it.

The surrounding `WiredThemeData.roughnessLevel` controls the amount of curve variation. Gentle, playful, and expressive remain smooth; these drawings vary long curves instead of introducing short, jagged segments. Scribbles use the seed to choose a different angle and two to four loops, so they are useful as a small background accent without looking stamped out.

## Place drawings around content

Keep flourishes out of text and touch areas. All drawings ignore pointer events. They are excluded from semantics unless you supply a meaningful `semanticLabel`.

```dart
// Static example: api
Stack(
  children: [
    content,
    const Positioned(
      right: 16,
      top: 16,
      child: WiredDoodle(kind: WiredDoodleKind.heart, seed: 21),
    ),
  ],
)
```

## Reveal the ink

Wrap a drawing in `WiredDraw` for a one-time entrance, or use `WiredDrawTransition` with an animation you own. Reduced-motion preferences take precedence. Ordinary drawings have no ticker and never move by themselves.

## The logo: inked brackets

`WiredLogo(size: 48)` renders the skribble logo: a smiling face in square brackets, inked with a fineliner over a marker-filled face with rosy cheeks. The ink is the theme's text colour and the face its marker colour, so the logo reads on day and night paper. The outlines have fixed geometry and ink the same way at every roughness, so the mark stays recognisable everywhere.

```dart
// Static example: api

// The full-colour mark.
const WiredLogo(size: 96)

// A single-colour mark, such as for a stamp or a watermark.
const WiredLogo(
  size: 96,
  color: WiredPalette.coral,
  faceColor: Color(0x00000000),
  cheekColor: Color(0x00000000),
)

// Watch the pen draw it.
WiredDrawTransition(progress: animation, child: const WiredLogo(size: 96))
```

Set `semanticLabel: null` when nearby text already identifies the brand. `cheekColor` defaults to `WiredPalette.blush`. The `mark` loader style sketches the same outlines with the same pen weight, so a splash hands over to `WiredLogo` without the mark jumping.

## Figma and downloads

The [Figma design system](https://www.figma.com/design/pjRi0rh4NWkGRROPlWLLBo/Skribble-Design-System) includes editable versions of these same curves. Download the [logo SVGs](https://github.com/openbudgetfun/skribble/tree/main/assets/brand) and [flourish SVGs](https://github.com/openbudgetfun/skribble/tree/main/assets/flourishes) from GitHub.

Regenerate assets from the repository root with `devenv shell dart run packages/skribble/tool/export_design_assets.dart`.
