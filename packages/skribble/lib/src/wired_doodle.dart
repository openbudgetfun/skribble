import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'canvas/wired_canvas.dart';
import 'canvas/wired_painter_base.dart';
import 'doodles/doodle_geometry.dart';
import 'motion/wired_draw.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_doodle_kind.dart';
import 'wired_theme.dart';

/// A seeded, softly drawn flourish that inherits ink from [WiredTheme].
///
/// Decorations ignore pointer events and are silent to assistive technology
/// unless [semanticLabel] is supplied. Put them beside content, leaving text
/// and controls unobstructed. [WiredDrawTransition] can reveal their ink.
class WiredDoodle extends WiredBaseWidget {
  /// Creates a flourish. Reusing [seed] preserves its curves across rebuilds.
  const WiredDoodle({
    required this.kind,
    super.key,
    this.size = 64,
    this.seed = 1,
    this.color,
    this.fillColor,
    this.strokeWidth = 2,
    this.semanticLabel,
  }) : assert(size >= 0 && size < double.infinity),
       assert(strokeWidth > 0 && strokeWidth < double.infinity);

  /// The drawing to generate.
  final WiredDoodleKind kind;

  /// Preferred square size in logical pixels; parent constraints still apply.
  final double size;

  /// Stable shape variation. Changing this deliberately redraws the curves.
  final int seed;

  /// Outline color, defaulting to the theme's text color.
  final Color? color;

  /// Optional solid wash for closed contours; open strokes remain unfilled.
  final Color? fillColor;

  /// Pen width at the requested size. Scales down in smaller parent bounds.
  final double strokeWidth;

  /// A meaningful description, or null for a purely decorative drawing.
  final String? semanticLabel;

  @override
  Widget buildWiredElement() => Builder(
    builder: (context) {
      final theme = WiredTheme.of(context);
      final picture = IgnorePointer(
        child: SizedBox.square(
          dimension: size,
          child: WiredCanvas(
            painter: _DoodlePainter(
              strokes: doodleGeometry(
                kind,
                seed: seed,
                amplitude: theme.roughness.clamp(0, 3).toDouble(),
              ),
              color: color ?? theme.textColor,
              fillColor: fillColor,
              strokeWidth: strokeWidth,
              referenceSize: size,
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
      );

      return semanticLabel == null
          ? ExcludeSemantics(child: picture)
          : Semantics(image: true, label: semanticLabel, child: picture);
    },
  );
}

/// Converts shared cubic geometry to the existing cached ink renderer.
class _DoodlePainter extends WiredPainterBase {
  _DoodlePainter({
    required this.strokes,
    required this.color,
    required this.fillColor,
    required this.strokeWidth,
    required this.referenceSize,
  });

  final List<DoodleStroke> strokes;
  final Color color;
  final Color? fillColor;
  final double strokeWidth;
  final double referenceSize;

  @override
  RoughDrawing prepare(Size size, DrawConfig drawConfig, Filler filler) {
    final side = math.min(size.width, size.height);
    final scale = side / 100;
    final offset = Offset((size.width - side) / 2, (size.height - side) / 2);
    final pen = referenceSize == 0 ? 0.0 : strokeWidth * side / referenceSize;
    PointD point(DoodlePoint p) =>
        PointD(p.x * scale + offset.dx, p.y * scale + offset.dy);
    final outlines = [
      for (final stroke in strokes)
        OpSet(
          type: OpSetType.path,
          ops: [
            Op.move(point(stroke.start)),
            for (final curve in stroke.curves)
              Op.curveTo(
                point(curve.first),
                point(curve.second),
                point(curve.end),
              ),
          ],
        ),
    ];

    return RoughDrawing(
      Drawable(
        sets: [
          if (fillColor != null)
            for (var i = 0; i < strokes.length; i++)
              if (strokes[i].closed)
                OpSet(type: OpSetType.fillPath, ops: outlines[i].ops),
          ...outlines,
        ],
      ),
      WiredBase.pathPainter(pen, color: color),
      Paint()..color = fillColor ?? const Color(0x00000000),
    );
  }

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) => prepare(size, drawConfig, filler).paint(canvas);
}
