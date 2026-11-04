---
skribble_rough: patch
skribble: patch
---

# Empty arcs and negative boxes no longer hang or throw

`Generator.arc`, `OpSetBuilder.arc`, and `OpSetBuilder.arcPolygon` return empty ink for a sweep that is empty (`start == stop`), reversed, or not finite. Before, the arc samplers stepped by half the sweep, so a zero sweep never advanced and a reversed one walked away from its stop, hanging the isolate while it ran out of memory. A start angle far below zero is also normalised in one step instead of a turn at a time. Ordinary arcs draw exactly as before; the JavaScript parity fixtures are unchanged.

`Generator.roundedRectangle` no longer throws `ArgumentError` for a negative width or height.
