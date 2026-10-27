import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:skribble_jaspr/src/ink.dart';
import 'package:skribble_rough/skribble_rough.dart';

/// How a [WiredHighlight] marks its text.
enum WiredHighlightKind {
  /// A pen stroke under the text.
  underline,

  /// A loose loop drawn around the text.
  circle,

  /// A highlighter swipe behind the text.
  marker,

  /// A pen stroke through the middle of the text.
  strikethrough,

  /// A rough rectangle drawn around the text.
  box,
}

/// Marks a word or phrase inside running text with hand-drawn ink.
///
/// Renders an inline `<span>` around [child], with the ink in a decorative
/// overlay that sizes itself to the text through `skribbleCss`. The
/// highlight is visual only: wrap [child] in `<em>`, `<strong>`, `<mark>`,
/// or `<del>` when the emphasis carries meaning.
///
/// ```dart
/// Component.element(tag: 'h1', children: [
///   Component.text('Draw it '),
///   WiredHighlight(
///     kind: WiredHighlightKind.circle,
///     child: Component.text('differently'),
///   ),
/// ])
/// ```
class WiredHighlight extends StatelessComponent {
  /// Creates a highlight around [child].
  const WiredHighlight({
    required this.child,
    this.kind = WiredHighlightKind.underline,
    this.seed = 1,
    this.color,
    super.key,
  });

  /// The highlighted content.
  final Component child;

  /// How the text is marked.
  final WiredHighlightKind kind;

  /// Chooses the wobble. The same seed always draws the same mark.
  final int seed;

  /// The ink colour, as any CSS colour.
  ///
  /// Sets `--skribble-highlight` on the span. When null, pen marks use
  /// `--skribble-ink` and the marker uses `--skribble-accent`.
  final String? color;

  @override
  Component build(BuildContext context) {
    final color = this.color;

    return Component.element(
      tag: 'span',
      classes: 'skribble-highlight skribble-highlight--${kind.name}',
      styles: color == null
          ? null
          : Styles(raw: {'--skribble-highlight': color}),
      children: [child, _ink()],
    );
  }

  Component _ink() {
    const lineCanvas = InkCanvas(100, 10);
    const loopCanvas = InkCanvas(100, 40, inset: 2);

    return switch (kind) {
      WiredHighlightKind.underline ||
      WiredHighlightKind.strikethrough => inkSvg(
        RoughSvg.fromDrawable(
          inkGenerator(seed: seed).line(2, 5.5, 98, 4.5),
        ),
        lineCanvas,
      ),
      WiredHighlightKind.circle => inkSvg(
        drawInkShape(InkShape.ellipse, loopCanvas, seed: seed),
        loopCanvas,
      ),
      WiredHighlightKind.box => inkSvg(
        drawInkShape(InkShape.rectangle, loopCanvas, seed: seed),
        loopCanvas,
      ),
      WiredHighlightKind.marker => inkSvg(
        _marker(),
        loopCanvas,
      ),
    };
  }

  /// A solid swipe with no outline, like a highlighter's flat nib.
  RoughSvg _marker() {
    final drawable = inkGenerator(
      seed: seed,
      fillStyle: RoughFillStyle.solid,
    ).rectangle(2, 6, 96, 30);
    final solid = drawable.sets.where((set) => set.type == OpSetType.fillPath);

    return RoughSvg.fromDrawable(
      Drawable(options: drawable.options, sets: solid.toList()),
    );
  }
}
