import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';

import 'helpers/render.dart';

void main() {
  group('WiredButton', () {
    testServer('renders a native button without an href', (tester) async {
      final body = await renderBody(
        tester,
        const WiredButton(child: Component.text('Save')),
      );
      final button = single(body, 'button');

      expect(button.attributes['type'], 'button');
      expect(button.attributes.containsKey('href'), isFalse);
      expect(button.text.trim(), 'Save');
    });

    testServer('renders a link with an href', (tester) async {
      final body = await renderBody(
        tester,
        const WiredButton(href: '/start', child: Component.text('Start')),
      );
      final link = single(body, 'a');

      expect(link.attributes['href'], '/start');
      expect(link.attributes.containsKey('type'), isFalse);
      expect(body.querySelectorAll('button'), isEmpty);
    });

    testServer('keeps the label as the accessible name', (tester) async {
      final body = await renderBody(
        tester,
        const WiredButton(child: Component.text('Join the beta')),
      );
      final label = single(body, '.skribble-button__label');

      expect(label.text, 'Join the beta');

      body.querySelectorAll('svg').forEach(expectInkOverlay);
    });

    testServer('draws two outline frames for the hover boil', (tester) async {
      final body = await renderBody(
        tester,
        const WiredButton(seed: 3, child: Component.text('Boil')),
      );
      final frames = body.querySelectorAll('.skribble-ink');

      expect(frames, hasLength(2));
      expect(
        frames.first.querySelector('.skribble-ink-outline')!.attributes['d'],
        isNot(
          frames.last.querySelector('.skribble-ink-outline')!.attributes['d'],
        ),
      );
    });

    testServer('fills the primary variant and outlines the secondary', (
      tester,
    ) async {
      final primary = await renderBody(
        tester,
        const WiredButton(child: Component.text('Primary')),
      );
      final secondary = await renderBody(
        tester,
        const WiredButton(
          variant: WiredButtonVariant.secondary,
          child: Component.text('Secondary'),
        ),
      );

      expect(
        single(primary, '.skribble-button').classes,
        containsAll([
          'skribble-box',
          'skribble-button--primary',
          'skribble-wobble',
        ]),
      );
      expect(primary.querySelectorAll('.skribble-ink-solid'), hasLength(2));
      expect(
        single(secondary, '.skribble-button').classes,
        contains('skribble-button--secondary'),
      );
      expect(secondary.querySelectorAll('.skribble-ink-solid'), isEmpty);
    });

    testServer('lets attributes override the defaults', (tester) async {
      final body = await renderBody(
        tester,
        const WiredButton(
          classes: 'cta',
          attributes: {'type': 'submit', 'name': 'intent'},
          child: Component.text('Send'),
        ),
      );
      final button = single(body, 'button');

      expect(button.attributes['type'], 'submit');
      expect(button.attributes['name'], 'intent');
      expect(button.classes, contains('cta'));
    });

    testServer('merges a class attribute instead of repeating it', (
      tester,
    ) async {
      final markup = await renderMarkup(
        tester,
        const WiredButton(
          classes: 'cta',
          attributes: {'class': 'wide', 'aria-disabled': 'true'},
          child: Component.text('Soon'),
        ),
      );
      final tag = RegExp('<button [^>]*>').firstMatch(markup)![0]!;

      expect(' class='.allMatches(tag), hasLength(1), reason: tag);
      expect(tag, contains('cta wide"'));
      expect(tag, contains('aria-disabled="true"'));
    });

    testServer('lets an aria-label name an icon-only button', (tester) async {
      final body = await renderBody(
        tester,
        WiredButton(
          attributes: const {'aria-label': 'Next page'},
          child: WiredSketch.line(
            width: 24,
            height: 24,
            from: (2, 12),
            to: (22, 12),
            arrowhead: true,
          ),
        ),
      );
      final button = single(body, 'button');

      expect(button.attributes['aria-label'], 'Next page');
      // Every svg inside, including the icon, is hidden from the a11y tree.
      for (final svg in button.querySelectorAll('svg')) {
        expect(svg.attributes['aria-hidden'], 'true');
      }
    });

    testServer('renders identical markup for the same seed', (tester) async {
      Component button() => const WiredButton(
        seed: 8,
        href: '/docs',
        child: Component.text('Docs'),
      );

      expect(
        await renderMarkup(tester, button()),
        await renderMarkup(tester, button()),
      );
    });
  });
}
