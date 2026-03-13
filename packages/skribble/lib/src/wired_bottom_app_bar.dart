import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'wired_base.dart';

/// A hand-drawn bottom app bar corresponding to Flutter's [BottomAppBar].
///
/// Provides a sketchy hand-drawn top border with optional FAB notch support
/// and child content.
class WiredBottomAppBar extends HookWidget {
  /// The content of the bottom app bar.
  final Widget? child;

  /// Background color.
  final Color? color;

  /// Elevation of the bar.
  final double? elevation;

  /// The shape of the notch for the FAB. Use [CircularNotchedRectangle]
  /// for the standard notch.
  final NotchedShape? shape;

  /// The margin around the notch.
  final double notchMargin;

  /// Padding inside the bar.
  final EdgeInsetsGeometry? padding;

  /// Height of the bar.
  final double? height;

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
    final bgColor = color ?? filledColor;

    return buildWiredElement(
      child: SizedBox(
        height: height ?? 56,
        child: Stack(
          children: [
            // Background
            Positioned.fill(child: Container(color: bgColor)),
            // Sketchy top border
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 3,
              child: WiredCanvas(
                painter: WiredLineBase(
                  x1: 0,
                  y1: 1,
                  x2: double.maxFinite,
                  y2: 1,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            // Content
            Positioned.fill(
              child: Padding(
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
