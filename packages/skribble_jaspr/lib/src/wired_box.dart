import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/src/ink.dart';
import 'package:skribble_rough/skribble_rough.dart';

/// Wraps [child] in an element with a hand-drawn rectangle behind it.
///
/// The border is generated on the server from [seed], so the same seed
/// always renders the same wobble and static builds stay byte-stable. It is
/// drawn into an absolutely positioned, decorative `<svg>` that stretches
/// with the element, so the box can be any size and needs no JavaScript.
///
/// Include `skribbleCss` on the page for positioning and theming. Every
/// other wired component is built on the same overlay.
///
/// ```dart
/// WiredBox(
///   seed: 4,
///   fillStyle: RoughFillStyle.hachure,
///   fill: '#ffe08a',
///   classes: 'pricing-tier',
///   child: Component.text('Pro'),
/// )
/// ```
class WiredBox extends StatelessComponent {
  /// Creates a hand-drawn box around [child].
  const WiredBox({
    required this.child,
    this.seed = 1,
    this.roughness = 1,
    this.fill,
    this.fillStyle = RoughFillStyle.none,
    this.tag = 'div',
    this.classes,
    this.attributes,
    super.key,
  });

  /// The nominal canvas a box is drawn on before it stretches.
  static const InkCanvas boxCanvas = InkCanvas(240, 120);

  /// The content drawn over the ink.
  final Component child;

  /// Chooses the wobble. The same seed always draws the same border.
  final int seed;

  /// How far the hand wanders from a straight line; zero is ruler-straight.
  final double roughness;

  /// The fill colour, as any CSS colour.
  ///
  /// Sets the `--skribble-fill` custom property on the element. When null,
  /// fills use `--skribble-accent`. Only visible when [fillStyle] is not
  /// [RoughFillStyle.none].
  final String? fill;

  /// The fill pattern drawn inside the border.
  final RoughFillStyle fillStyle;

  /// The HTML tag of the wrapping element, such as `section` or `li`.
  final String tag;

  /// Extra CSS classes, added after the component's own classes.
  final String? classes;

  /// Extra HTML attributes for the wrapping element, such as `id` or
  /// `aria-label`.
  final Map<String, String>? attributes;

  @override
  Component build(BuildContext context) {
    return _inkBox(
      shape: InkShape.rectangle,
      canvas: boxCanvas,
      baseClass: 'skribble-box',
      seed: seed,
      roughness: roughness,
      fill: fill,
      fillStyle: fillStyle,
      tag: tag,
      classes: classes,
      attributes: attributes,
      child: child,
    );
  }
}

/// A hand-drawn card: a padded [WiredBox] for grouping related content.
///
/// Renders a `<div class="skribble-card">`. Give it a heading inside [child]
/// for screen readers; the border itself is decorative.
class WiredCard extends StatelessComponent {
  /// Creates a hand-drawn card around [child].
  const WiredCard({
    required this.child,
    this.seed = 1,
    this.fill,
    this.fillStyle = RoughFillStyle.none,
    this.classes,
    super.key,
  });

  /// The nominal canvas a card is drawn on before it stretches.
  static const InkCanvas cardCanvas = InkCanvas(320, 200, gap: 10);

  /// The card's content.
  final Component child;

  /// Chooses the wobble. The same seed always draws the same border.
  final int seed;

  /// The fill colour, as any CSS colour. See [WiredBox.fill].
  final String? fill;

  /// The fill pattern drawn inside the border.
  final RoughFillStyle fillStyle;

  /// Extra CSS classes, added after `skribble-card`.
  final String? classes;

  @override
  Component build(BuildContext context) {
    return _inkBox(
      shape: InkShape.rectangle,
      canvas: cardCanvas,
      baseClass: 'skribble-box skribble-card',
      seed: seed,
      roughness: 1,
      fill: fill,
      fillStyle: fillStyle,
      tag: 'div',
      classes: classes,
      attributes: null,
      child: child,
    );
  }
}

/// Wraps [child] in a hand-drawn ellipse, like a circled note.
///
/// The ellipse stretches with the element: a square element gets a circle.
/// Use it for badges, stickers, and step numbers. For circling a word in a
/// sentence, use `WiredHighlight` with `WiredHighlightKind.circle`.
class WiredCircle extends StatelessComponent {
  /// Creates a hand-drawn ellipse around [child].
  const WiredCircle({
    required this.child,
    this.seed = 1,
    this.roughness = 1,
    this.fill,
    this.fillStyle = RoughFillStyle.none,
    this.tag = 'div',
    this.classes,
    this.attributes,
    super.key,
  });

  /// The nominal canvas an ellipse is drawn on before it stretches.
  static const InkCanvas circleCanvas = InkCanvas(120, 120, inset: 4);

  /// The content drawn inside the ellipse.
  final Component child;

  /// Chooses the wobble. The same seed always draws the same ellipse.
  final int seed;

  /// How far the hand wanders from a perfect curve.
  final double roughness;

  /// The fill colour, as any CSS colour. See [WiredBox.fill].
  final String? fill;

  /// The fill pattern drawn inside the ellipse.
  final RoughFillStyle fillStyle;

  /// The HTML tag of the wrapping element.
  final String tag;

  /// Extra CSS classes, added after `skribble-circle`.
  final String? classes;

  /// Extra HTML attributes for the wrapping element.
  final Map<String, String>? attributes;

  @override
  Component build(BuildContext context) {
    return _inkBox(
      shape: InkShape.ellipse,
      canvas: circleCanvas,
      baseClass: 'skribble-box skribble-circle',
      seed: seed,
      roughness: roughness,
      fill: fill,
      fillStyle: fillStyle,
      tag: tag,
      classes: classes,
      attributes: attributes,
      child: child,
    );
  }
}

/// Renders [child] inside [tag] with a rough [shape] stretched behind it.
Component _inkBox({
  required InkShape shape,
  required InkCanvas canvas,
  required String baseClass,
  required int seed,
  required double roughness,
  required String? fill,
  required RoughFillStyle fillStyle,
  required String tag,
  required String? classes,
  required Map<String, String>? attributes,
  required Component child,
}) {
  final ink = drawInkShape(
    shape,
    canvas,
    seed: seed,
    roughness: roughness,
    fillStyle: fillStyle,
  );

  return Component.element(
    tag: tag,
    classes: joinClasses([baseClass, classes]),
    styles: fill == null ? null : Styles(raw: {'--skribble-fill': fill}),
    attributes: attributes,
    children: [inkSvg(ink, canvas), child],
  );
}
