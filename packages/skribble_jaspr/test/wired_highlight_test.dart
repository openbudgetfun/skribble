import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';

import 'helpers/render.dart';

void main() {
  group('WiredHighlight', () {
    testServer('renders every kind as an inline span', (tester) async {
      for (final kind in WiredHighlightKind.values) {
        final body = await renderBody(
          tester,
          WiredHighlight(kind: kind, child: const Component.text('word')),
        );
        final span = single(body, '.skribble-highlight');

        expect(span.localName, 'span', reason: kind.name);
        expect(
          span.classes,
          contains('skribble-highlight--${kind.name}'),
          reason: kind.name,
        );
        expect(span.text, 'word', reason: kind.name);
        expectInkOverlay(single(span, 'svg'));
      }
    });

    testServer('draws pen kinds as outlines', (tester) async {
      for (final kind in [
        WiredHighlightKind.underline,
        WiredHighlightKind.circle,
        WiredHighlightKind.strikethrough,
        WiredHighlightKind.box,
      ]) {
        final body = await renderBody(
          tester,
          WiredHighlight(kind: kind, child: const Component.text('word')),
        );

        expect(
          body.querySelectorAll('.skribble-ink-outline'),
          hasLength(1),
          reason: kind.name,
        );
        expect(body.querySelectorAll('.skribble-ink-solid'), isEmpty);
      }
    });

    testServer('draws the marker as a solid swipe without an outline', (
      tester,
    ) async {
      final body = await renderBody(
        tester,
        const WiredHighlight(
          kind: WiredHighlightKind.marker,
          child: Component.text('word'),
        ),
      );

      expect(body.querySelectorAll('.skribble-ink-solid'), hasLength(1));
      expect(body.querySelectorAll('.skribble-ink-outline'), isEmpty);
    });

    testServer('exposes the colour as a custom property', (tester) async {
      final body = await renderBody(
        tester,
        const WiredHighlight(color: '#e8590c', child: Component.text('word')),
      );

      expect(
        single(body, '.skribble-highlight').attributes['style'],
        '--skribble-highlight: #e8590c',
      );
    });

    testServer('keeps semantic children intact', (tester) async {
      final body = await renderBody(
        tester,
        const Component.element(
          tag: 'p',
          children: [
            Component.text('Draw it '),
            WiredHighlight(
              kind: WiredHighlightKind.circle,
              child: Component.element(
                tag: 'em',
                children: [Component.text('differently')],
              ),
            ),
          ],
        ),
      );

      expect(single(body, 'p').text.trim(), 'Draw it differently');
      expect(single(body, '.skribble-highlight em').text, 'differently');
    });

    testServer('renders identical markup for the same seed', (tester) async {
      Component highlight() => const WiredHighlight(
        seed: 5,
        kind: WiredHighlightKind.circle,
        child: Component.text('same'),
      );

      expect(
        await renderMarkup(tester, highlight()),
        await renderMarkup(tester, highlight()),
      );
    });
  });

  group('WiredDivider', () {
    testServer('renders an accessible separator', (tester) async {
      final body = await renderBody(
        tester,
        const WiredDivider(classes: 'wide'),
      );
      final divider = single(body, '.skribble-divider');

      expect(divider.localName, 'div');
      expect(divider.attributes['role'], 'separator');
      expect(divider.attributes['aria-orientation'], 'horizontal');
      expect(divider.classes, contains('wide'));
      expectInkOverlay(single(divider, 'svg'));
      expect(divider.querySelectorAll('.skribble-ink-outline'), hasLength(1));
    });

    testServer('replays the same line from a seed', (tester) async {
      final first = await renderMarkup(tester, const WiredDivider(seed: 4));
      final second = await renderMarkup(tester, const WiredDivider(seed: 4));
      final other = await renderMarkup(tester, const WiredDivider(seed: 5));

      expect(first, second);
      expect(first, isNot(other));
    });
  });
}
