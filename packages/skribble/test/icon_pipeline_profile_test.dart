import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/src/canvas/wired_waver.dart';
import 'package:skribble/src/generated/skribble_glyphs.g.dart';
import 'package:skribble/src/rough/skribble_rough.dart';
import 'package:skribble/src/wired_svg_icon_painter.dart';

/// Reports the per-stage cost of preparing icon ink, so optimization work
/// targets the stage that actually costs the most.
///
/// Run with: flutter test test/icon_pipeline_profile_test.dart
void main() {
  final icons = SkribbleGlyphs.all.values.toList();

  test('stage costs for typical glyphs at 24 and 32px', () {
    final labels = <String>[
      'prepare',
      'waver fill',
      'fill polygons',
      'stroke ink',
      'outline ink',
    ];
    final totals = {for (final label in labels) label: 0.0};
    var count = 0;

    for (final icon in icons.take(60)) {
      for (final size in [24.0, 32.0]) {
        final drawConfig = DrawConfig.build(
          maxRandomnessOffset: 2 * 2.5 * (size / 24).clamp(0, 2),
          roughness: 1.8,
          lineWobble: 1,
          bowing: 0.8,
          curveFitting: 0.9,
          curveStepCount: 8,
          seed: 1,
        );
        final silhouetteWidth = 2 * (size / 24);

        var prepare = 0.0;
        var waverFill = 0.0;
        var fillPolygons = 0.0;
        var strokeInk = 0.0;
        var outlineInk = 0.0;

        void time(double Function() body) => body();

        double prepareStage() {
          final sw = Stopwatch()..start();
          final primitives = prepareIconPrimitives(icon, size);
          prepare += sw.elapsedMicroseconds / 1000;

          final contours = <List<WaveredContour>>[];
          final fills = <Path>[];
          for (final primitive in primitives) {
            sw
              ..reset()
              ..start();
            final fillContours = waverPath(primitive.path, drawConfig);
            waverFill += sw.elapsedMicroseconds / 1000;

            sw
              ..reset()
              ..start();
            fills.add(
              waveredPolygons(fillContours, fillType: primitive.path.fillType),
            );
            fillPolygons += sw.elapsedMicroseconds / 1000;
            contours.add(fillContours);

            sw
              ..reset()
              ..start();
            final strokeContours = waverPath(
              primitive.strokePath,
              drawConfig,
              bounds: primitive.path.getBounds(),
            );
            final strokeSink = PathInkOutline();
            for (final (index, contour) in strokeContours.indexed) {
              if (contour.points.length < 2) continue;
              InkStroke(
                contour.toOps(),
                width: primitive.strokeWidth,
                pen: drawConfig.pen,
                seed: drawConfig.seed * 7919 + index * 131,
              ).writeOutline(strokeSink);
            }
            strokeInk += sw.elapsedMicroseconds / 1000;

            sw
              ..reset()
              ..start();
            final outlineSink = PathInkOutline();
            for (final (index, contour) in fillContours.indexed) {
              if (contour.points.length < 2) continue;
              InkStroke(
                contour.toOps(),
                width: silhouetteWidth * 0.5,
                pen: drawConfig.pen,
                seed: drawConfig.seed * 7919 + index * 131 + 1,
              ).writeOutline(outlineSink);
            }
            outlineInk += sw.elapsedMicroseconds / 1000;
          }
          return 0;
        }

        time(prepareStage);

        totals['prepare'] = totals['prepare']! + prepare;
        totals['waver fill'] = totals['waver fill']! + waverFill;
        totals['fill polygons'] = totals['fill polygons']! + fillPolygons;
        totals['stroke ink'] = totals['stroke ink']! + strokeInk;
        totals['outline ink'] = totals['outline ink']! + outlineInk;
        count++;
      }
    }

    var sum = 0.0;
    for (final label in labels) {
      final avg = totals[label]! / count;
      sum += avg;
      // ignore: avoid_print
      print('$label: ${avg.toStringAsFixed(3)} ms');
    }
    // ignore: avoid_print
    print('TOTAL: ${sum.toStringAsFixed(3)} ms/icon');
    expect(count, 102);
  });
}
