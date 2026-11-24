import 'dart:math' as math;

import 'package:jaspr/jaspr.dart';

/// Shorthand for an HTML element, keeping section markup close to the HTML
/// it renders.
Component el(
  String tag, [
  List<Component> children = const [],
  String? classes,
  Map<String, String>? attributes,
]) => Component.element(
  tag: tag,
  classes: classes,
  attributes: attributes,
  children: children,
);

/// A text node.
Component t(String text) => Component.text(text);

/// A `<p>` with plain text.
Component para(String text, {String? classes}) => el('p', [t(text)], classes);

/// A link. External links open in the same tab, as ordinary links should.
Component anchor(
  String href,
  List<Component> children, {
  String? classes,
  Map<String, String>? attributes,
}) => el('a', children, classes, {'href': href, ...?attributes});

/// A section with a heading wired to it for assistive technology.
Component pageSection({
  required String id,
  required String eyebrow,
  required List<Component> title,
  required List<Component> children,
  String? lede,
  String? classes,
}) {
  return el(
    'section',
    [
      el('div', [
        el('p', [t(eyebrow)], 'eyebrow'),
        el('h2', title, null, {'id': '$id-title'}),
        if (lede != null) para(lede, classes: 'lede'),
      ], 'section-head reveal'),
      ...children,
    ],
    ['section', ?classes].join(' '),
    {'id': id, 'aria-labelledby': '$id-title'},
  );
}

/// Strips comments and the whitespace CSS does not need from [css].
///
/// Strings are copied as they are. Whitespace is dropped around `{`, `}`,
/// `;`, and `,`, and after `:`, and collapsed elsewhere, so descendant
/// combinators such as `.card :is(h2)` and
/// values such as `0 auto` keep their meaning. The last `;` of a block goes.
String minifyCss(String css) {
  const tight = '{};,';
  final out = <String>[];
  var i = 0;
  var space = false;

  void emit(String text) {
    if (space && out.isNotEmpty) {
      final last = out.last[out.last.length - 1];
      // A space after ":" never matters: selectors cannot have one, and
      // declarations ignore it.
      if (!'$tight:'.contains(last) && !tight.contains(text[0])) {
        out.add(' ');
      }
    }
    space = false;
    if (text == '}' && out.isNotEmpty && out.last == ';') out.removeLast();
    out.add(text);
  }

  while (i < css.length) {
    final c = css[i];
    if (c == '/' && i + 1 < css.length && css[i + 1] == '*') {
      final end = css.indexOf('*/', i + 2);
      i = end < 0 ? css.length : end + 2;
      space = true;
    } else if (c == '"' || c == "'") {
      var end = i + 1;
      while (end < css.length && css[end] != c) {
        if (css[end] == r'\') end++;
        end++;
      }
      emit(css.substring(i, math.min(end + 1, css.length)));
      i = end + 1;
    } else if (' \n\t\r'.contains(c)) {
      space = true;
      i++;
    } else {
      emit(c);
      i++;
    }
  }

  return out.join();
}
