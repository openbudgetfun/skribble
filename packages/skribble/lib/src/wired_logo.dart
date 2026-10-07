import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'canvas/wired_canvas.dart';
import 'canvas/wired_painter_base.dart';
import 'doodles/doodle_geometry.dart';
import 'doodles/doodle_raster.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_palette.dart';
import 'wired_theme.dart';

/// skribble's logo: a smiling face in square brackets, inked with a
/// fineliner over a marker-filled face with rosy cheeks.
///
/// The outlines are the same paths as the brand SVGs in `assets/brand`, and
/// they ink the same way in every theme so the mark stays recognisable. The
/// colours follow the theme: the ink is its text colour and the face its
/// marker colour, so the logo reads on day and night paper alike.
///
/// Wrap it in a `WiredDrawTransition` to watch the pen draw it.
class WiredLogo extends WiredBaseWidget {
  /// Creates the mark with an optional accessible name.
  const WiredLogo({
    super.key,
    this.size = 48,
    this.color,
    this.faceColor,
    this.cheekColor = WiredPalette.blush,
    this.semanticLabel = 'Skribble',
  }) : assert(size >= 0 && size < double.infinity);

  /// Preferred square size in logical pixels.
  final double size;

  /// Ink colour, defaulting to the surrounding theme's text colour.
  final Color? color;

  /// The marker fill behind the face, defaulting to the theme's marker
  /// colour. A transparent colour leaves the face unfilled.
  final Color? faceColor;

  /// The blush on the cheeks. A transparent colour leaves them out, which
  /// with a transparent [faceColor] gives a single-colour mark.
  final Color cheekColor;

  /// Accessible name, or null when adjacent text already identifies skribble.
  final String? semanticLabel;

  @override
  Widget buildWiredElement() => Builder(
    builder: (context) {
      final theme = WiredTheme.of(context);
      final face = faceColor ?? theme.markerColor;
      Widget layer(_LogoLayer layer, Color color) => WiredCanvas(
        painter: _LogoPainter(layer, color),
        fillerType: RoughFilter.noFiller,
      );
      final picture = SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (face.a > 0) layer(_LogoLayer.face, face),
            if (cheekColor.a > 0) layer(_LogoLayer.cheeks, cheekColor),
            layer(_LogoLayer.ink, color ?? theme.textColor),
          ],
        ),
      );

      return semanticLabel == null
          ? ExcludeSemantics(child: picture)
          : Semantics(image: true, label: semanticLabel, child: picture);
    },
  );
}

/// One colour of the logo.
enum _LogoLayer { face, cheeks, ink }

/// Paints one layer of the logo in its 100-unit design space, centred in
/// the largest square that fits.
class _LogoPainter extends WiredPainterBase {
  _LogoPainter(this.layer, this.color);

  final _LogoLayer layer;
  final Color color;

  /// Ink width in design units: bold enough to read at favicon sizes.
  static const double _inkWidth = 5.2;

  /// How far the marker sits off the line, in design units, the way every
  /// skribble fill misses its outline a little.
  static const Offset _markerShift = Offset(1.4, 1.2);

  /// The logo inks the same in every theme: a fineliner on a fixed seed.
  static final DrawConfig _pen = DrawConfig.build(
    seed: 7,
    pen: RoughPen.fineliner,
  );

  static const Color _none = Color(0x00000000);

  @override
  RoughDrawing prepare(Size size, DrawConfig drawConfig, Filler filler) {
    final side = math.min(size.width, size.height);
    final scale = side / 100;
    final origin = Offset((size.width - side) / 2, (size.height - side) / 2);

    OpSet set(DoodleStroke stroke, OpSetType type, [Offset shift = .zero]) {
      PointD point(DoodlePoint p) => PointD(
        (p.x + shift.dx) * scale + origin.dx,
        (p.y + shift.dy) * scale + origin.dy,
      );
      final ops = <Op>[];
      walkDoodleStroke(
        stroke,
        moveTo: (start) => ops.add(Op.move(point(start))),
        curveTo: (curve) => ops.add(
          Op.curveTo(point(curve.first), point(curve.second), point(curve.end)),
        ),
      );
      return OpSet(type: type, ops: ops);
    }

    final fill = Paint()..color = color;
    return switch (layer) {
      _LogoLayer.face => RoughDrawing(
        Drawable(
          options: _pen,
          sets: [set(logoFaceGeometry(), OpSetType.fillPath, _markerShift)],
        ),
        Paint()..color = _none,
        fill,
      ),
      _LogoLayer.cheeks => RoughDrawing(
        Drawable(
          options: _pen,
          sets: [
            for (final cheek in logoCheekGeometry())
              set(cheek, OpSetType.fillPath),
          ],
        ),
        Paint()..color = _none,
        fill,
      ),
      _LogoLayer.ink => RoughDrawing(
        Drawable(
          options: _pen,
          sets: [
            for (final stroke in logoGeometry()) set(stroke, OpSetType.path),
          ],
        ),
        WiredBase.pathPainter(_inkWidth * scale, color: color),
        Paint()..color = _none,
      ),
    };
  }

  @override
  void paintRough(
    Canvas canvas,
    Size size,
    DrawConfig drawConfig,
    Filler filler,
  ) => prepare(size, drawConfig, filler).paint(canvas);

  @override
  bool operator ==(Object other) =>
      other is _LogoPainter && other.layer == layer && other.color == color;

  @override
  int get hashCode => Object.hash(layer, color);
}
