import 'dart:math' as math;

import 'package:html/dom.dart' as html;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';

import 'helpers/css.dart';
import 'helpers/render.dart';

/// The least room between content and a drawn line, matching the Flutter
/// widgets' `kWiredInkPadding`.
const _vertical = 8.0;
const _horizontal = 12.0;

/// How far the outline in [svg] reaches in from the edges of its canvas,
/// in nominal units, as `(x, y)`.
///
/// Every number pair in the path is an end or control point, and a cubic
/// stays inside its control points, so this bounds the drawn line.
(double, double) _reach(html.Element svg) {
  final box = svg.attributes['viewBox']!.split(' ').map(double.parse).toList();
  final width = box[2];
  final height = box[3];
  final numbers = RegExp(r'-?\d+(?:\.\d+)?')
      .allMatches(single(svg, '.skribble-ink-outline').attributes['d']!)
      .map((match) => double.parse(match[0]!))
      .toList();
  var x = 0.0;
  var y = 0.0;

  for (var i = 0; i + 1 < numbers.length; i += 2) {
    final fromSide = math.min(numbers[i], width - numbers[i]);
    final fromEdge = math.min(numbers[i + 1], height - numbers[i + 1]);

    if (fromSide < fromEdge) {
      x = math.max(x, fromSide);
    } else {
      y = math.max(y, fromEdge);
    }
  }

  return (x, y);
}

/// The `[vertical, horizontal]` padding of [rule], in pixels.
List<double> _padding(Map<String, String> rule, {required double em}) {
  final values = rule['padding']!.split(' ');

  return [
    cssPixels(values.first, em: em),
    cssPixels(values.last, em: em),
  ];
}

void main() {
  group('ink padding', () {
    testServer('keeps box content clear of the line at its nominal size', (
      tester,
    ) async {
      final [vertical, horizontal] = _padding(
        ruleFor(skribbleCss, ':where(.skribble-box)'),
        em: 16,
      );

      for (var seed = 1; seed <= 40; seed++) {
        final body = await renderBody(
          tester,
          WiredBox(seed: seed, child: const Component.text('Box')),
        );
        final (x, y) = _reach(single(body, 'svg'));

        expect(vertical - y, greaterThanOrEqualTo(_vertical), reason: '$seed');
        expect(
          horizontal - x,
          greaterThanOrEqualTo(_horizontal),
          reason: '$seed',
        );
      }
    });

    testServer('keeps card content clear of the line at its nominal size', (
      tester,
    ) async {
      final [vertical, horizontal] = _padding(
        ruleFor(skribbleCss, '.skribble-card'),
        em: 16,
      );

      for (var seed = 1; seed <= 40; seed++) {
        final body = await renderBody(
          tester,
          WiredCard(seed: seed, child: const Component.text('Card')),
        );
        final (x, y) = _reach(single(body, 'svg'));

        expect(vertical - y, greaterThanOrEqualTo(_vertical), reason: '$seed');
        expect(
          horizontal - x,
          greaterThanOrEqualTo(_horizontal),
          reason: '$seed',
        );
      }
    });

    testServer('keeps button labels clear of the line at 1x and 1.3x text', (
      tester,
    ) async {
      final button = ruleFor(skribbleCss, '.skribble-button');

      for (final scale in [1.0, 1.3]) {
        final rem = 16 * scale;
        final font = cssPixels(button['font-size']!, rem: rem, em: rem);
        final [vertical, horizontal] = _padding(button, em: font);
        final minHeight = cssPixels(button['min-height']!, rem: rem, em: font);
        final height = math.max(
          minHeight,
          font * double.parse(button['line-height']!) + vertical * 2,
        );

        for (var seed = 1; seed <= 40; seed++) {
          final body = await renderBody(
            tester,
            WiredButton(seed: seed, child: const Component.text('Go')),
          );

          for (final svg in body.querySelectorAll('svg')) {
            final (x, y) = _reach(svg);
            final stretch = height / WiredButton.buttonCanvas.height;

            expect(
              vertical - y * stretch,
              greaterThanOrEqualTo(_vertical),
              reason: 'seed $seed at ${scale}x',
            );
            expect(
              horizontal - x,
              greaterThanOrEqualTo(_horizontal),
              reason: 'seed $seed at ${scale}x',
            );
          }
        }
      }
    });
  });
}
