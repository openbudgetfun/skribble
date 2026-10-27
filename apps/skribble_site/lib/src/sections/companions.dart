import 'dart:math' as math;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/skribble_jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart';
import 'package:skribble_site/src/config.dart';
import 'package:skribble_site/src/html.dart';
import 'package:skribble_site/src/ink.dart';

/// The companion packages: a candlestick chart from `skribble_charts` and a
/// map with hand-drawn overlays from `skribble_maps`.
///
/// Both are drawings of what the Flutter widgets render, made with the same
/// pens as the rest of the page. The live widgets are in the docs.
class ChartsAndMaps extends StatelessComponent {
  /// Creates the section.
  const ChartsAndMaps({super.key});

  @override
  Component build(BuildContext context) {
    return pageSection(
      id: 'charts-maps',
      eyebrow: 'Charts and maps',
      title: [
        t('Your data, '),
        const WiredHighlight(
          seed: 31,
          color: 'var(--mint)',
          child: Component.text('in ink'),
        ),
      ],
      lede: 'Two companion packages draw charts and maps with the same pen.',
      children: [
        el('div', [
          _card(
            seed: 320,
            widget: 'WiredFinancialChart',
            package: 'skribble_charts',
            href: SiteLinks.charts,
            art: const _CandleChart(),
            caption:
                'Candles, volume, a moving average, and a marked price. '
                'Bodies span open to close; wicks reach the exact high and '
                'low.',
          ),
          _card(
            seed: 321,
            widget: 'WiredMap',
            package: 'skribble_maps',
            href: SiteLinks.maps,
            art: const _SketchMap(),
            caption:
                'A crisp MapLibre basemap underneath. skribble draws the '
                'pins, route, area, location, and controls on top.',
          ),
        ], 'companion-grid'),
      ],
    );
  }

  static Component _card({
    required int seed,
    required String widget,
    required String package,
    required String href,
    required Component art,
    required String caption,
  }) {
    return WiredCard(
      seed: seed,
      classes: 'companion-card reveal',
      child: Component.fragment([
        el('div', [
          el('h3', [
            el('code', [t(widget)]),
          ]),
          anchor(
            href,
            [t('Try it live')],
            classes: 'play-docs',
            attributes: {'aria-label': '$widget live example'},
          ),
        ], 'play-head'),
        art,
        para(caption, classes: 'companion-caption'),
        el('p', [
          el('code', [t('flutter pub add $package')]),
        ], 'companion-install'),
      ]),
    );
  }
}

const _artWidth = 560.0;
const _artHeight = 320.0;

/// Positions an HTML label at ([x], [y]) in the art's own units.
Component _tag(String text, double x, double y, String classes) => el(
  'span',
  [t(text)],
  classes,
  {
    'style': 'left:${_percent(x / _artWidth)};top:${_percent(y / _artHeight)}',
  },
);

String _percent(double fraction) => '${(fraction * 100).toStringAsFixed(2)}%';

/// The illustrative candles from the charts docs page, in cents.
const _closes = [
  14220, 14268, 14240, 14304, 14380, 14355, 14295, 14210, //
  14178, 14230, 14295, 14368, 14420, 14380, 14405, 14475,
  14520, 14490, 14430, 14485, 14540, 14512, 14580, 14605,
];

/// How far each candle's wick rises above and falls below its body, in cents.
const _wickUp = [
  18, 12, 30, 8, 22, 15, 10, 26, 12, 20, 9, 24, //
  16, 28, 11, 19, 25, 14, 30, 10, 17, 22, 13, 20,
];
const _wickDown = [
  14, 22, 9, 17, 11, 26, 19, 12, 24, 10, 15, 13, //
  21, 9, 18, 12, 16, 27, 11, 20, 14, 10, 23, 15,
];

/// Traded volume for each candle, in arbitrary units.
const _volumes = [
  8, 14, 6, 18, 26, 12, 20, 30, 22, 10, 16, 24, //
  28, 12, 9, 20, 26, 14, 18, 11, 24, 10, 16, 22,
];

/// A candlestick chart with volume, a five-candle moving average, and a
/// horizontal price annotation, as `WiredFinancialChart` draws it.
class _CandleChart extends StatelessComponent {
  const _CandleChart();

  static const _low = 14120.0;
  static const _high = 14660.0;
  static const _plotLeft = 14.0;
  static const _plotRight = 486.0;
  static const _priceTop = 18.0;
  static const _priceBottom = 232.0;
  static const _volumeBottom = 304.0;
  static const _volumeHeight = 44.0;
  static const _marked = 14500;

  static double _y(num cents) =>
      _priceBottom -
      (cents - _low) / (_high - _low) * (_priceBottom - _priceTop);

