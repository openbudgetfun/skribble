import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';

import 'helpers/render.dart';

void main() {
  group('skribbleCss', () {
    test('declares every theme custom property', () {
      for (final property in [
        '--skribble-ink',
        '--skribble-paper',
        '--skribble-accent',
        '--skribble-on-accent',
        '--skribble-stroke-width',
        '--skribble-font',
      ]) {
        expect(skribbleCss, contains('$property:'), reason: property);
      }
    });

    test('switches palettes for dark mode', () {
      expect(skribbleCss, contains('@media (prefers-color-scheme: dark)'));
    });

    test('turns motion off when the reader asks for less', () {
      final reduced = skribbleCss.substring(
        skribbleCss.indexOf('@media (prefers-reduced-motion: reduce)'),
      );

      expect(reduced, contains('animation: none'));
      expect(reduced, contains('transform: none'));
      expect(reduced, contains('transition: none'));
    });

    test('draws a visible keyboard focus ring', () {
      expect(skribbleCss, contains('.skribble-button:focus-visible'));
      expect(skribbleCss, contains('outline: 2px dashed'));
    });

    test('styles every class the components render', () {
      for (final selector in [
        '.skribble-box',
        '.skribble-ink',
        '.skribble-ink-outline',
        '.skribble-ink-hatch',
        '.skribble-ink-solid',
        '.skribble-card',
        '.skribble-circle',
        '.skribble-button',
        '.skribble-wobble',
        '.skribble-divider',
        '.skribble-sketch',
        for (final kind in WiredHighlightKind.values)
          '.skribble-highlight--${kind.name}',
      ]) {
        expect(skribbleCss, contains(selector), reason: selector);
      }
    });

    test('has balanced braces', () {
      expect(
        '{'.allMatches(skribbleCss).length,
        '}'.allMatches(skribbleCss).length,
      );
    });

    testServer('can be inlined in a style element unchanged', (tester) async {
      final body = await renderBody(
        tester,
        const Component.element(tag: 'style', children: [RawText(skribbleCss)]),
      );

      // The server re-indents raw text, so compare the CSS token stream.
      String tokens(String css) => css.split(RegExp(r'\s+')).join(' ').trim();

      expect(tokens(single(body, 'style').text), tokens(skribbleCss));
    });
  });
}
