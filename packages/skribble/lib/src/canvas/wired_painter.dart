import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../rough/skribble_rough.dart';
import 'wired_painter_base.dart';

/// Paints stable rough geometry, listening directly to borrowed animations.
///
/// Prepared shapes are cached until size or the painter delegate changes.
/// Legacy custom painters still use their imperative [WiredPainterBase.paintRough].
class WiredPainter extends CustomPainter {
  /// Creates a painter. Null progress means complete; null pressure means idle.
  WiredPainter(
    this.drawConfig,
    this.filler,
    this.painter, {
    this.progress,
    this.pressure,
  }) : super(repaint: Listenable.merge({?progress, ?pressure}.toList()));

  final DrawConfig drawConfig;
  final Filler filler;
  final WiredPainterBase painter;

  /// Optional pen reveal, borrowed from its owner.
  final Animation<double>? progress;

  /// Optional interaction emphasis, borrowed from its owner.
  final Animation<double>? pressure;
  Size? _size;
  RoughDrawing? _drawing;

  /// Replays every random stream the fill depends on.
  ///
  /// The filler owns a [DrawConfig] separate from this painter's, so resetting
  /// one of them is not enough: fill randomness keeps advancing across paints
  /// and the same shape hatches differently on a rebuild than on first paint.
  void _resetRandomizers() {
    drawConfig.randomizer?.reset();
    filler.config?.drawConfig?.randomizer?.reset();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_size != size) {
      _resetRandomizers();
      _drawing = painter.prepare(size, drawConfig, filler);
      _size = size;
    }
    final drawing = _drawing;
    if (drawing == null) {
      _resetRandomizers();
      painter.paintRough(canvas, size, drawConfig, filler);
    } else {
      drawing.paint(
        canvas,
        progress: progress?.value ?? 1,
        pressure: pressure?.value ?? 0,
      );
    }
  }

  @override
  bool shouldRepaint(WiredPainter oldDelegate) =>
      oldDelegate.drawConfig != drawConfig ||
      oldDelegate.filler != filler ||
      oldDelegate.painter != painter ||
      oldDelegate.progress != progress ||
      oldDelegate.pressure != pressure;
}
