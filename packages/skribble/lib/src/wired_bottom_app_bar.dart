import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn bottom app bar corresponding to Flutter's [BottomAppBar].
///
/// Draws a sketchy line along its top edge above the theme's paper and
/// centres [child] vertically inside [padding]. The bar is at least
/// [height] tall and grows when its content does, such as with large text,
/// and it keeps its content above the system's bottom inset (the home
/// indicator on notched phones).
class WiredBottomAppBar extends HookWidget {
  /// The content of the bottom app bar, usually a [Row] of buttons.
  final Widget? child;

  /// Background color. Defaults to the theme's fill color.
  final Color? color;

  /// Kept for parity with [BottomAppBar]. The bar draws no shadow, so this
  /// has no effect.
  final double? elevation;

  /// Kept for parity with [BottomAppBar]. The bar does not cut a notch for
  /// a floating action button yet, so this has no effect.
  final NotchedShape? shape;

  /// Kept for parity with [BottomAppBar]. See [shape].
  final double notchMargin;

  /// Space between the hand-drawn line and [child]. Defaults to 8 pixels
  /// above and below, the ink padding, and 16 at the sides.
  final EdgeInsetsGeometry? padding;

  /// The bar's least height, 56 by default. It grows past this when its
  /// content needs more room.
  final double? height;

  /// Creates a hand-drawn bottom app bar.
  const WiredBottomAppBar({
    super.key,
    this.child,
    this.color,
    this.elevation,
    this.shape,
    this.notchMargin = 4.0,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final bgColor = color ?? theme.fillColor;

    return buildWiredElement(
      child: ColoredBox(
        color: bgColor,
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height ?? 56),
            child: Stack(
              // Passes the least height through to the content, so it is
              // centred in a bar that grows with it.
              fit: StackFit.passthrough,
              children: [
                // Sketchy top border
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: theme.inkExtent,
                  child: WiredCanvas(
                    painter: WiredLineBase(
                      strokeWidth: theme.strokeWidth,
                      x1: 0,
                      y1: 1,
                      x2: double.maxFinite,
                      y2: 1,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.noFiller,
                  ),
                ),
                Padding(
                  padding:
                      padding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    heightFactor: 1,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
