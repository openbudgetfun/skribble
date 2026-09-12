import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'doodles/doodle_geometry.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// Skribble's bracketed smile, drawn from the same paths as the brand SVGs.
class WiredLogo extends HookWidget {
  /// Creates the mark with an optional accessible name.
  const WiredLogo({
    super.key,
    this.size = 48,
    this.color,
    this.semanticLabel = 'Skribble',
  }) : assert(size >= 0 && size < double.infinity);

  /// Preferred square size in logical pixels.
  final double size;

  /// Ink color, defaulting to the surrounding theme's text color.
  final Color? color;

  /// Accessible name, or null when adjacent text already identifies Skribble.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final paths = useMemoized(
      () => logoGeometry().map((stroke) {
        final path = Path()..moveTo(stroke.start.x, stroke.start.y);
        for (final curve in stroke.curves) {
          path.cubicTo(
            curve.first.x,
            curve.first.y,
            curve.second.x,
            curve.second.y,
            curve.end.x,
            curve.end.y,
          );
        }
        if (stroke.closed) path.close();
        return path;
      }).toList(),
    );
    final picture = RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoPainter(paths, color ?? WiredTheme.of(context).textColor),
      ),
    );

    return semanticLabel == null
        ? ExcludeSemantics(child: picture)
        : Semantics(image: true, label: semanticLabel, child: picture);
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter(this.paths, this.color);
  final List<Path> paths;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 100);
    final paint = WiredBase.pathPainter(3.6, color: color);

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.paths != paths;
}
