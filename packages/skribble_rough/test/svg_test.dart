import 'package:skribble_rough/skribble_rough.dart';
import 'package:test/test.dart';

/// A full SVG path: one or more commands, each followed by numbers.
final _pathData = RegExp(
  r'^(?:[MLCZ](?:-?\d+(?:\.\d{1,2})?(?: -?\d+(?:\.\d{1,2})?)*)?)+$',
);

/// Builds a generator whose shape and fill both replay from [seed].
Generator _generator(int seed, [RoughFillStyle style = RoughFillStyle.none]) {
  return Generator(
    DrawConfig.build(seed: seed),
    style.filler(FillerConfig.build(drawConfig: DrawConfig.build(seed: seed))),
  );
}

/// Every shape the generator can draw, keyed by name.
Map<String, Drawable> _shapes(int seed) {
  return {
    'line': _generator(seed).line(0, 0, 100, 20),
    'rectangle': _generator(seed).rectangle(4, 4, 92, 42),
    'roundedRectangle': _generator(
      seed,
    ).roundedRectangle(4, 4, 92, 42, 8, 8, 8, 8),
    'ellipse': _generator(seed).ellipse(50, 25, 90, 40),
    'circle': _generator(seed).circle(25, 25, 40),
    'polygon': _generator(
      seed,
    ).polygon([PointD(0, 0), PointD(60, 10), PointD(30, 50)]),
    'linearPath': _generator(
      seed,
    ).linearPath([PointD(0, 0), PointD(40, 30), PointD(80, 0)]),
    'curvePath': _generator(
      seed,
    ).curvePath([PointD(0, 20), PointD(30, 0), PointD(60, 30), PointD(90, 10)]),
    'arc': _generator(seed).arc(50, 50, 80, 80, 0, 3.14, true),
  };
}

