import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A card with a hand-drawn rectangle border.
///
/// Reads fill color from the nearest [WiredTheme] ancestor.
class WiredCard extends HookWidget {
  final Widget? child;
  final bool fill;
  final double? height;

  /// Soft corners for the paper outline. Use [BorderRadius.zero] for square ink.
  final BorderRadius borderRadius;

  const WiredCard({
    super.key,
    this.child,
    this.fill = false,
    this.height = 130.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

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
