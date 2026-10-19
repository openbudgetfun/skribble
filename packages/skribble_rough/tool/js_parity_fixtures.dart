// Writes the fixtures that keep the npm package `@skribble/rough` drawing the
// same ink as this engine. The TypeScript tests replay every case and expect
// byte-identical SVG. Outputs are stored as FNV-1a hashes with their lengths,
// which keeps the fixture small; one case is stored in full for readable
// diffs.
//
//   dart run packages/skribble_rough/tool/js_parity_fixtures.dart \
//     > js/rough/test/fixtures/dart-parity.json
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:skribble_rough/skribble_rough.dart';

typedef _Draw = Drawable Function(Generator generator);

final Map<String, _Draw> _shapes = {
  'rectangle': (g) => g.rectangle(4, 4, 192, 92),
  'smallRectangle': (g) => g.rectangle(2, 3, 30, 20),
  'ellipse': (g) => g.ellipse(100, 50, 180, 80),
  'circle': (g) => g.circle(40, 40, 60),
  'shortLine': (g) => g.line(10, 10, 40, 30),
  'longLine': (g) => g.line(5, 5, 400, 120),
  'veryLongLine': (g) => g.line(0, 0, 900, 40),
  'polygon': (g) => g.polygon([
    PointD(10, 80),
    PointD(60, 5),
    PointD(120, 70),
    PointD(80, 110),
    PointD(30, 100),
  ]),
  'linearPath': (g) => g.linearPath([
    PointD(5, 5),
    PointD(80, 30),
    PointD(20, 70),
  ]),
  'arc': (g) => g.arc(100, 100, 160, 120, 0.3, math.pi * 1.4),
  'closedArc': (g) => g.arc(100, 100, 160, 120, -0.5, math.pi, true),
  'curve': (g) => g.curvePath([
    PointD(4, 50),
    PointD(40, 10),
    PointD(80, 40),
    PointD(116, 12),
  ]),
  'threePointCurve': (g) => g.curvePath([
    PointD(4, 50),
    PointD(40, 10),
    PointD(80, 40),
  ]),
  'roundedRectangle': (g) => g.roundedRectangle(4, 4, 220, 64, 16, 16, 16, 16),
  'mixedRoundedRectangle': (g) =>
      g.roundedRectangle(2, 2, 90, 40, 4, 12, 0, 30),
};

void main() {
  final cases = <Map<String, Object?>>[];

  for (final MapEntry(key: name, value: draw) in _shapes.entries) {
    for (final style in RoughFillStyle.values) {
      for (final (seed, roughness) in [(1, 1.8), (7, 1.0), (42, 2.6)]) {
        // Keep the matrix small: fills only matter for closed shapes.
        if (style != RoughFillStyle.none &&
            const {
              'shortLine',
              'longLine',
              'veryLongLine',
              'linearPath',
              'curve',
              'threePointCurve',
            }.contains(name)) {
          continue;
        }
        if (style != RoughFillStyle.none && seed == 42) continue;
        cases.add(_case(name, draw, style, seed, roughness, RoughPen.ink));
      }
    }
  }

  // Every pen preset through the ink exporter.
  for (final (penName, pen) in [
    ('uniform', RoughPen.uniform),
    ('fineliner', RoughPen.fineliner),
    ('ink', RoughPen.ink),
    ('brush', RoughPen.brush),
  ]) {
    for (final name in ['rectangle', 'ellipse', 'curve', 'longLine']) {
      cases.add(
        _case(name, _shapes[name]!, RoughFillStyle.hachure, 3, 1.4, pen)
          ..['pen'] = penName,
      );
    }
  }

  final randoms = [
    for (final seed in [0, 1, 7, 42, -3, 123456789])
      {
        'seed': seed,
        'values': () {
          final random = math.Random(seed);
          return [for (var i = 0; i < 8; i++) random.nextDouble()];
        }(),
      },
  ];

  DrawConfig sampleConfig() => DrawConfig.build(seed: 7, roughness: 1.2);
  final sample = Generator(
    sampleConfig(),
    RoughFillStyle.hachure.filler(
      FillerConfig.build(drawConfig: sampleConfig(), hachureGap: 8),
    ),
  ).rectangle(4, 4, 192, 92);

  stdout.writeln(
    jsonEncode({
      'randoms': randoms,
      'sample': {
        'description':
            'rectangle(4, 4, 192, 92), seed 7, roughness 1.2, '
            'hachure gap 8',
        'elements': RoughSvg.fromDrawable(
          sample,
        ).toPathElements(stroke: '#222', fill: 'rgb(1, 2, 3)'),
      },
      'cases': cases,
    }),
  );
}

Map<String, Object?> _case(
  String name,
  _Draw draw,
  RoughFillStyle style,
  int seed,
  double roughness,
  RoughPen pen,
) {
  DrawConfig config() =>
      DrawConfig.build(seed: seed, roughness: roughness, pen: pen);
  final generator = Generator(
    config(),
    style.filler(FillerConfig.build(drawConfig: config(), hachureGap: 8)),
  );
  final drawable = draw(generator);
  final svg = RoughSvg.fromDrawable(drawable);
  final ink = DrawableInk(drawable, outlineWidth: 2, sketchWidth: 1);

  return {
    'shape': name,
    'fillStyle': style.name,
    'seed': seed,
    'roughness': roughness,
    'svg': {
      'outline': _digest(svg.outline),
      'sketch': _digest(svg.sketch),
      'solid': _digest(svg.solid),
      'elements': _digest(
        svg.toPathElements(stroke: '#222', fill: 'rgb(1, 2, 3)'),
      ),
    },
    // Pen strokes only. Plain centrelines print full-precision doubles, whose
    // last digit can differ between libm implementations of sin and cos.
    'ink': [
      for (final path in ink.svgPaths())
        if (path.filled && path.type != OpSetType.fillPath)
          _digest('${path.type.name} ${path.data}'),
    ],
  };
}

/// FNV-1a over UTF-16 code units, with the length: `<hash>:<length>`.
String _digest(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  return '${hash.toRadixString(16).padLeft(8, '0')}:${value.length}';
}
