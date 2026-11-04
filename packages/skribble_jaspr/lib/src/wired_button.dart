import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/src/ink.dart';
import 'package:skribble_rough/skribble_rough.dart';

/// The visual weight of a [WiredButton].
enum WiredButtonVariant {
  /// A solid accent fill inside the outline, for the main call to action.
  primary,

  /// An outline only, for secondary actions beside a primary one.
  secondary,
}

/// A hand-drawn button or link.
///
/// Renders an `<a>` when [href] is set and a `<button type="button">`
/// otherwise, so keyboard, screen-reader, and middle-click behaviour come
/// from the browser. The label is [child]; the ink is decorative and hidden
/// from assistive technology.
///
/// The outline is drawn twice from neighbouring seeds. On hover `skribbleCss`
/// flips between the two drawings, the "line boil" of hand-drawn animation,
/// and tilts the ink slightly. Both effects are pure CSS and switch off under
/// `prefers-reduced-motion`. Keyboard focus draws a dashed ring outside the
/// ink.
///
/// ```dart
/// WiredButton(
///   href: '/start',
///   child: Component.text('Start sketching'),
/// )
/// ```
class WiredButton extends StatelessComponent {
  /// Creates a hand-drawn button labelled by [child].
  const WiredButton({
    required this.child,
    this.href,
    this.seed = 1,
    this.variant = WiredButtonVariant.primary,
    this.classes,
    this.attributes,
    super.key,
  });

  /// The nominal canvas a button is drawn on before it stretches.
  static const InkCanvas buttonCanvas = InkCanvas(160, 48, inset: 2.5);

  /// The button's label.
  final Component child;

  /// Where the button navigates. When set the button renders as a link.
  final String? href;

  /// Chooses the wobble. The same seed always draws the same button.
  final int seed;

  /// The button's visual weight.
  final WiredButtonVariant variant;

  /// Extra CSS classes, added after the component's own classes.
  final String? classes;

  /// Extra HTML attributes, such as `type`, `name`, `target`, or
  /// `aria-label`. They override the component's defaults.
  ///
  /// Give an icon-only button an `aria-label` so it keeps an accessible
  /// name. A `class` entry is added to the component's classes and a
  /// `style` entry is kept as is, rather than repeating either attribute.
  /// Set `aria-disabled="true"` (or `disabled` on a `<button>`) to dim the
  /// button and stop its hover motion.
  final Map<String, String>? attributes;

  @override
  Component build(BuildContext context) {
    final href = this.href;
    final fillStyle = switch (variant) {
      WiredButtonVariant.primary => RoughFillStyle.solid,
      WiredButtonVariant.secondary => RoughFillStyle.none,
    };
    final frames = [
      for (final frameSeed in [seed, seed + 1])
        inkSvg(
          drawInkShape(
            InkShape.rectangle,
            buttonCanvas,
            seed: frameSeed,
            fillStyle: fillStyle,
          ),
          buttonCanvas,
        ),
    ];
    final label = Component.element(
      tag: 'span',
      classes: 'skribble-button__label',
      children: [child],
    );

    final merged = mergeAttributes(
      classes: [
        'skribble-box',
        'skribble-button',
        'skribble-button--${variant.name}',
        'skribble-wobble',
        classes,
      ],
      defaults: {if (href == null) 'type': 'button' else 'href': href},
      attributes: attributes,
    );

    return Component.element(
      tag: href == null ? 'button' : 'a',
      classes: merged.classes,
      attributes: merged.attributes,
      children: [...frames, label],
    );
  }
}
