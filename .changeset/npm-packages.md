---
"@skribble.dev/rough":
  bump: major
  version: "0.1.0"
"@skribble.dev/react":
  bump: major
  version: "0.1.0"
"@skribble.dev/react-native":
  bump: major
  version: "0.1.0"
"@skribble.dev/vue":
  bump: major
  version: "0.1.0"
"@skribble.dev/svelte":
  bump: major
  version: "0.1.0"
---

# Draw skribble's hand-drawn shapes from JavaScript

`@skribble.dev/rough` is a dependency-free TypeScript port of `skribble_rough` that draws the same SVG as the Dart engine for the same seed, with a rough.js-style `rough.canvas()`, `rough.svg()`, and `rough.generator()` API and a framework-neutral `sketch()` that returns path data.

`@skribble.dev/react`, `@skribble.dev/react-native`, `@skribble.dev/vue`, and `@skribble.dev/svelte` add a `<Sketch>` component to each framework:

```tsx
import { Sketch } from "@skribble.dev/react";

<Sketch width={160} height={80} shape={{ type: "rectangle", x: 4, y: 4, width: 152, height: 72 }} fill="#ffd54f" seed={7} />;
```
