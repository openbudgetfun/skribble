---
skribble: patch
---

# Rough borders reuse their outline through color animations

`RoughOutlinedBorder` and the rough input border cached a prepared outline for every color they were painted in, so Material's focus and hover color fades regenerated the hand-drawn outline on every frame and filled the shared cache. The cache now keys outlines by their geometry only, and the color is applied as the outline is painted: a 20-step fade prepares one outline instead of 21. `RoughDrawing.paint` takes a new optional `outlineColor` for the same purpose.
