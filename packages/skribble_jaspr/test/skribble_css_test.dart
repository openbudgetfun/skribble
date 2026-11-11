import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';

import 'helpers/css.dart';
import 'helpers/render.dart';

void main() {
  group('skribbleCss', () {
    test('declares every theme custom property', () {
      for (final property in [
        '--skribble-ink',
        '--skribble-paper',
        '--skribble-accent',
        '--skribble-on-accent',
        '--skribble-marker',
        '--skribble-on-marker',
        for (var i = 1; i <= 6; i++) '--skribble-wash-$i',
        '--skribble-stroke-width',
        '--skribble-font',
      ]) {
        expect(skribbleCss, contains('$property:'), reason: property);
      }
    });

    test('letters pages in Skribble Noto Sketch first', () {
      expect(
        skribbleCss,
        contains(
          '--skribble-font: "SkribbleNotoSketch", "Skribble Noto Sketch", '
          '"Skribble",',
        ),
      );
    });

    test('switches palettes for dark mode', () {
      expect(skribbleCss, contains('@media (prefers-color-scheme: dark)'));
    });

    test('only moves when the reader has not asked for less motion', () {
      // A reduce block can lose to the motion rules on specificity, so every
      // moving declaration must sit behind no-preference instead.
      final moving = [
        for (final rule in cssRules(skribbleCss))
          if (!rule.atRules.any((at) => at.startsWith('@keyframes')))
            for (final MapEntry(:key, :value) in rule.declarations.entries)
              if (const {
                    'animation',
                    'animation-name',
                    'transition',
                    'transform',
                  }.contains(key) &&
                  value != 'none')
                rule,
      ];

      expect(moving, hasLength(greaterThanOrEqualTo(4)));

      for (final rule in moving) {
        expect(
          rule.atRules,
          contains(contains('(prefers-reduced-motion: no-preference)')),
          reason: rule.selector,
        );
      }
    });

    test('keeps disabled buttons and links still', () {
      for (final rule in cssRules(skribbleCss)) {
        final moves = rule.declarations.keys.any(
          const {'animation', 'animation-name', 'transform'}.contains,
        );

        if (!moves || !rule.selector.contains(RegExp(':hover|:active'))) {
          continue;
        }

        for (final selector in rule.selector.split(',')) {
          expect(
            selector,
            contains(':not(:disabled):not([aria-disabled="true"])'),
            reason: selector,
          );
        }
      }
    });

    test('draws the ink in system colours under forced colours', () {
      final forced = {
        for (final rule in cssRules(skribbleCss))
          if (rule.atRules.contains('@media (forced-colors: active)'))
            rule.selector: rule.declarations,
      };

      expect(
        forced['.skribble-ink-outline,\n  .skribble-highlight .skribble-ink-outline'],
        {'stroke': 'CanvasText'},
      );
      expect(forced['.skribble-button .skribble-ink-outline'], {
        'stroke': 'ButtonText',
      });
      // Forced text over the accent fill would be unreadable.
      expect(forced['.skribble-ink-solid'], {'fill': 'none'});
      expect(
        forced['.skribble-highlight--marker .skribble-ink-solid'],
        containsPair('fill', 'Highlight'),
      );
      expect(
        forced['.skribble-highlight--marker'],
        containsPair('color', 'HighlightText'),
      );
    });

    test('pads boxes with a rule any page style overrides', () {
      expect(ruleFor(skribbleCss, ':where(.skribble-box)'), {
        'padding': '0.75rem 1.25rem',
      });
    });

    test('keeps overlays wider than their box under an svg reset', () {
      final ink = skribbleCss.substring(
        skribbleCss.indexOf('.skribble-ink {'),
        skribbleCss.indexOf('}', skribbleCss.indexOf('.skribble-ink {')),
      );

      expect(ink, contains('max-width: none'));
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
    test('defaults to the sunny colourway', () {
      final root = ruleFor(skribbleCss, ':where(:root)');
      expect(root['--skribble-ink'], '#34283f');
      expect(root['--skribble-accent'], '#ff6b4a');
      expect(root['--skribble-marker'], '#ffd43b');
    });

    test('wash classes colour-code a fill', () {
      for (var i = 1; i <= 6; i++) {
        expect(
          ruleFor(skribbleCss, '.skribble-wash-$i'),
          {'--skribble-fill': 'var(--skribble-wash-$i)'},
        );
      }
    });

    test('draws ink on, pops, and lifts only with motion allowed', () {
      final moving = {
        for (final rule in cssRules(skribbleCss))
          if (rule.selector.contains(
            RegExp(r'skribble-(draw|pop|lift)\b'),
          ))
            rule.selector: rule.atRules,
      };
      expect(moving.keys, contains(contains('.skribble-pop')));
      expect(moving.keys, contains(contains('.skribble-draw')));
      expect(moving.keys, contains(contains('.skribble-lift')));
      for (final MapEntry(:key, :value) in moving.entries) {
        expect(
          value,
          contains(contains('(prefers-reduced-motion: no-preference)')),
          reason: key,
        );
      }
    });

    test('springs with a linear() easing and a cubic fallback', () {
      expect(skribbleCss, contains('animation: skribble-pop 0.72s linear(0,'));
      expect(
        skribbleCss,
        contains('animation: skribble-pop 0.72s cubic-bezier('),
      );
    });
  });
}
