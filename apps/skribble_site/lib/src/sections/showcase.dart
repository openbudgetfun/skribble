import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart';
import 'package:skribble_site/src/config.dart';
import 'package:skribble_site/src/controls.dart';
import 'package:skribble_site/src/html.dart';
import 'package:skribble_site/src/ink.dart';

/// A slow, endless strip of widget names.
class Marquee extends StatelessComponent {
  /// Creates the marquee.
  const Marquee({super.key});

  static const _names = [
    'WiredButton',
    'WiredSwitch',
    'WiredSlider',
    'WiredCalendar',
    'WiredTabBar',
    'WiredDataTable',
    'WiredStepper',
    'WiredColorPicker',
    'WiredNavigationRail',
    'WiredTooltip',
    'WiredSearchBar',
    'WiredExpansionTile',
    'WiredSkeleton',
    'WiredDoodle',
    'WiredTimePicker',
    'WiredBottomSheet',
  ];

  @override
  Component build(BuildContext context) {
    Component strip({required bool hidden}) => el(
      'ul',
      [
        for (final (index, name) in _names.indexed)
          el('li', [
            t(name),
            doodle(
              width: 22,
              height: 22,
              marks: [
                Mark(
                  roughStar(
                    Pen.playful.generator(
                      index + 100,
                      fill: RoughFillStyle.solid,
                    ),
                    11,
                    11,
                    9,
                  ),
                  fill: index.isEven ? Tone.sun : Tone.coral,
                  width: 1.4,
                ),
              ],
            ),
          ]),
      ],
      'marquee-strip',
      {if (hidden) 'aria-hidden': 'true'},
    );

    return el(
      'div',
      [strip(hidden: false), strip(hidden: true)],
      'marquee',
      {'aria-label': 'A few of the Wired widgets', 'role': 'region'},
    );
  }
}

/// Six fill styles, each pre-drawn from three seeds, with a shuffle button.
class FillGallery extends StatelessComponent {
  /// Creates the fill gallery.
  const FillGallery({super.key});

  static const _seeds = [7, 23, 58];

  static final _fills = <(String, RoughFillStyle, Tone, _Shape)>[
    ('hachure', RoughFillStyle.hachure, Tone.coral, _Shape.box),
    ('crossHatch', RoughFillStyle.crossHatch, Tone.lilac, _Shape.oval),
    ('zigzag', RoughFillStyle.zigzag, Tone.mint, _Shape.star),
    ('dashed', RoughFillStyle.dashed, Tone.sky, _Shape.heart),
    ('dots', RoughFillStyle.dots, Tone.pink, _Shape.blob),
    ('solid', RoughFillStyle.solid, Tone.sun, _Shape.cloud),
  ];

  @override
  Component build(BuildContext context) {
    return pageSection(
      id: 'ink',
      eyebrow: 'The rough engine',
      title: [
        t('Every line is '),
        const WiredHighlight(
          seed: 9,
          color: 'var(--coral)',
          child: Component.text('hand-drawn'),
        ),
      ],
      lede: 'Same seed, same sketch. New seed, new hand.',
      children: [
        el(
          'div',
          [
            for (final (index, (name, style, tone, shape)) in _fills.indexed)
              el(
                'figure',
                [
                  el('div', [
                    for (final (seedIndex, seed) in _seeds.indexed)
                      doodle(
                        width: 220,
                        height: 150,
                        classes: 'seed seed--$seedIndex',
                        marks: [
                          Mark(
                            shape.draw(
                              Pen.playful.generator(
                                seed + index,
                                fill: style,
                                gap: style == RoughFillStyle.dots ? 15 : 8,
                              ),
                            ),
                            fill: tone,
                            width: 2.2,
                            fillWidth: style == RoughFillStyle.dots ? 2.4 : 1.6,
                          ),
                        ],
                      ),
                  ], 'fill-art'),
                  el('figcaption', [
                    el('code', [t('RoughFillStyle.$name')]),
                    el('span', [
                      for (final (seedIndex, seed) in _seeds.indexed)
                        el('span', [
                          t('seed ${seed + index}'),
                        ], 'seed seed--$seedIndex'),
                    ], 'fill-seed'),
                  ]),
                ],
                'fill-card reveal',
                {'style': '--d:$index'},
              ),
          ],
          'fill-grid',
          {'data-seed': '0'},
        ),
        el('div', [
          WiredButton(
            variant: WiredButtonVariant.secondary,
            seed: 30,
            classes: 'shuffle',
            attributes: const {'data-shuffle': ''},
            child: t('Shuffle the seeds'),
          ),
          anchor(SiteLinks.roughEngine, [t('How the rough engine works')]),
        ], 'section-actions'),
      ],
    );
  }
}

