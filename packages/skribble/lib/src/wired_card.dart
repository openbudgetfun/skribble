import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';
import 'wired_theme_scope.dart';

/// A card with a hand-drawn rectangle border.
///
/// Reads its ink from the nearest [WiredTheme] ancestor. Give it a [color]
/// to colour it in, such as `WiredTheme.of(context).accentAt(index)` to
/// colour-code a list of cards. Its [child]
/// sits [padding] inside the ink, [kWiredInkPadding] by default, and the
/// card is at least [height] tall, growing when its content needs more
/// room. With a [height] it spans the width it is given; with a null
/// [height] it wraps [child].
class WiredCard extends HookWidget {
  /// The card's content.
  final Widget? child;

  /// Whether to colour the card in with close, even pencil strokes: of
  /// [color] when it is set, otherwise of the theme's `fillColor`.
  final bool fill;

  /// The card's wash: a solid fill of this colour, or, with [fill], close
  /// pencil strokes of it. Null leaves the paper showing through.
  ///
  /// On a solid wash, the [child] is inked with
  /// the theme's `inkOn`, so its text and icons stay legible on any
  /// colour in light and dark themes.
  final Color? color;

  /// The card's least height, or null to size it to [child]. The card grows
  /// past it when its content is taller, so text never presses against the
  /// ink.
  final double? height;

  /// The space between the hand-drawn outline and [child]. Defaults to
  /// [kWiredInkPadding], 8 pixels above and below and 12 at the sides; pass
  /// [EdgeInsets.zero] when the child brings its own.
  final EdgeInsetsGeometry padding;

  /// Soft corners for the paper outline. Use [BorderRadius.zero] for square ink.
  final BorderRadius borderRadius;

  /// Creates a hand-drawn card.
  const WiredCard({
    super.key,
    this.child,
    this.fill = false,
    this.color,
    this.height = 130.0,
    this.padding = kWiredInkPadding,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.seed,
  });

  /// <!-- {=dartInkSeed|trim|linePrefix:"  /// "} -->
  /// Varies the hand behind this widget's ink. The same seed always draws
  /// the same wobble, so neighbouring shapes of the same size need different
  /// seeds to stop them reading as copies of each other. Null keeps the
  /// theme's seed.
  /// <!-- {/dartInkSeed} -->
  final int? seed;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final wash = color;
    final solid = wash != null && !fill;
    final ink = solid ? theme.inkOn(wash) : theme;
    Widget content = Padding(padding: padding, child: child);
    if (!identical(ink, theme)) {
      content = WiredThemeScope(data: ink, child: content);
    }
    final card = Stack(
      // The card's constraints, its least height included, reach the
      // content, which the outline then frames.
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: WiredCanvas(
            painter: WiredRoundedRectangleBase(
              borderRadius: borderRadius,
              strokeWidth: theme.strokeWidth,
              fillColor: wash ?? theme.fillColor,
              borderColor: theme.borderColor,
            ),
            fillerType: fill
                ? RoughFilter.hachureFiller
                : solid
                ? RoughFilter.solidFiller
                : RoughFilter.noFiller,
            seed: seed,
            // Close, even strokes read as a page coloured in with a pencil.
            fillerConfig: FillerConfig.build(
              drawConfig: theme.drawConfig.copyWith(),
              hachureGap: 7,
            ),
          ),
        ),
        // A transparent Material surface, so ink-based children such as
        // list tiles have one to draw on.
        Card(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          margin: EdgeInsets.zero,
          child: content,
        ),
      ],
    );

    final least = height;
    // A card with a height spans the width it is given, as a sheet of paper
    // would; one sized to its child wraps it.
    return least == null
        ? card
        : _SpanBoundedWidth(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: least),
              child: card,
            ),
          );
  }
}

/// Stretches its child across a bounded width and leaves it at its own
/// width when the width is unbounded, as in a horizontal scroll view.
class _SpanBoundedWidth extends SingleChildRenderObjectWidget {
  const _SpanBoundedWidth({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSpanBoundedWidth();
}

class _RenderSpanBoundedWidth extends RenderProxyBox {
  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final span = constraints.hasBoundedWidth
        ? constraints.copyWith(minWidth: constraints.maxWidth)
        : constraints;
    child.layout(span, parentUsesSize: true);
    size = constraints.constrain(child.size);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final span = constraints.hasBoundedWidth
        ? constraints.copyWith(minWidth: constraints.maxWidth)
        : constraints;
    return constraints.constrain(child?.getDryLayout(span) ?? Size.zero);
  }
}
