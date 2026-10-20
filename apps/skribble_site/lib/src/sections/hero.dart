import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart';

import 'package:skribble_site/src/config.dart';
import 'package:skribble_site/src/controls.dart';
import 'package:skribble_site/src/html.dart';
import 'package:skribble_site/src/ink.dart';

/// The opening section: the pitch, the install command, and a live phone
/// drawn entirely from server-rendered ink.
class Hero extends StatelessComponent {
  /// Creates the hero.
  const Hero({super.key});

  @override
  Component build(BuildContext context) {
    return el(
      'section',
      [
        el('div', [
          el('p', [t('A hand-drawn design system for Flutter')], 'eyebrow'),
          el(
            'h1',
            [
              t('Ship apps that look '),
              el('span', [
                doodle(
                  width: 420,
                  height: 90,
                  stretch: true,
                  classes: 'hero-marker',
                  marks: [
                    Mark(
                      Pen.expressive
                          .generator(11, fill: RoughFillStyle.solid)
                          .polygon([
                            PointD(6, 22),
                            PointD(414, 14),
                            PointD(410, 76),
                            PointD(12, 82),
                          ]),
                      stroke: Tone.paper,
                      fill: Tone.sun,
                      width: 0,
                    ),
                  ],
                ),
                t('drawn by hand'),
                doodle(
                  width: 420,
                  height: 24,
                  stretch: true,
                  classes: 'hero-underline',
                  marks: [
                    Mark(
                      roughCurve(Pen.expressive.generator(4), [
                        (6, 16),
                        (120, 9),
                        (260, 14),
                        (414, 6),
                      ]),
                      stroke: Tone.coral,
                      width: 4,
                    ),
                  ],
                ),
              ], 'hero-highlight'),
              t('.'),
            ],
            'hero-title',
            {'id': 'hero-title'},
          ),
          para(
            'Every border, fill, icon, and letter, drawn by a seeded pen.',
            classes: 'hero-lede',
          ),
          el('div', [
            WiredButton(
              href: SiteLinks.install,
              seed: 7,
              child: t('Get started'),
            ),
            WiredButton(
              href: SiteLinks.storybook,
              variant: WiredButtonVariant.secondary,
              seed: 12,
              child: t('Play with every widget'),
            ),
          ], 'hero-actions'),
          const InstallCommand(),
        ], 'hero-copy'),
        el('div', [
          const Phone(),
          el('p', [
            doodle(
              width: 120,
              height: 70,
              classes: 'hero-note-arrow draw',
              marks: [
                for (final arrow in roughArrow(Pen.playful.generator(5), [
                  (110, 10),
                  (70, 18),
                  (38, 40),
                  (14, 62),
                ]))
                  Mark(arrow, width: 2.2),
              ],
            ),
            t('Tap it. Then drag the pen.'),
          ], 'hero-note'),
        ], 'hero-stage'),
      ],
      'hero',
      {'aria-labelledby': 'hero-title'},
    );
  }
}

/// `flutter pub add skribble` with a copy button.
///
/// The button is enhanced by `site.js`; without JavaScript the command is
/// still selectable text.
class InstallCommand extends StatelessComponent {
  /// Creates the install command.
  const InstallCommand({super.key});

  @override
  Component build(BuildContext context) {
    return WiredBox(
      seed: 21,
      classes: 'install',
      child: Component.fragment([
        el('span', [t(r'$')], 'install-prompt', {'aria-hidden': 'true'}),
        el('code', [t('flutter pub add skribble')], 'install-code'),
        el(
          'button',
          [t('Copy')],
          'install-copy',
          {
            'type': 'button',
            'data-copy': 'flutter pub add skribble',
            'aria-label': 'Copy the install command',
          },
        ),
      ]),
    );
  }
}

/// A phone-sized sketch of a to-do app made of real, working form controls.
///
/// Checkboxes, the switch, and the radio-free pen slider need no JavaScript
/// to look right; `site.js` only wires the slider to the phone's `data-pen`.
class Phone extends StatelessComponent {
  /// Creates the phone.
  const Phone({super.key});