enum _Shape {
  box,
  oval,
  star,
  heart,
  blob,
  cloud;

  Drawable draw(Generator g) => switch (this) {
    _Shape.box => g.rectangle(30, 22, 160, 106),
    _Shape.oval => g.ellipse(110, 75, 170, 116),
    _Shape.star => roughStar(g, 110, 78, 68),
    _Shape.heart => g.polygon([
      for (final (x, y) in const [
        (110, 140),
        (40, 82),
        (34, 46),
        (58, 18),
        (90, 18),
        (110, 42),
        (130, 18),
        (162, 18),
        (186, 46),
        (180, 82),
      ])
        PointD(x.toDouble(), y.toDouble()),
    ]),
    _Shape.blob => g.polygon([
      for (final (x, y) in const [
        (40, 40),
        (100, 16),
        (170, 30),
        (196, 80),
        (160, 130),
        (90, 134),
        (30, 104),
      ])
        PointD(x.toDouble(), y.toDouble()),
    ]),
    _Shape.cloud => g.roundedRectangle(24, 34, 172, 86, 40, 40, 40, 40),
  };
}

/// The three pens side by side, each drawing the same little form.
class PenComparison extends StatelessComponent {
  /// Creates the comparison.
  const PenComparison({super.key});

  @override
  Component build(BuildContext context) {
    return pageSection(
      id: 'pens',
      eyebrow: 'Themes',
      title: [t('Three pens, one design system')],
      lede: 'One setting redraws the whole app.',
      children: [
        el('div', [
          for (final (index, pen) in Pen.values.indexed)
            el(
              'article',
              [
                doodle(
                  width: 320,
                  height: 300,
                  stretch: true,
                  classes: 'pen-card-frame',
                  marks: [Mark(roughBox(pen.generator(140 + index), 320, 300))],
                ),
                el('h3', [t(_title(pen))]),
                el('div', [
                  el('span', [
                    doodle(
                      width: 150,
                      height: 46,
                      stretch: true,
                      marks: [
                        Mark(
                          roughBox(
                            pen.generator(
                              150 + index,
                              fill: RoughFillStyle.solid,
                            ),
                            150,
                            46,
                          ),
                        ),
                      ],
                    ),
                    t('Save sketch'),
                  ], 'pen-demo-button'),
                  el('span', [
                    doodle(
                      width: 26,
                      height: 26,
                      marks: [
                        Mark(roughBox(pen.generator(160 + index), 26, 26)),
                        Mark(
                          roughCurve(pen.generator(170 + index), [
                            (5, 14),
                            (11, 21),
                            (23, 4),
                          ]),
                          stroke: Tone.coral,
                          width: 3,
                        ),
                      ],
                    ),
                    t('Remember me'),
                  ], 'pen-demo-check'),
                  doodle(
                    width: 260,
                    height: 18,
                    stretch: true,
                    classes: 'pen-demo-wave',
                    marks: [
                      Mark(
                        roughSquiggle(
                          pen.generator(180 + index),
                          260,
                          18,
                          loops: 6,
                        ),
                        stroke: Tone.lilac,
                        width: 2.4,
                      ),
                    ],
                  ),
                ], 'pen-demo'),
                el('dl', [
                  el('dt', [t('roughness')]),
                  el('dd', [t('${pen.roughness}')]),
                  el('dt', [t('wobble')]),
                  el('dd', [t('${pen.lineWobble}')]),
                ], 'pen-stats'),
              ],
              'pen-card pen-card--${pen.name} reveal draw',
              {'style': '--d:$index'},
            ),
        ], 'pen-grid'),
        el('div', [
          anchor(SiteLinks.theming, [t('Theme your app')]),
        ], 'section-actions'),
      ],
    );
  }

  static String _title(Pen pen) =>
      '${pen.name[0].toUpperCase()}${pen.name.substring(1)}';
}

/// A grid of working controls, each named after its Wired widget.
class Playground extends StatelessComponent {
  /// Creates the playground.
  const Playground({super.key});

