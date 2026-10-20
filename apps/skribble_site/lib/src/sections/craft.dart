import 'package:jaspr/dom.dart' show RawText;
import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:skribble_site/src/assets.dart';
import 'package:skribble_site/src/config.dart';
import 'package:skribble_site/src/html.dart';
import 'package:skribble_site/src/ink.dart';

/// The lettering showcase: a type tester over the bundled families.
class Lettering extends StatelessComponent {
  /// Creates the lettering section for [fonts].
  const Lettering({required this.fonts, super.key});

  /// The families to show.
  final List<LetteringFamily> fonts;

  @override
  Component build(BuildContext context) {
    return pageSection(
      id: 'fonts',
      eyebrow: 'Lettering',
      title: [
        t('Fonts with '),
        const WiredHighlight(
          kind: WiredHighlightKind.marker,
          seed: 5,
          color: 'var(--sun)',
          child: Component.text('handwriting'),
        ),
        t(' built in'),
      ],
      lede: 'Free under the SIL Open Font License. Type something.',
      children: [
        el('div', [
          el('div', [
            el(
              'div',
              [
                for (final (index, font) in fonts.indexed)
                  el(
                    'label',
                    [
                      el('input', const [], 'control', {
                        'type': 'radio',
                        'name': 'font-family',
                        'value': font.family,
                        'data-package': font.package,
                        if (index == 0) 'checked': '',
                      }),
                      el('span', [t(font.label)], 'font-pick-label'),
                      doodle(
                        width: 120,
                        height: 44,
                        stretch: true,
                        classes: 'font-pick-ink',
                        marks: [
                          Mark(
                            roughBox(
                              Pen.playful.generator(
                                300 + index,
                                fill: RoughFillStyle.hachure,
                                gap: 6,
                              ),
                              120,
                              44,
                            ),
                            fill: Tone.sun,
                          ),
                        ],
                      ),
                    ],
                    'font-pick',
                    {'style': '--family:"${font.family}"'},
                  ),
              ],
              'font-picks',
              {'role': 'radiogroup', 'aria-label': 'Font family'},
            ),
            el('div', [
              el('label', [t('Weight')], 'field-label', {'for': 'font-weight'}),
              el('input', const [], 'range', {
                'id': 'font-weight',
                'type': 'range',
                'min': '300',
                'max': '900',
                'step': '100',
                'value': '700',
              }),
              el('output', [t('700')], 'slider-value', {'for': 'font-weight'}),
            ], 'font-weight'),
          ], 'font-controls'),
          WiredCard(
            seed: 310,
            classes: 'specimen',
            child: Component.fragment([
              el(
                'p',
                [
                  t('The quick brown fox sketches over the lazy dog.'),
                ],
                'specimen-text',
                {
                  'contenteditable': 'true',
                  'spellcheck': 'false',
                  'role': 'textbox',
                  'aria-label': 'Type to try the font',
                  'aria-multiline': 'true',
                },
              ),
              el('p', [
                t('Aa Bb Cc Dd Ee Ff Gg 0123456789 & ? ! @ ( )'),
              ], 'specimen-glyphs'),
            ]),
          ),
        ], 'font-lab reveal'),
        el('div', [
          anchor(
            SiteLinks.fontSource,
            [t('Download the font files')],
          ),
          el(
            'code',
            [t('flutter pub add ${fonts.first.package}')],
            null,
            {
              'data-font-install': '',
              'aria-live': 'polite',
            },
          ),
          anchor('fonts/${licenceFile(recursivePackage)}', [
            t('Recursive licence'),
          ]),
          if (fonts.any((font) => font.package != recursivePackage))
            anchor('fonts/${licenceFile('skribble_font_noto')}', [
              t('Noto licence'),
            ]),
        ], 'section-actions'),
      ],
    );
  }
}

/// A wall of emoji and rough icons, both drawn in skribble's hand.
class ArtWall extends StatelessComponent {
  /// Creates the wall from [assets].
  const ArtWall({required this.assets, super.key});

  /// The emoji and icons to show.
  final SiteAssets assets;

