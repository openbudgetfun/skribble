import 'package:jaspr/jaspr.dart';
import 'package:skribble_rough/skribble_rough.dart';

import 'package:skribble_site/src/html.dart';
import 'package:skribble_site/src/ink.dart';

/// Hand-drawn form controls built on native inputs.
///
/// Each control keeps a real `<input>` for keyboard, form, and screen-reader
/// behaviour, visually hidden behind server-drawn ink. Checked, focused, and
/// hovered states are pure CSS, so the controls work without JavaScript.

/// A checkbox with a rough box and a tick that draws itself on when checked.
///
/// With [strike], the label is crossed out when the box is checked.
Component sketchCheckbox(
  String label, {
  required int seed,
  bool checked = false,
  bool strike = false,
  List<Pen> pens = const [Pen.playful],
}) {
  return el('label', [
    el('input', const [], 'control', {
      'type': 'checkbox',
      if (checked) 'checked': '',
    }),
    el('span', [
      penDoodle(
        width: 28,
        height: 28,
        pens: pens,
        classes: 'check-box',
        marks: (pen) => [
          Mark(roughBox(pen.generator(seed), 28, 28, inset: 2.5)),
        ],
      ),
      penDoodle(
        width: 28,
        height: 28,
        pens: pens,
        classes: 'check-tick',
        marks: (pen) => [
          Mark(
            roughCurve(pen.generator(seed + 40), [(5, 15), (11, 22), (25, 3)]),
            stroke: Tone.coral,
            width: 3,
          ),
        ],
      ),
    ], 'check'),
    el('span', [
      t(label),
      if (strike)
        penDoodle(
          width: 200,
          height: 12,
          stretch: true,
          pens: pens,
          classes: 'task-strike',
          marks: (pen) => [
            Mark(pen.generator(seed + 80).line(2, 7, 198, 5)),
          ],
        ),
    ], 'task-label'),
  ], 'task');
}

/// A switch: a hatched track with a knob that slides across when on.
Component sketchSwitch(
  String label, {
  required int seed,
  bool checked = false,
  List<Pen> pens = const [Pen.playful],
  String? classes,
}) {
  return el('label', [
    el('span', [t(label)], 'row-label'),
    el('input', const [], 'control', {
      'type': 'checkbox',
      'role': 'switch',
      if (checked) 'checked': '',
    }),
    el('span', [
      penDoodle(
        width: 58,
        height: 32,
        pens: pens,
        classes: 'switch-track',
        marks: (pen) => [
          Mark(
            pen
                .generator(seed, fill: RoughFillStyle.hachure, gap: 5)
                .roundedRectangle(3, 3, 52, 26, 13, 13, 13, 13),
            fill: Tone.mint,
          ),
        ],
      ),
      penDoodle(
        width: 24,
        height: 24,
        pens: pens,
        classes: 'switch-knob',
        marks: (pen) => [
          Mark(
            roughOval(
              pen.generator(seed + 1, fill: RoughFillStyle.solid),
              24,
              24,
              inset: 2,
            ),
          ),
        ],
      ),
    ], 'switch'),
  ], ['switch-row', ?classes].join(' '));
}

/// A radio button whose dot is scribbled in when selected.
Component sketchRadio(
  String label, {
  required String name,
  required int seed,
  bool checked = false,
}) {
  final g = Pen.playful.generator(seed);

  return el('label', [
    el('input', const [], 'control', {
      'type': 'radio',
      'name': name,
      'value': label,
      if (checked) 'checked': '',
    }),
    el('span', [
      doodle(
        width: 28,
        height: 28,
        classes: 'check-box',
        marks: [Mark(roughOval(g, 28, 28, inset: 2.5))],
      ),
      doodle(
        width: 28,
        height: 28,
        classes: 'check-tick',
        marks: [
          Mark(
            roughOval(
              Pen.playful.generator(seed + 1, fill: RoughFillStyle.solid),
              28,
              28,
              inset: 8,
            ),
            stroke: Tone.coral,
          ),
        ],
      ),
    ], 'check'),
    el('span', [t(label)], 'task-label'),
  ], 'task');
}

/// A filter chip that fills with hatching when selected.
Component sketchChip(String label, {required int seed, bool checked = false}) {
  return el('label', [
    el('input', const [], 'control', {
      'type': 'checkbox',
      if (checked) 'checked': '',
    }),
    doodle(
      width: 120,
      height: 40,
      stretch: true,
      classes: 'chip-fill',
      marks: [
        Mark(
          roughBox(
            Pen.playful.generator(seed, fill: RoughFillStyle.hachure, gap: 6),
            120,
            40,
          ),
          stroke: Tone.paper,
          fill: Tone.sun,
          width: 0.01,
        ),
      ],
    ),
    doodle(
      width: 120,
      height: 40,
      stretch: true,
      classes: 'chip-line',
      marks: [Mark(roughBox(Pen.playful.generator(seed + 1), 120, 40))],
    ),
    el('span', [t(label)], 'chip-label'),
  ], 'chip');
}

/// A single-line text field with a rough frame that redraws on focus.
Component sketchField(
  String label, {
  required String id,
  required int seed,
  String? placeholder,
}) {
  return el('div', [
    el('label', [t(label)], 'field-label', {'for': id}),
    el('div', [
      doodle(
        width: 260,
        height: 48,
        stretch: true,
        classes: 'field-ink',
        marks: [Mark(roughBox(Pen.playful.generator(seed), 260, 48))],
      ),
      doodle(
        width: 260,
        height: 48,
        stretch: true,
        classes: 'field-focus',
        marks: [
          Mark(
            roughBox(Pen.playful.generator(seed + 1), 260, 48),
            stroke: Tone.coral,
            width: 2.6,
          ),
        ],
      ),
      el('input', const [], 'field-input', {
        'id': id,
        'type': 'text',
        'autocomplete': 'off',
        'placeholder': ?placeholder,
      }),
    ], 'field-box'),
  ], 'field');
}

/// A range slider over a rough track. `site.js` shows the live value.
Component sketchSlider(
  String label, {
  required String id,
  required int seed,
  int value = 60,
}) {
  return el('div', [
    el('div', [
      el('label', [t(label)], 'field-label', {'for': id}),
      el('output', [t('$value')], 'slider-value', {'for': id}),
    ], 'slider-head'),
    el('div', [
      doodle(
        width: 260,
        height: 20,
        stretch: true,
        classes: 'slider-track',
        marks: [
          Mark(
            roughCurve(Pen.playful.generator(seed), [
              (4, 11),
              (90, 8),
              (180, 12),
              (256, 9),
            ]),
          ),
        ],
      ),
      el('input', const [], 'range', {
        'id': id,
        'type': 'range',
        'min': '0',
        'max': '100',
        'value': '$value',
      }),
    ], 'slider'),
  ], 'field');
}

/// The rough knob drawn on every range thumb, as a CSS `url()` value.
String sliderThumbDataUri() {
  final ink = RoughSvg.fromDrawable(
    Pen.playful
        .generator(91, fill: RoughFillStyle.solid)
        .ellipse(14, 14, 22, 22),
  );
  final svg = [
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 28 28">',
    '<path d="${ink.solid}" fill="#e87960"/>',
    '<path d="${ink.outline}" fill="none" stroke="#34283f" ',
    'stroke-width="2" stroke-linecap="round"/></svg>',
  ].join();

  return 'url("data:image/svg+xml,${Uri.encodeComponent(svg)}")';
}