  @override
  Component build(BuildContext context) {
    Component card(
      int seed,
      String widget,
      String href,
      List<Component> demo, {
      String? classes,
    }) {
      return WiredCard(
        seed: seed,
        classes: ['play-card reveal', ?classes].join(' '),
        child: Component.fragment([
          el('div', [
            el('h3', [
              el('code', [t(widget)]),
            ]),
            anchor(
              href,
              [t('Docs')],
              classes: 'play-docs',
              attributes: {
                'aria-label': '$widget documentation',
              },
            ),
          ], 'play-head'),
          el('div', demo, 'play-demo'),
        ]),
      );
    }

    return pageSection(
      id: 'widgets',
      eyebrow: 'Widgets',
      title: [
        t('Touch the '),
        const WiredHighlight(
          kind: WiredHighlightKind.circle,
          seed: 14,
          color: 'var(--coral)',
          child: Component.text('ink'),
        ),
      ],
      lede: 'Real inputs. Go on, poke them.',
      children: [
        el('div', [
          card(201, 'WiredCheckbox', 'docs/widgets/selection', [
            sketchCheckbox('Bring snacks', seed: 210, checked: true),
            sketchCheckbox('Pack the sketchbook', seed: 211),
            sketchCheckbox('Charge the pencil', seed: 212),
          ]),
          card(202, 'WiredSwitch', 'docs/widgets/selection', [
            sketchSwitch('Notifications', seed: 220, checked: true),
            sketchSwitch('Reduce motion', seed: 222),
          ]),
          card(203, 'WiredRadio', 'docs/widgets/selection', [
            for (final (index, size) in ['Small', 'Medium', 'Large'].indexed)
              sketchRadio(
                size,
                name: 'cup',
                seed: 230 + index * 3,
                checked: index == 1,
              ),
          ]),
          card(204, 'WiredFilterChip', 'docs/widgets/selection', [
            el('div', [
              sketchChip('Ink', seed: 240, checked: true),
              sketchChip('Paper', seed: 242),
              sketchChip('Doodles', seed: 244, checked: true),
              sketchChip('Crayons', seed: 246),
            ], 'chip-row'),
          ]),
          card(205, 'WiredInput', 'docs/widgets/inputs', [
            sketchField(
              'Name your sketchbook',
              id: 'play-name',
              seed: 250,
              placeholder: 'Rainy day ideas',
            ),
          ]),
          card(206, 'WiredSlider', 'docs/widgets/inputs', [
            sketchSlider('Ink level', id: 'play-ink', seed: 260),
          ]),
          card(207, 'WiredProgress', 'docs/widgets/loading', [
            el(
              'div',
              [
                doodle(
                  width: 260,
                  height: 26,
                  stretch: true,
                  marks: [
                    Mark(
                      roughBox(
                        Pen.playful.generator(
                          270,
                          fill: RoughFillStyle.hachure,
                          gap: 6,
                        ),
                        260,
                        26,
                      ),
                      fill: Tone.sky,
                      classes: 'progress-fill',
                    ),
                    Mark(roughBox(Pen.playful.generator(271), 260, 26)),
                  ],
                ),
              ],
              'progress',
              {
                'role': 'progressbar',
                'aria-label': 'Uploading doodles',
              },
            ),
            para('Uploading doodles…', classes: 'muted'),
          ]),
          card(208, 'WiredTabBar', 'docs/widgets/navigation', [
            const _Tabs(),
          ]),
          card(209, 'WiredButton', 'docs/widgets/buttons', [
            el('div', [
              WiredButton(seed: 290, child: t('Primary')),
              WiredButton(
                seed: 291,
                variant: WiredButtonVariant.secondary,
                child: t('Outline'),
              ),
            ], 'button-row'),
          ]),
        ], 'play-grid'),
        el('div', [
          WiredButton(
            href: SiteLinks.storybook,
            seed: 299,
            child: t('Open the full storybook'),
          ),
          anchor(SiteLinks.widgets, [t('Browse the widget catalog')]),
        ], 'section-actions'),
      ],
    );
  }
}

/// Radio-driven tabs: the selected tab's panel shows, with no JavaScript.
class _Tabs extends StatelessComponent {
  const _Tabs();

  static const _tabs = [
    ('Sketch', 'Rough out the idea with a pencil.'),
    ('Ink', 'Trace the keepers with a pen.'),
    ('Colour', 'Wash in marker and hatching.'),
  ];

  @override
  Component build(BuildContext context) {
    return el('div', [
      el(
        'div',
        [
          for (final (index, (name, _)) in _tabs.indexed)
            el('label', [
              el('input', const [], 'control', {
                'type': 'radio',
                'name': 'stage',
                'value': name,
                if (index == 0) 'checked': '',
              }),
              el('span', [t(name)], 'tab-label'),
              doodle(
                width: 80,
                height: 12,
                stretch: true,
                classes: 'tab-underline',
                marks: [
                  Mark(
                    roughCurve(Pen.playful.generator(280 + index), [
                      (3, 7),
                      (40, 5),
                      (77, 7),
                    ]),
                    stroke: Tone.coral,
                    width: 3,
                  ),
                ],
              ),
            ], 'tab'),
        ],
        'tab-list',
        {'role': 'radiogroup', 'aria-label': 'Drawing stage'},
      ),
      el(
        'div',
        [
          for (final (_, copy) in _tabs) para(copy, classes: 'tab-panel'),
        ],
        'tab-panels',
        {'aria-live': 'polite'},
      ),
    ], 'tabs');
  }
}