  @override
  Component build(BuildContext context) {
    return pageSection(
      id: 'art',
      eyebrow: 'Icons and emoji',
      title: [t('A whole sketchbook of artwork')],
      lede:
          '${_count(assets.emojiCount)} emoji. '
          '${_count(assets.iconCount)} icons. All hand-drawn.',
      children: [
        el('ul', [
          for (final (index, art) in assets.emoji.indexed)
            el(
              'li',
              [
                el('img', const [], null, {
                  'src': art.path,
                  'alt': art.label,
                  'width': '72',
                  'height': '72',
                  'loading': 'lazy',
                  'decoding': 'async',
                }),
              ],
              'emoji',
              {'style': '--d:${index % 7}'},
            ),
        ], 'emoji-wall reveal'),
        el('ul', [
          for (final icon in assets.icons)
            el('li', [
              RawText(_iconSvg(icon)),
              el('span', [t(icon.name)]),
            ], 'icon'),
        ], 'icon-wall reveal'),
        el('div', [
          anchor('docs/widgets/emoji', [t('Emoji guide')]),
          anchor('docs/widgets/icons', [t('Icon catalogs')]),
        ], 'section-actions'),
      ],
    );
  }

  static String _iconSvg(IconArt icon) {
    final size = icon.size == icon.size.roundToDouble()
        ? '${icon.size.toInt()}'
        : '${icon.size}';
    final paths = [
      for (final d in icon.paths) '<path d="$d"/>',
    ].join();

    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $size $size" '
        'width="40" height="40" fill="none" stroke="currentColor" '
        'stroke-width="2" stroke-linecap="round" stroke-linejoin="round" '
        'aria-hidden="true" focusable="false">$paths</svg>';
  }

  static String _count(int value) {
    final digits = '$value';
    final out = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }

    return out.toString();
  }
}

/// The minimal app, with the code on one side and what it buys on the other.
class CodeSample extends StatelessComponent {
  /// Creates the code sample.
  const CodeSample({super.key});

  static const List<List<(String, String)>> _code = [
    [('k', 'import'), ('s', " 'package:flutter/widgets.dart'"), ('p', ';')],
    [('k', 'import'), ('s', " 'package:skribble/skribble.dart'"), ('p', ';')],
    [],
    [('k', 'void'), ('f', ' main'), ('p', '() {')],
    [('f', '  runApp'), ('p', '(')],
    [('t', '    SkribbleApp'), ('p', '(')],
    [('a', '      title'), ('p', ': '), ('s', "'My sketchy app'"), ('p', ',')],
    [('a', '      home'), ('p', ': '), ('t', 'WiredScaffold'), ('p', '(')],
    [
      ('a', '        appBar'),
      ('p', ': '),
      ('t', 'WiredAppBar'),
      ('p', '(title: '),
      ('t', 'Text'),
      ('p', '('),
      ('s', "'Hello'"),
      ('p', ')),'),
    ],
    [
      ('a', '        body'),
      ('p', ': '),
      ('t', 'Center'),
      ('p', '(child: '),
      ('t', 'WiredButton'),
      ('p', '('),
    ],
    [('a', '          onPressed'), ('p', ': () {},')],
    [
      ('a', '          child'),
      ('p', ': '),
      ('t', 'Text'),
      ('p', '('),
      ('s', "'Press me'"),
      ('p', '),'),
    ],
    [('p', '        )),')],
    [('p', '      ),')],
    [('p', '    ),')],
    [('p', '  );')],
    [('p', '}')],
  ];

  @override
  Component build(BuildContext context) {
    return pageSection(
      id: 'code',
      eyebrow: 'Start in minutes',
      title: [t('A whole app in a handful of lines')],
      children: [
        el('div', [
          WiredCard(
            seed: 410,
            classes: 'code-card',
            child: el(
              'pre',
              [
                el('code', [
                  for (final line in _code)
                    el('span', [
                      for (final (kind, text) in line)
                        el('span', [t(text)], 'tok-$kind'),
                      t('\n'),
                    ], 'code-line'),
                ]),
              ],
              null,
              {'aria-label': 'main.dart', 'tabindex': '0'},
            ),
          ),
          const _AppPreview(),
        ], 'code-grid'),
        el('div', [
          WiredButton(
            href: SiteLinks.quickStart,
            seed: 430,
            child: t('Follow the quick start'),
          ),
          anchor(SiteLinks.pub, [t('skribble on pub.dev')]),
        ], 'section-actions'),
      ],
    );
  }
}

