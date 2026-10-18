---
skribble: minor
---

# `RoughBoxDecoration` fills, clips, animates, and keeps its drawing across rebuilds

`RoughBoxDecoration` can now replace a `BoxDecoration` that has a colour, a rounded corner, and a border, without app-side wrappers:

- **`color`** paints a level fill under the hand-drawn outline. It stops at the centre of the pen line, so it never pokes out past the wobble. `fillStyle` and `filler` still draw sketched fills.
- **`inkInset`** reports how far inside the box the outline's centre lands. The outline, the level fill, and the clip all use it.
- **`getClipPath`** returns the shape at that inset, so `Container(clipBehavior: Clip.antiAlias)` clips a child to the outline instead of throwing.
- **Value equality.** Equal decorations compare equal, so a parent that rebuilds with an equal decoration keeps the prepared drawing instead of generating the outline again. `drawConfig`, `filler`, `progress`, and `pressure` compare by identity.
- **Interpolation.** `RoughBoxDecoration.lerp` and `RoughDrawingStyle.lerp` interpolate colours, pen widths, and corner radii between decorations of the same shape, so `AnimatedContainer` can move between hand-drawn states. The seed switches at the midpoint.

Nothing changes for existing decorations: without `color`, the outline, padding, and hit testing draw and behave as before.
