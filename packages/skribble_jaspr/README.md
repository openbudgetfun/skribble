# skribble_jaspr

Hand-drawn [Jaspr](https://jaspr.site) components from the [skribble](https://openbudgetfun.github.io/skribble/) design system. Rough borders, sketched fills, scribbled highlights, and doodles render on the server into inline SVG, so a static site gets the hand-drawn look with **zero client JavaScript**.

## Why it exists

skribble's Flutter widgets draw every line with a seeded rough engine. This package runs the same engine ([`skribble_rough`](../skribble_rough)) while Jaspr renders HTML, then lets CSS do the rest:

- **Static and server-rendered sites.** Ink is generated at build time. Nothing measures the DOM or redraws in the browser.
- **Stable builds.** The same `seed` always produces the same markup, so static output does not churn between deploys.
- **Pure CSS theming.** Colours, stroke width, and font come from CSS custom properties, including dark mode.

Use it for landing pages, documentation sites, and marketing pages that should feel sketched rather than templated.

## Install

Until the package is published to pub.dev, depend on it from Git. `skribble_jaspr` depends on `skribble_rough` from the same repository, so point both at the same ref:

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

Pin `ref` to a commit SHA for reproducible builds.

## Add the stylesheet

`skribbleCss` positions the ink and maps it to the theme. Include it once per page:

```dart
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

Add `class="skribble-page"` to `<body>` for the paper background and casual font.

## Components

```dart
WiredCard(
  seed: 3,
  child: Component.fragment([
    Component.element(tag: 'h2', children: [
      Component.text('Draw it '),
      WiredHighlight(
        kind: WiredHighlightKind.circle,
        child: Component.text('differently'),
      ),
    ]),
    WiredButton(href: '/start', child: Component.text('Start sketching')),
  ]),
)
```

| Component        | Renders                                                                                                   |
| ---------------- | --------------------------------------------------------------------------------------------------------- |
| `WiredBox`       | Any element (`tag`) with a rough rectangle behind it, optionally filled with a `RoughFillStyle`           |
| `WiredCard`      | A padded `WiredBox` for grouped content                                                                   |
| `WiredCircle`    | A rough ellipse around content, for badges and step numbers                                               |
| `WiredButton`    | `<a>` with `href`, otherwise `<button type="button">`; `primary` (accent fill) or `secondary` (outline)   |
| `WiredHighlight` | An inline `underline`, `circle`, `marker`, `strikethrough`, or `box` around text                          |
| `WiredDivider`   | A rough horizontal rule (`role="separator"`)                                                              |
| `WiredSketch`    | A standalone doodle: `.rectangle`, `.ellipse`, `.line`, `.polygon`, or `.curve`, with optional arrowheads |

Give neighbouring components different seeds so their wobbles differ.

## Theming

| Property                  | Default (light / dark)                 | Used for                                |
| ------------------------- | -------------------------------------- | --------------------------------------- |
| `--skribble-ink`          | `#1f1d1a` / `#f2efe6`                  | Outlines, pen highlights, button labels |
| `--skribble-paper`        | `#fffdf6` / `#1b1a17`                  | The `.skribble-page` background         |
| `--skribble-accent`       | `#ffd43b` / `#e3b62f`                  | Default fills, primary buttons, markers |
| `--skribble-on-accent`    | `#1f1d1a` / `#1b1a17`                  | Text on accent fills                    |
| `--skribble-stroke-width` | `2px`                                  | Outline width at every size             |
| `--skribble-font`         | `"Skribble"`, then casual system faces | Button labels and `.skribble-page`      |

Defaults use `:where(:root)`, so any rule of yours wins. The `fill` and `color` arguments set `--skribble-fill` and `--skribble-highlight` on the element.

## How it works

The server cannot know an element's size, so each component draws into a nominal `viewBox` and an absolutely positioned `<svg>` stretches to fit with `preserveAspectRatio="none"`. `vector-effect="non-scaling-stroke"` keeps strokes at their CSS width at any size. Very wide or very tall elements stretch the wobble with them.

The ink is decorative (`aria-hidden="true"`): accessible names come from the content. Buttons and links keep native semantics and show a dashed focus ring. Hover tilts the ink, and buttons flip between two drawings (the "line boil" of hand-drawn animation); both stop under `prefers-reduced-motion`.

## Documentation

See [Using skribble on Jaspr](https://openbudgetfun.github.io/skribble/guides/jaspr) for the full guide, including fonts and drawing with `skribble_rough` directly.
