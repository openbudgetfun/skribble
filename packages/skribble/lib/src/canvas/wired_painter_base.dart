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
// The single-member abstract class is intentional: it defines the painter
// protocol shared by every rough painter implementation.
// ignore: one_member_abstracts
abstract class WiredPainterBase {
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  );
}
