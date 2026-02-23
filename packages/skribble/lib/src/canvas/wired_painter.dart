import 'package:flutter/material.dart';
import 'package:skribble_rough/skribble_rough.dart';

import 'wired_painter_base.dart';

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
    return oldDelegate.drawConfig != drawConfig;
  }
}
