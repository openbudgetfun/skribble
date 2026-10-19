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
