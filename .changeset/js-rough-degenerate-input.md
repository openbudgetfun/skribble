---
"@skribble.dev/rough": patch
---

# Empty arcs, negative boxes, and zero-length dashes no longer hang

The JavaScript engine takes the Dart engine's arc fix. `Generator.arc`, `OpSetBuilder.arc`, and `OpSetBuilder.arcPolygon` draw nothing for a sweep that is empty (`start === stop`, such as a progress ring at zero), reversed, or not finite. Before, a zero sweep never advanced, and a reversed or infinite one walked away from its stop, so the page froze until it ran out of memory. A start angle far below zero is normalised in one step, and an arc sweep a hair above zero, or a `curveStepCount` of zero or less, finishes instead of sampling forever.

`roundedRectangle` with a negative width or height keeps square corners instead of drawing its corners inside out, as the Dart engine now does.

Other input that used to hang now finishes:

- a `"dashed"` fill whose `dashOffset` and `dashGap` add up to less than 0.1 draws undashed hachure lines;
- an edge with an infinite coordinate draws no ink and no hachure;
- an ellipse with an infinite size or a huge `curveStepCount`.

`Generator.curvePath([])` returns an empty outline instead of throwing a `TypeError`. Ordinary shapes draw exactly as before, and the Dart parity fixtures are unchanged.
