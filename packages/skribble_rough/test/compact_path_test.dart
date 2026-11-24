import 'dart:math' as math;

import 'package:skribble_rough/skribble_rough.dart';
import 'package:test/test.dart';

/// Resolves [data] into absolute commands: each entry is the upper-case
/// command and its absolute arguments, with implicit repeats expanded.
List<(String, List<double>)> _absolute(String data) {
  final tokens = RegExp(
    r'[MmLlTtHhVvCcSsQqAaZz]|[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?',
  ).allMatches(data).map((m) => m[0]!).toList();
  const arity = {
    'M': 2, 'L': 2, 'T': 2, 'H': 1, 'V': 1, 'C': 6, 'S': 4, 'Q': 4, //
    'A': 7, 'Z': 0,
  };
  final out = <(String, List<double>)>[];
  var x = 0.0;
  var y = 0.0;
  var sx = 0.0;
  var sy = 0.0;
  String? command;
  var i = 0;
  while (i < tokens.length) {
    if (RegExp('[A-Za-z]').hasMatch(tokens[i])) command = tokens[i++];
    final kind = command!.toUpperCase();
    final rel = command != kind;
    if (kind == 'Z') {
      out.add(('Z', const []));
      x = sx;
      y = sy;
      continue;
    }
    final a = [
      for (var k = 0; k < arity[kind]!; k++) double.parse(tokens[i + k]),
    ];
    i += arity[kind]!;
    final abs = <double>[];
    switch (kind) {
      case 'H':
        abs.add(rel ? x + a[0] : a[0]);
        x = abs[0];
      case 'V':
        abs.add(rel ? y + a[0] : a[0]);
        y = abs[0];
      case 'A':
        abs.addAll([
          ...a.take(5),
          if (rel) x + a[5] else a[5],
          if (rel) y + a[6] else a[6],
        ]);
        x = abs[5];
        y = abs[6];
      default:
        for (var k = 0; k < a.length; k += 2) {
          abs
            ..add(rel ? x + a[k] : a[k])
            ..add(rel ? y + a[k + 1] : a[k + 1]);
        }
        x = abs[abs.length - 2];
        y = abs[abs.length - 1];
    }
    if (kind == 'M') {
      sx = x;
      sy = y;
      command = rel ? 'l' : 'L';
    }
    out.add((kind == 'M' && out.isNotEmpty ? 'M' : kind, abs));
  }
  return out;
}

/// Expects [actual] to draw [expected] rounded to [digits] decimals.
void _expectSameShape(String actual, String expected, int digits) {
  final a = _absolute(actual);
  final e = _absolute(expected);
  expect(a.length, e.length, reason: 'segment count');
  final scale = math.pow(10, digits);
  for (var i = 0; i < a.length; i++) {
    expect(a[i].$1, e[i].$1, reason: 'command $i');
    for (var k = 0; k < a[i].$2.length; k++) {
      expect(
        (a[i].$2[k] * scale).round(),
        (e[i].$2[k] * scale).round(),
        reason: 'segment $i argument $k',
      );
    }
  }
}

Generator _generator(int seed, RoughFillStyle style) => Generator(
  DrawConfig.build(seed: seed),
  style.filler(FillerConfig.build(drawConfig: DrawConfig.build(seed: seed))),
);

void main() {
  group('compactSvgPath', () {
    test('writes relative commands without redundant characters', () {
      expect(
        compactSvgPath('M10.04 20 L15.5 20 L15.5 25', fractionDigits: 1),
        'M10 20l5.5 0 0 5',
      );
      expect(
        compactSvgPath('M0 0 C0.5 0.5 1 -0.25 2 0Z', fractionDigits: 2),
        'M0 0c.5.5 1-.25 2 0z',
      );
    });

    test('starts each later subpath with a relative move', () {
      expect(
        compactSvgPath('M1 1L2 2M10 10L11 11', fractionDigits: 0),
        'M1 1l1 1m8 8 1 1',
      );
    });

    test('returns to the subpath start after close', () {
      final out = compactSvgPath('M5 5L9 5L9 9ZM5 5L1 1', fractionDigits: 0);
      _expectSameShape(out, 'M5 5L9 5L9 9ZM5 5L1 1', 0);
    });

    test('keeps rough drawings exactly at two decimals', () {
      var before = 0;
      var after = 0;
      for (final style in RoughFillStyle.values) {
        for (final seed in [1, 7, 42]) {
          final g = _generator(seed, style);
          for (final drawable in [
            g.rectangle(4, 4, 192, 92),
            g.ellipse(60, 40, 110, 70),
            g.curvePath([PointD(0, 0), PointD(40, 30), PointD(90, 5)]),
          ]) {
            final svg = RoughSvg.fromDrawable(drawable);
            final compact = svg.compact();
            _expectSameShape(compact.outline, svg.outline, 2);
            _expectSameShape(compact.sketch, svg.sketch, 2);
            _expectSameShape(compact.solid, svg.solid, 2);
            before += svg.outline.length + svg.sketch.length;
            after += compact.outline.length + compact.sketch.length;
          }
        }
      }
      expect(after, lessThan(before * 0.85));
    });

    test('rounds absolute coordinates so deltas never drift', () {
      // Thirty steps of 0.04 would drift by 1.2 if each delta were rounded.
      final path = StringBuffer('M0 0');
      for (var i = 1; i <= 30; i++) {
        path.write('L${(i * 0.04).toStringAsFixed(2)} 0');
      }
      _expectSameShape(
        compactSvgPath(path.toString(), fractionDigits: 1),
        path.toString(),
        1,
      );
    });

    test('understands every command, relative input, and packed arc flags', () {
      const input =
          'M10 10h5v5H20V30l1 1c1 1 2 2 3 3s1 1 2 2q1 1 2 2t1 1 '
          'a5 5 0 011 1A2 3 30 1 0 40 40z';
      final out = compactSvgPath(input, fractionDigits: 1);
      // The same path with the arc flags spaced out, for the test parser.
      _expectSameShape(out, input.replaceFirst('011', '0 1 1'), 1);
      expect(out, contains('a5 5 0 0 1 1 1'));
    });

    test('leaves data it cannot parse unchanged', () {
      expect(compactSvgPath('M1 1 L oops'), 'M1 1 L oops');
      expect(compactSvgPath('1 2 3'), '1 2 3');
      expect(compactSvgPath(''), '');
    });

    test('rejects an unsupported precision', () {
      expect(() => compactSvgPath('M0 0', fractionDigits: 7), throwsRangeError);
      expect(
        () => compactSvgPath('M0 0', fractionDigits: -1),
        throwsRangeError,
      );
    });
  });
}
