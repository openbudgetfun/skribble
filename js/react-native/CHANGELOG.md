# Changelog

All notable changes to this project will be documented in this file.

This changelog is managed by [monochange](https://github.com/monochange/monochange).

## js [0.1.0](https://github.com/openbudgetfun/skribble/releases/tag/js/v0.1.0) (2026-10-23)

### Changed

#### Draw skribble's hand-drawn shapes from JavaScript

_Owner:_ [@ifiokjr](https://github.com/ifiokjr) · _Review:_ [PR #254](https://github.com/openbudgetfun/skribble/pull/254)

`@skribble.dev/rough` is a dependency-free TypeScript port of `skribble_rough` that draws the same SVG as the Dart engine for the same seed, with a rough.js-style `rough.canvas()`, `rough.svg()`, and `rough.generator()` API and a framework-neutral `sketch()` that returns path data.

`@skribble.dev/react`, `@skribble.dev/react-native`, `@skribble.dev/vue`, and `@skribble.dev/svelte` add a `<Sketch>` component to each framework:

```tsx
import { Sketch } from "@skribble.dev/react";

<Sketch width={160} height={80} shape={{ type: "rectangle", x: 4, y: 4, width: 152, height: 72 }} fill="#ffd54f" seed={7} />;
```
