import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

/// Every coordinate pair in SVG path data.
List<Offset> _points(String data) {
  final numbers = RegExp(r'-?\d+(?:\.\d+)?')
      .allMatches(data)
      .map((match) => double.parse(match.group(0)!))
      .toList();
  return [
    for (var i = 0; i + 1 < numbers.length; i += 2)
      Offset(numbers[i], numbers[i + 1]),
  ];
}

List<Op> _line(double length, {double y = 50}) => [
  Op.move(PointD(0, y)),
  Op.lineTo(PointD(length, y)),
];

List<Op> _square(double side) => [
  Op.move(PointD(0, 0)),
  Op.lineTo(PointD(side, 0)),
  Op.lineTo(PointD(side, side)),
  Op.lineTo(PointD(0, side)),
  Op.lineTo(PointD(0, 0)),
];

/// The widest the outline gets across the line `y = 50` near [x].
double _thicknessNear(List<Offset> points, double x) {
  final near = points.where((point) => (point.dx - x).abs() < 1.5);
  if (near.isEmpty) return 0;
  return near.map((point) => (point.dy - 50).abs()).reduce(math.max) * 2;
}

Future<int> _inkPixels(void Function(Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(240, 120);
  final bytes = (await image.toByteData())!.buffer.asUint8List();
  image.dispose();
  var count = 0;
  for (var i = 3; i < bytes.length; i += 4) {
    if (bytes[i] > 128) count++;
  }
  return count;
}

void main() {
  group('RoughPen', () {
    test('uniform is the only constant-width preset', () {
      expect(RoughPen.uniform.isUniform, isTrue);
      for (final pen in [RoughPen.fineliner, RoughPen.ink, RoughPen.brush]) {
        expect(pen.isUniform, isFalse, reason: '$pen');
      }
    });

    test('reach covers half the widest swell', () {
      expect(RoughPen.uniform.reach, 0.5);
      expect(
        RoughPen.ink.reach,
        closeTo((1 + RoughPen.ink.pressure) / 2, 1e-9),
      );
      expect(RoughPen.brush.reach, greaterThan(RoughPen.ink.reach));
    });

    test('copyWith replaces only the given values', () {
      final pen = RoughPen.ink.copyWith(pressure: 0.5);
      expect(pen.pressure, 0.5);
      expect(pen.taperIn, RoughPen.ink.taperIn);
      expect(pen, isNot(RoughPen.ink));
      expect(pen.copyWith(pressure: RoughPen.ink.pressure), RoughPen.ink);
      expect(
        pen.copyWith(pressure: RoughPen.ink.pressure).hashCode,
        RoughPen.ink.hashCode,
      );
    });

    test('roughness levels ink with progressively looser pens', () {
      expect(WiredRoughness.gentle.pen, RoughPen.fineliner);
      expect(WiredRoughness.playful.pen, RoughPen.ink);
      expect(WiredRoughness.expressive.pen, RoughPen.brush);
    });
  });

  group('InkStroke', () {
    test('is deterministic for a seed and varies between seeds', () {
      String outline(int seed) => InkStroke(
        _square(80),
        width: 3,
        pen: RoughPen.ink,
        seed: seed,
      ).svgPathData;

      expect(outline(4), outline(4));
      expect(outline(4), isNot(outline(5)));
    });

    test('a uniform pen keeps a constant width with round caps', () {
      final points = _points(
        InkStroke(_line(200), width: 4, pen: RoughPen.uniform).svgPathData,
      );
      for (final x in [20.0, 100.0, 180.0]) {
        expect(_thicknessNear(points, x), closeTo(4, 0.05), reason: 'x=$x');
      }
      final xs = points.map((point) => point.dx);
      expect(xs.reduce(math.min), closeTo(-2, 0.05));
      expect(xs.reduce(math.max), closeTo(202, 0.05));
    });

    test('an ink pen touches down lightly and lifts thinner', () {
      const pen = RoughPen(pressure: 0);
      final points = _points(
        InkStroke(_line(200), width: 4, pen: pen).svgPathData,
      );
      final middle = _thicknessNear(points, 100);
      expect(middle, closeTo(4, 0.05));
      expect(_thicknessNear(points, 0.5), lessThan(middle * 0.6));
      expect(_thicknessNear(points, 199.5), lessThan(middle * 0.5));
    });

    test('pressure swells stay within the pen reach', () {
      const pen = RoughPen(pressure: 0.3, startWidth: 1, endWidth: 1);
      final points = _points(
        InkStroke(_line(400), width: 4, pen: pen, seed: 9).svgPathData,
      );
      final widths = [
        for (var x = 10.0; x < 390; x += 7) _thicknessNear(points, x),
      ];
      expect(widths.reduce(math.max), lessThanOrEqualTo(4 * pen.peakWidth));
      expect(
        widths.reduce(math.max) - widths.reduce(math.min),
        greaterThan(0.8),
        reason: 'pressure visibly changes the width',
      );
    });

    test('a prefix draws only as far as the pen has travelled', () {
      final stroke = InkStroke(_line(200), width: 4, pen: RoughPen.ink);
      final sink = SvgInkOutline();
      stroke.writeOutline(sink, distance: 80);
      final xs = _points(sink.toString()).map((point) => point.dx);
      expect(xs.reduce(math.max), closeTo(82, 1));
      expect(stroke.length, closeTo(200, 1e-6));
    });

    test('partial coverage inks only part of a repeat pass', () {
      final full = InkStroke(_line(300), width: 3, pen: RoughPen.ink);
      final partial = InkStroke(
        _line(300),
        width: 3,
        pen: RoughPen.ink,
        coverage: 0.5,
        seed: 3,
      );
      expect(partial.length, inInclusiveRange(300 * 0.5 * 0.75, 300 * 0.5));
      expect(full.length, closeTo(300, 1e-6));
    });

    test('closed loops run past their start and curl inward', () {
      const side = 120.0;
      const width = 3.0;
      final stroke = InkStroke(
        _square(side),
        width: width,
        pen: RoughPen.brush,
        seed: 11,
      );
      expect(
        stroke.length,
        closeTo(side * 4 + RoughPen.brush.closure * width, 1e-6),
      );
      final reach = width * RoughPen.brush.reach;
      for (final point in _points(stroke.svgPathData)) {
        expect(point.dx, inInclusiveRange(-reach - 0.01, side + reach + 0.01));
        expect(point.dy, inInclusiveRange(-reach - 0.01, side + reach + 0.01));
      }
    });

    test('empty and zero-length input produces no ink', () {
      expect(
        InkStroke(const [], width: 2, pen: RoughPen.ink).svgPathData,
        isEmpty,
      );
      expect(
        InkStroke(
          [Op.move(PointD(4, 4)), Op.lineTo(PointD(4, 4))],
          width: 2,
          pen: RoughPen.ink,
        ).length,
        0,
      );
    });
  });

  group('DrawableInk', () {
    Drawable square(RoughPen pen) => Generator(
      DrawConfig.build(seed: 2, pen: pen),
      SolidFiller(),
    ).rectangle(10, 10, 200, 80);

    test('uniform pens keep plain centrelines', () {
      final ink = DrawableInk(
        square(RoughPen.uniform),
        outlineWidth: 2,
        sketchWidth: 1,
      );
      expect(ink.sets.every((set) => set.strokes == null), isTrue);
      expect(ink.svgPaths().last.filled, isFalse);
    });

    test('outlines are inked and solid fills stay polygons', () {
      final ink = DrawableInk(
        square(RoughPen.ink),
        outlineWidth: 2,
        sketchWidth: 1,
      );
      final outline = ink.sets.singleWhere(
        (set) => set.type == OpSetType.path,
      );
      final fill = ink.sets.singleWhere(
        (set) => set.type == OpSetType.fillPath,
      );
      expect(outline.strokes, isNotEmpty);
      expect(fill.strokes, isNull);
      final paths = ink.svgPaths();
      expect(paths.first.type, OpSetType.fillPath);
      expect(paths.first.data, endsWith('Z'));
      expect(paths.skip(1).every((path) => path.filled), isTrue);
    });

    test('repeat passes are lighter than first passes', () {
      final ink = DrawableInk(
        Generator(
          DrawConfig.build(seed: 2, pen: RoughPen.ink),
          NoFiller(),
        ).line(0, 50, 200, 50),
        outlineWidth: 4,
        sketchWidth: 1,
      );
      final strokes = ink.sets.single.strokes!;
      expect(strokes, hasLength(2));
      expect(strokes[1].length, lessThan(strokes[0].length));
    });
  });

  group('RoughDrawing with a pen', () {
    RoughDrawing drawing(RoughPen pen) => RoughDrawing(
      Generator(
        DrawConfig.build(seed: 5, pen: pen),
        NoFiller(),
      ).roundedRectangle(20, 20, 200, 80, 12, 12, 12, 12),
      WiredBase.pathPainter(3, color: const Color(0xff000000)),
      WiredBase.fillPainter(const Color(0xff000000)),
    );

    test('progress reveals ink gradually', () async {
      final ink = drawing(RoughPen.ink);
      final none = await _inkPixels((canvas) => ink.paint(canvas, progress: 0));
      final half = await _inkPixels(
        (canvas) => ink.paint(canvas, progress: 0.3),
      );
      final full = await _inkPixels((canvas) => ink.paint(canvas));
      expect(none, 0);
      expect(half, greaterThan(0));
      expect(half, lessThan(full));
    });

    test('pressure reinforces the same ink', () async {
      final ink = drawing(RoughPen.brush);
      final resting = await _inkPixels((canvas) => ink.paint(canvas));
      final pressed = await _inkPixels(
        (canvas) => ink.paint(canvas, pressure: 1),
      );
      expect(pressed, greaterThan(resting));
    });

    test('drawRough paints the same ink as a prepared drawing', () async {
      final drawable = Generator(
        DrawConfig.build(seed: 5, pen: RoughPen.ink),
        NoFiller(),
      ).ellipse(120, 60, 160, 80);
      final border = WiredBase.pathPainter(
        3,
        color: const Color(0xff000000),
      );
      final fill = WiredBase.fillPainter(const Color(0xff000000));
      expect(
        await _inkPixels((canvas) => canvas.drawRough(drawable, border, fill)),
        await _inkPixels(
          (canvas) => RoughDrawing(drawable, border, fill).paint(canvas),
        ),
      );
    });
  });

  group('WiredThemeData pen', () {
    test('follows the roughness level unless overridden', () {
      expect(
        WiredThemeData(roughnessLevel: WiredRoughness.gentle).drawConfig.pen,
        RoughPen.fineliner,
      );
      final theme = WiredThemeData(pen: RoughPen.uniform);
      expect(theme.pen, RoughPen.uniform);
      expect(theme.drawConfig.pen, RoughPen.uniform);
      expect(theme.copyWith(pen: RoughPen.brush).pen, RoughPen.brush);
      expect(theme.copyWith(strokeWidth: 3).pen, RoughPen.uniform);
      expect(WiredThemeData(pen: RoughPen.brush), isNot(WiredThemeData()));
    });

    test('ink extent reserves room for the widest swell', () {
      final uniform = WiredThemeData(pen: RoughPen.uniform);
      final brush = WiredThemeData(pen: RoughPen.brush);
      expect(brush.inkExtent, greaterThan(uniform.inkExtent));
    });
  });
}
