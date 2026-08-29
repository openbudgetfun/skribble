---
title: Using Skribble on Jaspr (Web)
description: Hand-drawn aesthetics in Jaspr sites — Skribble webfont, rough SVG borders, and the planned skribble_jaspr package.
---

# Using Skribble on Jaspr (Web)

Skribble's Flutter packages target Flutter apps, but the hand-drawn
aesthetic works on the web today — this very site (and the docs engine) is
a Jaspr app using the Skribble typeface and rough-line motifs.

## 1. The Skribble webfont

The bundled fonts live in
[`packages/skribble/assets/fonts/`](https://github.com/openbudgetfun/skribble/tree/main/packages/skribble/assets/fonts)
(OFL license). Self-host them with `@font-face`:

```css
@font-face {
  font-family: 'Skribble';
  src: url('/fonts/Skribble-Regular.ttf') format('truetype');
  font-weight: 400;
}
@font-face {
  font-family: 'Skribble';
  src: url('/fonts/Skribble-Bold.ttf') format('truetype');
  font-weight: 700;
}
/* + Skribble-Italic.ttf (style: italic), Skribble-BoldItalic.ttf */
body { font-family: 'Skribble', 'Comic Sans MS', cursive; }
```

## 2. Rough borders without Flutter

Two options for the sketchy chrome:

1. **rough.js** (JS, ~10 kB) draws hand-drawn rectangles, ellipses and
   hachure fills on any canvas/SVG:

```js
import rough from 'roughjs';
const rc = rough.svg(document.querySelector('svg'));
const node = rc.rectangle(10, 10, 200, 100, {
  roughness: 1.5, bowing: 1, fill: '#fffbe6', fillStyle: 'hachure',
  strokeWidth: 1.5, seed: 42,   // seed ⇒ deterministic like Skribble
});
```

2. **Pre-generated rough SVG paths** — the Skribble engine produces the
   same primitives deterministically; you can extract path data for a
   fixed geometry once and inline it (zero runtime cost, this
   documentation site's approach).

## 3. Live examples in this ecosystem

- **Storybook on the web** — https://openbudgetfun.github.io/skribble/storybook/
  (the Flutter storybook compiled to web — every widget rendered with the
  rough engine in the browser)
- **This documentation site** — Jaspr + the Skribble webfont

## 4. `skribble_jaspr` (planned)

A Jaspr component package (`ScribbleButton`, `ScribbleCard`,
`ScribbleDivider`, `ScribbleTextField`) with rough SVG chrome and the
Skribble fonts as assets. Scoped in PLANNING.md under "Beyond Flutter" —
design is a direct port of the rough engine's constants (roughness, bowing,
stroke widths, hachure angles) to JS/SVG generators.
