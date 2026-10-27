import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A card with a hand-drawn rectangle border.
///
/// Reads fill color from the nearest [WiredTheme] ancestor.
class WiredCard extends HookWidget {
  /// The card's content.
  final Widget? child;

  /// Whether to colour the card in with close, even pencil strokes of the
  /// theme's `fillColor`. Wrap the card in a [WiredTheme] to choose a tint.
  final bool fill;

  /// Fixed height, or null to size to [child].
  final double? height;

  /// Soft corners for the paper outline. Use [BorderRadius.zero] for square ink.
  final BorderRadius borderRadius;

  const WiredCard({
    super.key,
    this.child,
    this.fill = false,
    this.height = 130.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.seed,
  });

  /// Varies the hand behind this widget's ink. The same seed always draws
  /// the same wobble, so neighbouring shapes of the same size need different
  /// seeds to stop them reading as copies of each other. Null keeps the
  /// theme's seed.
  final int? seed;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final stack = Stack(
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
        if (height != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Card(
                  color: Colors.transparent,
                  shadowColor: Colors.transparent,
                  child: child,
                ),
              ),
            ],
          )
        else
          Card(
            color: Colors.transparent,
            shadowColor: Colors.transparent,
            child: child,
          ),
      ],
    );

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      height: height,
      child: stack,
    );
  }
}
