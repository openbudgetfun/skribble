import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';

import 'helpers/render.dart';

void main() {
  group('WiredBox', () {
    testServer('wraps its child in a div behind a rough outline', (
      tester,
    ) async {
      final body = await renderBody(
        tester,
        const WiredBox(child: Component.text('Inside')),
      );
      final box = single(body, '.skribble-box');

      expect(box.localName, 'div');
      expect(box.text, contains('Inside'));
      expectInkOverlay(single(box, 'svg'));
      expect(box.querySelectorAll('.skribble-ink-outline'), hasLength(1));
      expect(box.querySelectorAll('.skribble-ink-hatch'), isEmpty);
      expect(box.querySelectorAll('.skribble-ink-solid'), isEmpty);
    });

    testServer('renders the ink before the child so it paints behind', (
      tester,
    ) async {
      final body = await renderBody(
        tester,
        const WiredBox(child: Component.text('Inside')),
      );
      final box = single(body, '.skribble-box');

      expect(box.children.first.localName, 'svg');
    });

    testServer('uses the given tag, classes, and attributes', (tester) async {
      final body = await renderBody(
        tester,
        const WiredBox(
          tag: 'section',
          classes: 'pricing  tier',
          attributes: {'id': 'pro', 'aria-label': 'Pro plan'},
          child: Component.text('Pro'),
        ),
      );
      final box = single(body, 'section');

      expect(box.classes, containsAll(['skribble-box', 'pricing', 'tier']));
      expect(box.id, 'pro');
      expect(box.attributes['aria-label'], 'Pro plan');
    });

    testServer('draws sketched fills in the hatch group', (tester) async {
      for (final style in [
        RoughFillStyle.hachure,
        RoughFillStyle.crossHatch,
        RoughFillStyle.zigzag,
        RoughFillStyle.dashed,
        RoughFillStyle.dots,
      ]) {
        final body = await renderBody(
          tester,
          WiredBox(fillStyle: style, child: const Component.text('Filled')),
        );

        expect(
          body.querySelectorAll('.skribble-ink-hatch'),
          hasLength(1),
          reason: style.name,
        );
        expectInkOverlay(single(body, 'svg'));
      }
    });

    testServer('draws solid fills as a filled path', (tester) async {
      final body = await renderBody(
        tester,
        const WiredBox(
          fillStyle: RoughFillStyle.solid,
          child: Component.text('Solid'),
        ),
      );
      final solid = single(body, '.skribble-ink-solid');

      expect(solid.attributes['fill'], 'currentColor');
      expect(solid.attributes['stroke'], 'none');
      expect(solid.attributes['d'], endsWith('Z'));
    });

    testServer('exposes the fill colour as a custom property', (tester) async {
      final body = await renderBody(
        tester,
        const WiredBox(
          fill: '#ffe08a',
          fillStyle: RoughFillStyle.hachure,
          child: Component.text('Tinted'),
        ),
      );

      expect(
        single(body, '.skribble-box').attributes['style'],
        '--skribble-fill: #ffe08a',
      );
    });

    testServer('leaves the style attribute off without a fill', (tester) async {
      final body = await renderBody(
        tester,
        const WiredBox(child: Component.text('Plain')),
      );

      expect(single(body, '.skribble-box').attributes['style'], isNull);
    });

    testServer('renders identical markup for the same seed', (tester) async {
      Component box() => const WiredBox(
        seed: 12,
        fillStyle: RoughFillStyle.hachure,
        child: Component.text('Same'),
      );

      final first = await renderMarkup(tester, box());
      final second = await renderMarkup(tester, box());

      expect(first, second);
    });

    testServer('draws a different outline for a different seed', (
      tester,
    ) async {
      final first = await renderBody(
        tester,
        const WiredBox(child: Component.text('A')),
      );
      final second = await renderBody(
        tester,
        const WiredBox(seed: 2, child: Component.text('A')),
      );

      expect(
        single(first, '.skribble-ink-outline').attributes['d'],
        isNot(single(second, '.skribble-ink-outline').attributes['d']),
      );
    });

    testServer('draws straighter lines with less roughness', (tester) async {
      final calm = await renderBody(
        tester,
        const WiredBox(roughness: 0, child: Component.text('Calm')),
      );
      final wild = await renderBody(
        tester,
        const WiredBox(roughness: 3, child: Component.text('Wild')),
      );

      expect(
        single(calm, '.skribble-ink-outline').attributes['d'],
        isNot(single(wild, '.skribble-ink-outline').attributes['d']),
      );
      expect(
        single(calm, '.skribble-ink-outline').attributes['d'],
        startsWith('M3 3'),
      );
    });
  });

  group('WiredCard', () {
    testServer('renders a padded card box', (tester) async {
      final body = await renderBody(
        tester,
        const WiredCard(
          classes: 'feature',
          child: Component.element(
            tag: 'h3',
            children: [Component.text('Feature')],
          ),
        ),
      );
      final card = single(body, '.skribble-card');

      expect(card.localName, 'div');
      expect(card.classes, containsAll(['skribble-box', 'feature']));
      expect(single(card, 'h3').text, 'Feature');
      expectInkOverlay(single(card, 'svg'));
    });

    testServer('supports fills', (tester) async {
      final body = await renderBody(
        tester,
        const WiredCard(
          fill: 'pink',
          fillStyle: RoughFillStyle.crossHatch,
          child: Component.text('Card'),
        ),
      );

      expect(body.querySelectorAll('.skribble-ink-hatch'), hasLength(1));
      expect(
        single(body, '.skribble-card').attributes['style'],
        '--skribble-fill: pink',
      );
    });
  });

  group('WiredCircle', () {
    testServer('wraps its child in a rough ellipse', (tester) async {
      final body = await renderBody(
        tester,
        const WiredCircle(tag: 'span', child: Component.text('1')),
      );
      final circle = single(body, '.skribble-circle');

      expect(circle.localName, 'span');
      expect(circle.text, contains('1'));
      expectInkOverlay(single(circle, 'svg'));
      expect(
        single(circle, 'svg').attributes['viewBox'],
        '0 0 120 120',
      );
    });

    testServer('draws curves rather than straight edges', (tester) async {
      final body = await renderBody(
        tester,
        const WiredCircle(child: Component.text('Badge')),
      );
      final outline = single(body, '.skribble-ink-outline');

      expect(outline.attributes['d'], contains('C'));
      expect(outline.attributes['d'], isNot(contains('L')));
    });
  });
}
