---
dart:skribble_rough: minor
skribble_jaspr: patch
---

# Smaller SVG path data for server-rendered sketches

`compactSvgPath` rewrites SVG path data in its smallest equivalent form: relative commands, implicit command repeats, no leading zeros, and no separator where a minus sign or second decimal point already starts the next number. It rounds absolute coordinates to the precision you ask for (one decimal by default) and writes the deltas in whole units of that precision, so a long path never drifts. Every path command is understood, including arcs with packed flags; data it cannot parse comes back unchanged.

`RoughSvg.compact()` applies it to all three groups. At its default of two decimals it draws exactly the shape `RoughSvg.fromDrawable` writes, in about a fifth fewer bytes.

`skribble_jaspr` components now write compact path data in every ink overlay, with no change to what they draw.