  static const _tasks = [
    ('Sketch the onboarding', true, 31),
    ('Water the cactus', false, 32),
    ('Call grandma back', false, 33),
  ];

  @override
  Component build(BuildContext context) {
    return el(
      'div',
      [
        penDoodle(
          width: 320,
          height: 640,
          stretch: true,
          classes: 'phone-frame',
          marks: (pen) {
            final g = pen.generator(3);

            return [
              Mark(
                g.roundedRectangle(6, 6, 308, 628, 38, 38, 38, 38),
                width: 2.6,
              ),
              Mark(g.line(128, 24, 192, 24), width: 4),
            ];
          },
        ),
        el('div', [
          el('div', [
            el('span', [t('9:41')]),
            el('span', [t('● ● ●')], null, {'aria-hidden': 'true'}),
          ], 'phone-status'),
          el('div', [
            penDoodle(
              width: 284,
              height: 60,
              stretch: true,
              marks: (pen) => [
                Mark(
                  roughBox(
                    pen.generator(8, fill: RoughFillStyle.hachure, gap: 7),
                    284,
                    60,
                  ),
                  fill: Tone.lilac,
                ),
              ],
            ),
            el('span', [t('My sketchbook')], 'phone-title'),
          ], 'phone-bar'),
          el('ul', [
            for (final (label, done, seed) in _tasks)
              el('li', [
                sketchCheckbox(
                  label,
                  seed: seed,
                  checked: done,
                  strike: true,
                  pens: Pen.values,
                ),
              ]),
          ], 'phone-tasks'),
          sketchSwitch(
            'Flip the paper',
            seed: 41,
            pens: Pen.values,
            classes: 'phone-row phone-dark',
          ),
          el('div', [
            el('label', [t('Pen')], 'row-label', {'for': 'hero-pen'}),
            el('div', [
              penDoodle(
                width: 200,
                height: 20,
                stretch: true,
                classes: 'slider-track',
                marks: (pen) => [
                  Mark(
                    roughCurve(pen.generator(51), [
                      (4, 11),
                      (100, 9),
                      (196, 11),
                    ]),
                  ),
                ],
              ),
              el('input', const [], 'pen-slider', {
                'id': 'hero-pen',
                'type': 'range',
                'min': '0',
                'max': '2',
                'step': '1',
                'value': '1',
                'aria-valuetext': 'Playful',
              }),
            ], 'slider'),
            el('output', [t('Playful')], 'pen-name', {'for': 'hero-pen'}),
          ], 'phone-row phone-row--slider'),
          el('div', [
            penDoodle(
              width: 284,
              height: 92,
              stretch: true,
              marks: (pen) => [
                Mark(roughBox(pen.generator(61), 284, 92)),
              ],
            ),
            el('p', [t('Weekly streak')], 'streak-title'),
            el(
              'div',
              [
                penDoodle(
                  width: 248,
                  height: 22,
                  stretch: true,
                  marks: (pen) => [
                    Mark(
                      roughBox(
                        pen.generator(71, fill: RoughFillStyle.hachure, gap: 5),
                        170,
                        22,
                      ),
                      classes: 'streak-fill',
                    ),
                    Mark(roughBox(pen.generator(72), 248, 22)),
                  ],
                ),
              ],
              'streak-bar',
              {
                'role': 'img',
                'aria-label': 'Five of seven days done',
              },
            ),
          ], 'phone-card'),
          el(
            'span',
            [
              penDoodle(
                width: 60,
                height: 60,
                marks: (pen) => [
                  Mark(
                    roughOval(
                      pen.generator(81, fill: RoughFillStyle.solid),
                      60,
                      60,
                    ),
                  ),
                  Mark(pen.generator(82).line(30, 18, 30, 42), width: 3),
                  Mark(pen.generator(83).line(18, 30, 42, 30), width: 3),
                ],
              ),
            ],
            'phone-fab',
            {'aria-hidden': 'true'},
          ),
        ], 'phone-screen'),
      ],
      'phone draw',
      {
        'data-pen': 'playful',
        'role': 'group',
        'aria-label': 'Sketched to-do app',
      },
    );
  }
}
