import 'dart:ui';

import '../rough/skribble_rough.dart';

/// Abstract base class for all Skribble shape painters.
///
/// Implementations provide [paintRough] to draw a specific shape
/// (rectangle, circle, line, etc.) using the rough drawing engine.
///
/// See also:
///  * `WiredRectangleBase`, `WiredCircleBase`, `WiredLineBase` in
///    `wired_base.dart`.
abstract class WiredPainterBase {
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  );
}
