---
skribble_jaspr: patch
---

# Jaspr components keep their attributes, respect reduced motion, and give content room

- **Reduced motion is honoured.** The button's line boil kept running under `prefers-reduced-motion: reduce`, because the reduce rule had lower specificity than the hover rule. All hover and press motion now sits behind `prefers-reduced-motion: no-preference`, and disabled or `aria-disabled="true"` buttons and links stay still.
- **No repeated attributes.** A `class` or `style` entry in `WiredBox`, `WiredCircle`, or `WiredButton` `attributes` rendered a second `class` or `style` attribute, which browsers ignore, so the caller's classes and styles were lost. They are now merged with the component's own.
- **CSS values cannot inject declarations.** `fill` and `color` values containing `;`, `{`, or `}` now fail the build with an `ArgumentError` instead of adding declarations to the inline style.
- **Room for the ink.** `WiredBox` now pads its content `0.75rem 1.25rem` through a zero-specificity `:where(.skribble-box)` rule, and `WiredButton` pads `0.7em 1.3em` (was `0.55em`), so content keeps at least 8px above and below and 12px beside the drawn line.
- **Forced colours.** Under `forced-colors: active` the ink uses system colours and solid fills are dropped, so forced text never lands on the accent fill.
- Adds a runnable `example/main.dart`.
