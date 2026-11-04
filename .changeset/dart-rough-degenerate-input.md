---
skribble_rough: patch
---

# The rough engine finishes on tiny arcs, empty dash patterns, and infinite edges

These inputs used to hang the Dart engine or run it out of memory, and now finish the same way the JavaScript and Rust engines do:

- An arc with a sweep a hair above zero, such as a progress ring at 1e-12, or a `curveStepCount` of zero or less. Each arc pass now stops at 4,096 samples.
- A dashed fill whose `dashOffset` plus `dashGap` is under 0.1, or not finite. It now draws plain hachure lines.
- Shapes with an infinite side, lines to infinity, and ellipses of infinite size. A filled shape with an infinite side is drawn unfilled.

Output for ordinary input is unchanged; the cross-engine parity fixtures are byte-identical.
