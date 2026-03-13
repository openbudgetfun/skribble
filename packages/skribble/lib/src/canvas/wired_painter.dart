import 'package:flutter/material.dart';
import '../rough/skribble_rough.dart';

import 'wired_painter_base.dart';

/// A `CustomPainter` that delegates to a `WiredPainterBase` for
/// sketchy, hand-drawn rendering.
///
/// Resets the randomizer on each paint call so the rough shapes are
/// deterministic for a given configuration.
class WiredPainter extends CustomPainter {
  final DrawConfig drawConfig;
  final Filler filler;
  final WiredPainterBase painter;

  WiredPainter(this.drawConfig, this.filler, this.painter);

  @override
  void paint(Canvas canvas, Size size) {
    drawConfig.randomizer!.reset();
    painter.paintRough(canvas, size, drawConfig, filler);
  }

  @override
  bool shouldRepaint(WiredPainter oldDelegate) {
    return oldDelegate.drawConfig != drawConfig ||
        oldDelegate.filler.runtimeType != filler.runtimeType ||
        oldDelegate.painter.runtimeType != painter.runtimeType;
  }
}
