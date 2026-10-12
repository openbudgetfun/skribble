import 'package:html/dom.dart' as html;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';

import 'helpers/render.dart';

/// Counts the subpaths (pen strokes) in an SVG path.
int _strokes(String data) => 'M'.allMatches(data).length;

void main() {
  group('WiredSketch', () {
    final sketches = <String, Component Function()>{
      'rectangle': () => WiredSketch.rectangle(width: 120, height: 60),
      'ellipse': () => WiredSketch.ellipse(width: 80, height: 80),
      'line': () => WiredSketch.line(
        width: 100,
        height: 20,
        from: (2, 10),
        to: (98, 10),
      ),
      'polygon': () => WiredSketch.polygon(
        width: 60,
        height: 60,
        points: const [(30, 2), (58, 58), (2, 58)],
      ),
      'curve': () => WiredSketch.curve(
        width: 120,
        height: 60,
        points: const [(4, 50), (40, 10), (80, 40), (116, 12)],
      ),
    };

    for (final MapEntry(key: name, value: sketch) in sketches.entries) {
      testServer('$name renders a decorative svg at its intrinsic size', (
        tester,
      ) async {
        final body = await renderBody(tester, sketch());
        final svg = single(body, 'svg.skribble-sketch');
        final width = svg.attributes['width']!;
        final height = svg.attributes['height']!;

        expect(svg.attributes['viewBox'], '0 0 $width $height');
        expect(svg.attributes.containsKey('preserveAspectRatio'), isFalse);
        expect(svg.attributes['aria-hidden'], 'true');
        expect(
          single(svg, '.skribble-ink-outline').attributes['d'],
          startsWith('M'),
        );
      });
    }

    testServer('a label makes the sketch an image', (tester) async {
      final body = await renderBody(
        tester,
        WiredSketch.ellipse(
          width: 40,
          height: 40,
          label: 'A hand-drawn sun',
        ),
      );
      final svg = single(body, 'svg');

      expect(svg.attributes['role'], 'img');
      expect(svg.attributes['aria-label'], 'A hand-drawn sun');
      expect(svg.attributes.containsKey('aria-hidden'), isFalse);
    });

    testServer('arrowheads add two barbs to lines and curves', (tester) async {
      final plainLine = await renderBody(
        tester,
        WiredSketch.line(width: 100, height: 40, from: (2, 20), to: (98, 20)),
      );
      final arrowLine = await renderBody(
        tester,
        WiredSketch.line(
          width: 100,
          height: 40,
          from: (2, 20),
          to: (98, 20),
          arrowhead: true,
        ),
      );
      final plainCurve = await renderBody(
        tester,
        WiredSketch.curve(
          width: 100,
          height: 40,
          points: const [(2, 30), (98, 10)],
        ),
      );
      final arrowCurve = await renderBody(
        tester,
        WiredSketch.curve(
          width: 100,
          height: 40,
          points: const [(2, 30), (98, 10)],
          arrowhead: true,
        ),
      );

      String outline(html.Element body) =>
          single(body, '.skribble-ink-outline').attributes['d']!;

      // Each rough line is drawn as two pen strokes, so two barbs add four.
      expect(_strokes(outline(arrowLine)), _strokes(outline(plainLine)) + 4);
      expect(_strokes(outline(arrowCurve)), _strokes(outline(plainCurve)) + 4);
    });

    testServer('fills closed shapes and themes the ink', (tester) async {
      final body = await renderBody(
        tester,
        WiredSketch.polygon(
          width: 60,
          height: 60,
          points: const [(30, 2), (58, 58), (2, 58)],
          fillStyle: RoughFillStyle.hachure,
          fill: 'gold',
          color: 'navy',
          classes: 'doodle',
        ),
      );
      final svg = single(body, 'svg');

      expect(svg.classes, containsAll(['skribble-sketch', 'doodle']));
      expect(
        svg.attributes['style'],
        '--skribble-ink: navy; --skribble-fill: gold',
      );
      expect(svg.querySelectorAll('.skribble-ink-hatch'), hasLength(1));
    });

    test('a curve needs at least two points', () {
      expect(
        () => WiredSketch.curve(width: 10, height: 10, points: const [(1, 1)]),
        throwsArgumentError,
      );
    });

    testServer('renders identical markup for the same seed', (tester) async {
      Component arrow() => WiredSketch.curve(
        width: 120,
        height: 60,
        seed: 9,
        points: const [(4, 50), (60, 10), (116, 40)],
        arrowhead: true,
      );

      expect(
        await renderMarkup(tester, arrow()),
        await renderMarkup(tester, arrow()),
      );
    });
  });
}
