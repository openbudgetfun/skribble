import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/src/ink.dart';
import 'package:skribble_rough/skribble_rough.dart';

/// A hand-drawn horizontal rule between sections.
///
/// Renders `<div role="separator">`, because a `<hr>` cannot hold the SVG
/// ink. The line stretches to the divider's width.
class WiredDivider extends StatelessComponent {
  /// Creates a hand-drawn divider.
  const WiredDivider({this.seed = 1, this.classes, super.key});

  /// The nominal canvas a divider is drawn on before it stretches.
  static const InkCanvas dividerCanvas = InkCanvas(600, 12);

  /// Chooses the wobble. The same seed always draws the same line.
  final int seed;

  /// Extra CSS classes, added after `skribble-divider`.
  final String? classes;

  @override
  Component build(BuildContext context) {
    final line = inkGenerator(seed: seed).line(2, 6.5, 598, 5.5);

    return Component.element(
      tag: 'div',
      classes: joinClasses(['skribble-divider', classes]),
      attributes: const {
        'role': 'separator',
        'aria-orientation': 'horizontal',
      },
      children: [inkSvg(RoughSvg.fromDrawable(line), dividerCanvas)],
    );
  }
}
