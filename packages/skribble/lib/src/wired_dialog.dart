import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A dialog with a hand-drawn rectangle border.
///
/// Reads fill color from the nearest [WiredTheme] ancestor. The dialog hugs
/// its [child]: the border is drawn around the content, never stretched to
/// the height of the screen.
class WiredDialog extends HookWidget {
  /// The content of the dialog.
  final Widget child;

  /// Padding around the content.
  final EdgeInsetsGeometry? padding;

  /// Creates a dialog with a hand-drawn border.
  const WiredDialog({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return Dialog(
      child: Stack(
        children: [
          // The border follows the content's size. As a sizing child, a
          // canvas takes all the room it is offered, which is the whole
          // screen inside a dialog route.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: WiredCanvas(
                painter: WiredRectangleBase(
                  strokeWidth: theme.strokeWidth,
                  fillColor: theme.fillColor,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
          Padding(padding: padding ?? const EdgeInsets.all(20.0), child: child),
        ],
      ),
    );
  }
}