  @override
  Component build(BuildContext context) {
    const slot = (_plotRight - _plotLeft) / 24;
    const body = 11.0;
    final marks = <Mark>[
      for (final (index, cents) in [14200, 14300, 14400, 14500, 14600].indexed)
        Mark(
          Pen.gentle
              .generator(330 + index)
              .line(
                _plotLeft,
                _y(cents),
                _plotRight,
                _y(cents),
              ),
          stroke: Tone.rule,
          width: 1,
        ),
      Mark(
        Pen.gentle
            .generator(336)
            .line(
              _plotLeft,
              _volumeBottom,
              _plotRight,
              _volumeBottom,
            ),
        stroke: Tone.rule,
        width: 1,
      ),
    ];

    for (final (index, close) in _closes.indexed) {
      final open = index == 0 ? 14190 : _closes[index - 1];
      final rise = close >= open;
      final tone = rise ? Tone.rise : Tone.fall;
      final centre = _plotLeft + slot * (index + 0.5);
      final top = _y(math.max(open, close));
      final bottom = _y(math.min(open, close));
      const pen = Pen.gentle;

      marks
        ..add(
          Mark(
            pen
                .generator(400 + index)
                .line(
                  centre,
                  _y(math.max(open, close) + _wickUp[index]),
                  centre,
                  _y(math.min(open, close) - _wickDown[index]),
                ),
            stroke: tone,
            width: 1.4,
          ),
        )
        ..add(
          Mark(
            pen
                .generator(
                  440 + index,
                  fill: RoughFillStyle.hachure,
                  gap: 3.2,
                  angle: rise ? 320 : 40,
                )
                .rectangle(
                  centre - body / 2,
                  top,
                  body,
                  math.max(bottom - top, 2),
                ),
            stroke: tone,
            fill: tone,
            width: 1.6,
            fillWidth: 1.1,
          ),
        );
    }

    final loudest = _volumes.reduce(math.max);

    for (final (index, volume) in _volumes.indexed) {
      final close = _closes[index];
      final open = index == 0 ? 14190 : _closes[index - 1];
      final height = volume / loudest * _volumeHeight;
      final centre = _plotLeft + slot * (index + 0.5);

      marks.add(
        Mark(
          Pen.gentle
              .generator(480 + index, fill: RoughFillStyle.hachure, gap: 3.5)
              .rectangle(
                centre - body / 2,
                _volumeBottom - height,
                body,
                height,
              ),
          stroke: close >= open ? Tone.rise : Tone.fall,
          fill: close >= open ? Tone.rise : Tone.fall,
          width: 1,
          fillWidth: 0.7,
          classes: 'chart-volume',
        ),
      );
    }

    marks
      ..add(
        Mark(
          Pen.playful.generator(520).curvePath([
            for (var index = 4; index < _closes.length; index++)
              PointD(
                _plotLeft + slot * (index + 0.5),
                _y(
                  _closes
                          .sublist(index - 4, index + 1)
                          .reduce((sum, next) => sum + next) /
                      5,
                ),
              ),
          ]),
          stroke: Tone.sky,
          width: 2.2,
        ),
      )
      ..add(
        Mark(
          Pen.playful
              .generator(521)
              .line(
                _plotLeft,
                _y(_marked),
                _plotRight,
                _y(_marked),
              ),
          stroke: Tone.coral,
        ),
      );

    return el('div', [
      doodle(
        width: _artWidth,
        height: _artHeight,
        stretch: true,
        label:
            'A hand-drawn candlestick chart rising from 141.78 to 146.05, '
            'with volume bars, a moving average, and a line marked at '
            '145.00.',
        marks: marks,
      ),
      for (final cents in [14200, 14300, 14400, 14600])
        _tag(_price(cents), 494, _y(cents), 'chart-price'),
      _tag(_price(_marked), 494, _y(_marked), 'chart-price chart-price--mark'),
      _tag('SOL / USDC · 1m', 18, 6, 'chart-title'),
    ], 'companion-art chart-art');
  }

  static String _price(int cents) =>
      '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
}

/// A paper basemap with hand-drawn pins, a route, an area, the user's
/// location, and zoom controls, as `WiredMap` and its layers draw them.
class _SketchMap extends StatelessComponent {
  const _SketchMap();

  static const _route = [
    (112, 118),
    (150, 146),
    (206, 166),
    (262, 150),
    (318, 120),
    (380, 104),
    (436, 96),
  ];

