---
skribble: patch
---

# Keep the hand-drawn fill pattern stable across repaints

The filler carried its own random stream, separate from the painter's, and nothing replayed it. A card, switch, or slider could hatch differently after a rebuild than it did on first paint, and its pattern depended on which other filled widgets had painted before it. Both streams now reset before each shape is prepared, so a shape reproduces its ink exactly.
