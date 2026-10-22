---
title: Using skribble on Jaspr (Web)
description: Server-rendered hand-drawn components for Jaspr sites with skribble_jaspr — zero client JavaScript, seeded ink, and CSS theming.
---

# Using skribble on Jaspr (Web)

[`skribble_jaspr`](https://github.com/openbudgetfun/skribble/tree/main/packages/skribble_jaspr) brings skribble's hand-drawn look to [Jaspr](https://jaspr.site) sites. Its components draw rough borders, sketched fills, highlights, and doodles while Jaspr renders HTML, so static and server-rendered pages ship plain SVG and **no client JavaScript**.

The ink comes from [`skribble_rough`](https://github.com/openbudgetfun/skribble/tree/main/packages/skribble_rough), the same pure-Dart [rough engine](../core/rough-engine) the Flutter widgets paint with. The same seed always draws the same shape, so a static build produces identical markup every time.

## 1. Install

Until the packages are published to pub.dev, depend on them from Git. `skribble_jaspr` depends on `skribble_rough` from the same repository, so override it to the same ref:

```yaml
dependencies:
  jaspr: ^0.23.4
  skribble_jaspr:
    git:
      url: https://github.com/openbudgetfun/skribble.git
      path: packages/skribble_jaspr
      ref: main

dependency_overrides:
  skribble_rough:
    git:
      url: https://github.com/openbudgetfun/skribble.git
      path: packages/skribble_rough
      ref: main
```

Pin both `ref` values to one commit SHA for reproducible builds.

## 2. Add the stylesheet

`skribbleCss` is a `String` constant. It positions every ink overlay, maps the ink to theme custom properties, and adds hover, focus, and reduced-motion behaviour. Inline it in the document head, or write it to a file in `web/` during your build:

```dart
// Static example: setup
import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';

Document(
  title: 'Sketchbook',
  head: [
    Component.element(tag: 'style', children: [RawText(skribbleCss)]),
  ],
  body: App(),
)
```

Add `class="skribble-page"` to `<body>` for the paper background, ink colour, and hand-drawn font.

## 3. Use the components

```dart
// Static example: api
Component.fragment([
  Component.element(tag: 'h1', children: [
    Component.text('Draw it '),
    WiredHighlight(
      kind: WiredHighlightKind.circle,
      seed: 3,
      child: Component.text('differently'),
    ),
  ]),
  WiredButton(href: '/start', child: Component.text('Start sketching')),
  WiredButton(
    variant: WiredButtonVariant.secondary,
    seed: 4,
    child: Component.text('Read the docs'),
  ),
  const WiredDivider(seed: 2),
  WiredCard(
    seed: 5,
    fillStyle: RoughFillStyle.hachure,
    fill: '#ffe08a',
    child: Component.text('A hatched card'),
  ),
])
```

| Component        | Renders                                                                                                  |
| ---------------- | -------------------------------------------------------------------------------------------------------- |
| `WiredBox`       | Any element (`tag`, `classes`, `attributes`) with a rough rectangle behind its child                     |
| `WiredCard`      | A padded `WiredBox` for grouped content                                                                  |
| `WiredCircle`    | A rough ellipse around its child, for badges and step numbers                                            |
| `WiredButton`    | `<a>` when `href` is set, otherwise `<button type="button">`; `primary` (accent fill) or `secondary`     |
| `WiredHighlight` | An inline `underline`, `circle`, `marker`, `strikethrough`, or `box` around text, coloured by `color`    |
| `WiredDivider`   | A rough horizontal rule with `role="separator"`                                                          |
| `WiredSketch`    | A doodle at an explicit size: `.rectangle`, `.ellipse`, `.line`, `.polygon`, `.curve` (with `arrowhead`) |

Closed shapes accept a `RoughFillStyle`: `none`, `hachure`, `crossHatch`, `zigzag`, `dashed`, `dots`, or `solid`. Give neighbouring components different seeds so their wobbles differ. `WiredButton.attributes` passes through extras such as `type="submit"` or `target`.

### Doodles

`WiredSketch` draws standalone annotations. Points are `(x, y)` records in the sketch's own coordinates:

```dart
// Static example: api
WiredSketch.curve(
  width: 160,
  height: 80,
  points: [(6, 70), (50, 20), (110, 60), (154, 14)],
  arrowhead: true,
  label: 'Points to the sign-up form',
)
```

A sketch without a `label` is decorative and hidden from assistive technology; with one it becomes `role="img"`.

## 4. Theme with CSS

Every colour and width is a custom property, so theming needs no Dart:

```css
:root {
  --skribble-ink: #2b2a33;
  --skribble-accent: #9ad1d4;
  --skribble-stroke-width: 2.5px;
}

.pricing .skribble-card {
  --skribble-ink: #c92a2a;
}
```

| Property                  | Used for                                |
| ------------------------- | --------------------------------------- |
| `--skribble-ink`          | Outlines, pen highlights, button labels |
| `--skribble-paper`        | The `.skribble-page` background         |
| `--skribble-accent`       | Default fills, primary buttons, markers |
| `--skribble-on-accent`    | Text on accent fills                    |
| `--skribble-stroke-width` | Outline width at every size             |
| `--skribble-font`         | Button labels and `.skribble-page`      |
| `--skribble-fill`         | Set by a component's `fill` argument    |
| `--skribble-highlight`    | Set by `WiredHighlight.color`           |

Defaults are declared with `:where(:root)`, so any rule of yours overrides them. A dark palette applies under `prefers-color-scheme: dark`; override the properties inside your own dark-mode selector to change it. Add the `skribble-wobble` class to a `WiredBox` or `WiredCard` to give it the button's hover tilt.

## 5. The skribble webfont

The stylesheet loads no fonts. The default lettering, Skribble Noto Sketch, is [`packages/skribble_font_noto_sketch/assets/fonts/SkribbleNotoSketch-Regular.ttf`](https://github.com/openbudgetfun/skribble/tree/main/packages/skribble_font_noto_sketch/assets/fonts) (OFL license). Self-host it and declare the `SkribbleNotoSketch` family, which `--skribble-font` lists first. It has one Regular face; browsers synthesise bold and italic.

```css
@font-face {
  font-family: 'SkribbleNotoSketch';
  src: url('/fonts/SkribbleNotoSketch-Regular.ttf') format('truetype');
  font-weight: 400;
}
```

For other scripts, add files from the Skribble Noto Sketch font kit on the [GitHub release](https://github.com/openbudgetfun/skribble/releases/latest) and list them after it, for example `--skribble-font: "SkribbleNotoSketch", "SkribbleNotoSketchJP", cursive;`. A self-hosted Recursive `Skribble` family from `skribble_font_recursive` is still picked up next in the default stack.

## A complete example

The skribble.dev landing page is built this way. Its source in [`apps/skribble_site`](https://github.com/openbudgetfun/skribble/tree/main/apps/skribble_site) renders pages with Jaspr's `renderComponent` from a plain Dart build script, mixes `skribble_jaspr` components with doodles drawn straight from `skribble_rough`, and turns native checkboxes, radios, and range inputs into hand-drawn controls with CSS alone.

## How it works

A server cannot measure an element before the browser lays it out. Each component therefore draws into a nominal `viewBox` sized near its usual proportions, and an absolutely positioned `<svg>` stretches to the element with `preserveAspectRatio="none"`. `vector-effect="non-scaling-stroke"` keeps every stroke at its CSS width at any size. The SVG sits behind the content (`z-index: -1` inside an isolated stacking context), so it never intercepts clicks or covers text.

Paths carry `currentColor` presentation attributes, so the shapes still draw without the stylesheet. The stylesheet then maps them to the custom properties.

Accessibility comes from the HTML, not the ink:

- Ink overlays are `aria-hidden="true"` and `focusable="false"`.
- `WiredButton` renders a native `<a>` or `<button>`, labelled by its child, with a dashed `:focus-visible` ring outside the ink.
- `WiredDivider` is `role="separator"`. `WiredHighlight` is visual only: wrap its child in `<em>`, `<strong>`, `<mark>`, or `<del>` when the emphasis carries meaning.
- Hover tilts the ink, and buttons flip between two drawings from neighbouring seeds, the "line boil" of hand-drawn animation. Both effects are pure CSS, only apply to hover-capable pointers, and stop under `prefers-reduced-motion: reduce`.

### Limits

- The ink is generated once on the server. Components register no event handlers; add your own behaviour around them if you hydrate on the client.
- Elements much wider or taller than a component's nominal canvas stretch the wobble with them. Prefer `WiredSketch` at an explicit size when the proportions matter.
- Output is byte-stable for a given seed on the same Dart SDK. The engine's random stream comes from `dart:math`, which the SDK does not promise to keep identical across releases.

## Drawing with the engine directly

For shapes the components do not cover, use `skribble_rough` and write the SVG yourself:

```dart
// Static example: api
import 'package:skribble_rough/skribble_rough.dart';

final drawable = Generator(
  DrawConfig.build(seed: 7),
  RoughFillStyle.dots.filler(
    FillerConfig.build(drawConfig: DrawConfig.build(seed: 7)),
  ),
).circle(50, 50, 80);
final paths = RoughSvg.fromDrawable(drawable).toPathElements(
  stroke: 'currentColor',
  fill: 'var(--skribble-accent)',
);
```

See [Rough engine](../core/rough-engine#scalable-svg-centrelines) for the serializer and [Beyond Flutter](../reference/beyond-flutter) for the design kit and icon exports.
