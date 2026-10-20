---
skribble: patch
---

# `crampedText` measures a label against the border painted over it

When two hand-drawn borders of the same size surround a label, `crampedText` now measures against the later one, which paints over the first. An elevated button's label is measured from its paper face instead of the offset shadow underneath, so it no longer reports a 2-pixel shortfall that nobody can see.