/// What the code sample draws: an app bar and a button on sketch paper.
class _AppPreview extends StatelessComponent {
  const _AppPreview();

  @override
  Component build(BuildContext context) {
    return el('figure', [
      WiredCard(
        seed: 415,
        classes: 'app-preview',
        child: Component.fragment([
          el('div', [
            t('Hello'),
            doodle(
              width: 300,
              height: 10,
              stretch: true,
              classes: 'app-preview-rule',
              marks: [
                Mark(
                  roughCurve(Pen.playful.generator(416), [
                    (2, 5),
                    (150, 6),
                    (298, 4),
                  ]),
                ),
              ],
            ),
          ], 'app-preview-bar'),
          el('div', [
            WiredButton(seed: 417, child: t('Press me')),
          ], 'app-preview-body'),
        ]),
      ),
      el('figcaption', [t('What it draws')]),
    ], 'app-preview-figure reveal');
  }
}

/// Where skribble goes beyond Flutter: this page, design files, and the
/// engine itself.
class BeyondFlutter extends StatelessComponent {
  /// Creates the section.
  const BeyondFlutter({super.key});

  @override
  Component build(BuildContext context) {
    final cards = [
      (
        'This page',
        'Drawn on the server with skribble_jaspr.',
        SiteLinks.jaspr,
        'Build with Jaspr',
        Tone.coral,
      ),
      (
        'skribble_rough',
        'Seeded SVG anywhere Dart runs.',
        SiteLinks.roughEngine,
        'Meet the engine',
        Tone.mint,
      ),
      (
        'Figma kit',
        'Every widget, ready to remix.',
        SiteLinks.designKit,
        'Open the design kit',
        Tone.lilac,
      ),
    ];

    return pageSection(
      id: 'beyond',
      eyebrow: 'Beyond Flutter',
      title: [t('The same hand, everywhere')],
      children: [
        el('div', [
          for (final (index, (title, body, href, action, tone))
              in cards.indexed)
            WiredCard(
              seed: 500 + index,
              fillStyle: RoughFillStyle.hachure,
              fill: tone.paint,
              classes: 'beyond-card skribble-wobble reveal',
              child: Component.fragment([
                el('h3', [t(title)]),
                para(body),
                anchor(href, [t(action)], classes: 'arrow-link'),
              ]),
            ),
        ], 'beyond-grid'),
      ],
    );
  }
}

/// The closing call to action.
class Closing extends StatelessComponent {
  /// Creates the closing section.
  const Closing({super.key});

  @override
  Component build(BuildContext context) {
    return el(
      'section',
      [
        doodle(
          width: 900,
          height: 300,
          stretch: true,
          classes: 'closing-ink',
          marks: [
            Mark(
              roughBox(
                Pen.expressive.generator(
                  600,
                  fill: RoughFillStyle.hachure,
                  gap: 14,
                ),
                900,
                300,
                inset: 8,
              ),
              fill: Tone.sun,
              width: 2.6,
              fillWidth: 2.2,
            ),
          ],
        ),
        el('h2', [t('Grab a pen.')], null, {'id': 'closing-title'}),
        el('div', [
          WiredButton(
            href: SiteLinks.install,
            seed: 610,
            child: t('Install skribble'),
          ),
          WiredButton(
            href: SiteLinks.github,
            seed: 611,
            variant: WiredButtonVariant.secondary,
            child: t('Star on GitHub'),
          ),
        ], 'hero-actions'),
      ],
      'closing draw reveal',
      {'aria-labelledby': 'closing-title'},
    );
  }
}