  @override
  Component build(BuildContext context) {
    final pins = [(112.0, 118.0, Tone.coral), (436.0, 96.0, Tone.sun)];

    return el('div', [
      RawText(_basemap()),
      doodle(
        width: _artWidth,
        height: _artHeight,
        stretch: true,
        label:
            'A street map with a hand-drawn route between two pins, a '
            'hatched area, the current location, and zoom buttons.',
        marks: [
          Mark(
            Pen.playful
                .generator(540, fill: RoughFillStyle.hachure, gap: 7)
                .polygon([
                  for (final (x, y) in const [
                    (300, 176),
                    (404, 158),
                    (462, 214),
                    (396, 274),
                    (298, 250),
                  ])
                    PointD(x.toDouble(), y.toDouble()),
                ]),
            stroke: Tone.lilac,
            fill: Tone.lilac,
            width: 2.2,
          ),
          Mark(
            roughCurve(Pen.playful.generator(541), _route),
            stroke: Tone.coral,
            width: 4,
          ),
          for (final (index, (x, y, tone)) in pins.indexed) ...[
            Mark(
              Pen.playful
                  .generator(550 + index, fill: RoughFillStyle.solid)
                  .polygon(_pin(x, y, 18)),
              fill: tone,
              width: 2.2,
            ),
            Mark(
              Pen.playful
                  .generator(560 + index, fill: RoughFillStyle.solid)
                  .circle(x, y - 26, 13),
              fill: Tone.paper,
              width: 1.6,
            ),
          ],
          Mark(
            Pen.gentle
                .generator(570, fill: RoughFillStyle.hachure, gap: 4)
                .polygon([
                  PointD(214, 246),
                  PointD(200, 214),
                  PointD(228, 214),
                ]),
            stroke: Tone.sky,
            fill: Tone.sky,
            width: 1.2,
          ),
          Mark(
            Pen.gentle
                .generator(571, fill: RoughFillStyle.solid)
                .circle(214, 250, 16),
            fill: Tone.sky,
            width: 2.4,
          ),
          Mark(
            Pen.gentle.generator(572).circle(214, 250, 34),
            stroke: Tone.sky,
            width: 1.4,
          ),
          for (final (index, y) in const [24.0, 66.0].indexed)
            Mark(
              Pen.playful
                  .generator(580 + index, fill: RoughFillStyle.solid)
                  .rectangle(506, y, 36, 36),
              fill: Tone.paper,
            ),
          Mark(
            Pen.playful.generator(590).line(514, 42, 534, 42),
            width: 2.4,
          ),
          Mark(
            Pen.playful.generator(591).line(524, 32, 524, 52),
            width: 2.4,
          ),
          Mark(
            Pen.playful.generator(592).line(514, 84, 534, 84),
            width: 2.4,
          ),
        ],
      ),
      _tag('Studio', 112, 140, 'map-label'),
      _tag('Café', 436, 118, 'map-label'),
    ], 'companion-art map-art');
  }

  /// A teardrop pin whose point sits on ([x], [y]).
  static List<PointD> _pin(double x, double y, double radius) {
    final centre = y - radius * 1.45;

    return [
      PointD(x, y),
      for (var step = 0; step <= 12; step++)
        PointD(
          x + radius * math.cos(math.pi * (0.78 + step / 12 * 1.44)),
          centre + radius * math.sin(math.pi * (0.78 + step / 12 * 1.44)),
        ),
    ];
  }

  /// The crisp basemap: MapLibre draws tiles exactly, so this is plain SVG.
  static String _basemap() {
    final svg =
        StringBuffer(
            '<svg class="map-base" xmlns="http://www.w3.org/2000/svg" '
            'viewBox="0 0 560 320" preserveAspectRatio="none" '
            'aria-hidden="true" focusable="false">',
          )
          ..write('<rect width="560" height="320" class="map-land"/>')
          ..write(
            '<rect x="40" y="196" width="140" height="96" rx="10" '
            'class="map-park"/>',
          )
          ..write(
            '<path d="M-10 70 C 120 60, 180 120, 300 92 S 470 40, 570 54" '
            'class="map-water"/>',
          );

    for (final (x, y, w, h) in const [
      (210, 26, 54, 34),
      (276, 26, 42, 30),
      (210, 196, 60, 40),
      (330, 196, 40, 28),
      (476, 236, 60, 44),
      (40, 120, 52, 38),
      (360, 252, 30, 26),
      (480, 130, 60, 40),
    ]) {
      svg.write(
        '<rect x="$x" y="$y" width="$w" height="$h" rx="2" '
        'class="map-block"/>',
      );
    }

    for (final (x1, y1, x2, y2, major) in const [
      (0, 170, 560, 150, true),
      (196, 0, 220, 320, true),
      (0, 108, 560, 120, false),
      (0, 248, 560, 230, false),
      (100, 0, 120, 320, false),
      (300, 0, 286, 320, false),
      (390, 0, 410, 320, false),
      (466, 0, 470, 320, true),
    ]) {
      svg.write(
        '<path d="M$x1 $y1 L$x2 $y2" '
        'class="map-road${major ? ' map-road--major' : ''}"/>',
      );
    }

    return (svg..write('</svg>')).toString();
  }
}
