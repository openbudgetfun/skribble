---
skribble: minor
---

# Remove internal machinery from the public barrel

The `package:skribble/skribble.dart` barrel is now grouped (canvas/motion/rough engine extension points, then widgets & theme) and only exports the surface the documentation promises.

Symbols removed from the public barrel:

- `WiredPainter` (in `src/canvas/wired_painter.dart`) — the internal `CustomPainter` adapter that `WiredCanvas` creates. Custom painters extend `WiredPainterBase`, which remains exported.
- `Line`, `IntersectionInfo`, `FillStyle`, `RoughDecorationPainter`, and the rough engine's free geometry/filler helper functions (`src/rough/core.dart`, `src/rough/filler.dart`, `src/rough/decoration.dart`) — pure engine plumbing that no guide, example, or custom painter needs.

All documented engine symbols stay exported: `DrawConfig`, `Randomizer`, `Generator`, `Drawable`, `PointD`, `Filler`, `FillerConfig`, the seven concrete fillers, `Op`/`OpSet`/`OpType`/`OpSetType`, the `drawRough` extension, `RoughDrawing`, and the rough decoration types. `WiredSvgIconData` and `WiredSvgPrimitive` remain exported and unchanged.

This is breaking only for code that imported the removed internals through the barrel. Tests or tools that genuinely need them should import the defining `package:skribble/src/…` library directly.