void main() {
  group('opSetToSvgPath', () {
    test('returns an empty string for an empty set', () {
      expect(opSetToSvgPath(OpSet(type: OpSetType.path, ops: [])), isEmpty);
      expect(opSetToSvgPath(OpSet(type: OpSetType.path)), isEmpty);
    });

    test('writes move, line, and curve commands', () {
      final set = OpSet(
        type: OpSetType.path,
        ops: [
          Op.move(PointD(1, 2)),
          Op.lineTo(PointD(3.5, 4.25)),
          Op.curveTo(PointD(5, 6), PointD(7, 8), PointD(9, 10)),
        ],
      );

      expect(opSetToSvgPath(set), 'M1 2L3.5 4.25C5 6 7 8 9 10');
    });

    test('rounds to two decimals and never writes negative zero', () {
      final set = OpSet(
        type: OpSetType.path,
        ops: [Op.move(PointD(1.23456, -0.001))],
      );

      expect(opSetToSvgPath(set), 'M1.23 0');
    });

    test('closes solid fills', () {
      final set = OpSet(
        type: OpSetType.fillPath,
        ops: [
          Op.move(PointD(0, 0)),
          Op.lineTo(PointD(10, 0)),
          Op.lineTo(PointD(10, 10)),
        ],
      );

      expect(opSetToSvgPath(set), endsWith('Z'));
    });
  });

  group('RoughSvg', () {
    for (final MapEntry(key: name, value: drawable) in _shapes(3).entries) {
      test('$name produces well-formed outline data', () {
        final svg = RoughSvg.fromDrawable(drawable);

        expect(svg.isEmpty, isFalse);
        expect(svg.outline, matches(_pathData));
        expect(svg.outline, startsWith('M'));
        expect(svg.sketch, isEmpty);
        expect(svg.solid, isEmpty);
      });
    }

    test('the same seed always produces the same path data', () {
      final first = _shapes(42);
      final second = _shapes(42);

      for (final name in first.keys) {
        expect(
          RoughSvg.fromDrawable(first[name]!).outline,
          RoughSvg.fromDrawable(second[name]!).outline,
          reason: name,
        );
      }
    });

    test('different seeds produce different path data', () {
      final first = RoughSvg.fromDrawable(_shapes(1)['rectangle']!);
      final second = RoughSvg.fromDrawable(_shapes(2)['rectangle']!);

      expect(first.outline, isNot(second.outline));
    });

    test('sketched fills land in the sketch group', () {
      for (final style in [
        RoughFillStyle.hachure,
        RoughFillStyle.crossHatch,
        RoughFillStyle.zigzag,
        RoughFillStyle.dashed,
        RoughFillStyle.dots,
      ]) {
        final drawable = _generator(5, style).rectangle(4, 4, 92, 92);
        final svg = RoughSvg.fromDrawable(drawable);

        expect(svg.sketch, matches(_pathData), reason: style.name);
        expect(svg.solid, isEmpty, reason: style.name);
        expect(svg.outline, isNotEmpty, reason: style.name);
      }
    });

    test('fills replay from their seed', () {
      for (final style in RoughFillStyle.values) {
        final first = _generator(9, style).rectangle(4, 4, 92, 92);
        final second = _generator(9, style).rectangle(4, 4, 92, 92);

        expect(
          RoughSvg.fromDrawable(first).toPathElements(),
          RoughSvg.fromDrawable(second).toPathElements(),
          reason: style.name,
        );
      }
    });

    test('solid fills land in the solid group and close', () {
      final drawable = _generator(
        5,
        RoughFillStyle.solid,
      ).rectangle(4, 4, 92, 92);
      final svg = RoughSvg.fromDrawable(drawable);

      expect(svg.solid, matches(_pathData));
      expect(svg.solid, endsWith('Z'));
      expect(svg.sketch, isEmpty);
    });

    test('an empty drawable is empty and renders nothing', () {
      final svg = RoughSvg.fromDrawable(Drawable());

      expect(svg.isEmpty, isTrue);
      expect(svg.toPathElements(), isEmpty);
    });
  });

  group('RoughSvg.toPathElements', () {
    final svg = RoughSvg.fromDrawable(
      _generator(7, RoughFillStyle.solid).rectangle(4, 4, 92, 42),
    );

    test('paints solid fill before the outline', () {
      final markup = svg.toPathElements();

      expect(
        markup.indexOf('stroke="none"'),
        lessThan(markup.indexOf('fill="none"')),
      );
      expect(RegExp('<path ').allMatches(markup), hasLength(2));
      expect(RegExp('/>').allMatches(markup), hasLength(2));
    });

    test('applies colours, widths, and non-scaling strokes', () {
      final markup = svg.toPathElements(
        stroke: '#222',
        fill: 'var(--fill)',
        strokeWidth: 2,
        nonScalingStroke: true,
      );

      expect(markup, contains('stroke="#222"'));
      expect(markup, contains('fill="var(--fill)"'));
      expect(markup, contains('stroke-width="2"'));
      expect(markup, contains('vector-effect="non-scaling-stroke"'));
    });

    test('escapes paint values', () {
      final markup = svg.toPathElements(stroke: '"><script>');

      expect(markup, isNot(contains('<script>')));
      expect(markup, contains('&quot;&gt;&lt;script&gt;'));
    });
  });

  group('RoughFillStyle', () {
    test('maps every style to its filler', () {
      final config = FillerConfig.build();

      expect(RoughFillStyle.none.filler(config), isA<NoFiller>());
      expect(RoughFillStyle.hachure.filler(config), isA<HachureFiller>());
      expect(RoughFillStyle.crossHatch.filler(config), isA<HatchFiller>());
      expect(RoughFillStyle.zigzag.filler(config), isA<ZigZagFiller>());
      expect(RoughFillStyle.dashed.filler(config), isA<DashedFiller>());
      expect(RoughFillStyle.dots.filler(config), isA<DotFiller>());
      expect(RoughFillStyle.solid.filler(config), isA<SolidFiller>());
    });

    test('passes the configuration through', () {
      final config = FillerConfig.build(hachureGap: 4);

      expect(RoughFillStyle.hachure.filler(config).config, same(config));
    });
  });
}
