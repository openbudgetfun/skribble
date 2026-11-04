import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A card with a hand-drawn rectangle border.
///
/// Reads fill color from the nearest [WiredTheme] ancestor. Its [child]
/// sits [padding] inside the ink, [kWiredInkPadding] by default, and the
/// card is at least [height] tall, growing when its content needs more
/// room.
class WiredCard extends HookWidget {
  /// The card's content.
  final Widget? child;

  /// Whether to colour the card in with close, even pencil strokes of the
  /// theme's `fillColor`. Wrap the card in a [WiredTheme] to choose a tint.
  final bool fill;

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
              fillColor: theme.fillColor,
              borderColor: theme.borderColor,
            ),
            fillerType: fill ? RoughFilter.hachureFiller : RoughFilter.noFiller,
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
          child: Padding(padding: padding, child: child),
        ),
      ],
    );

    final least = height;
    return least == null
        ? card
        : ConstrainedBox(
            constraints: BoxConstraints(minHeight: least),
            child: card,
          );
  }
}
