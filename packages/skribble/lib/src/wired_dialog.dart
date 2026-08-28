import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A dialog with a hand-drawn rectangle border.
///
/// Reads fill color from the nearest [WiredTheme] ancestor.
class WiredDialog extends HookWidget {
  /// The content of the dialog.
  final Widget child;

  /// Padding around the content.
  final EdgeInsetsGeometry? padding;

  /// The border radius for the hand-drawn dialog shape.
  ///
  /// When provided, the dialog draws with rounded corners
  /// instead of sharp corners. Defaults to null (sharp corners).
  final BorderRadius? borderRadius;

  const WiredDialog({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return Dialog(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: WiredCanvas(
              painter: borderRadius != null
                  ? WiredRoundedRectangleBase(
                      borderRadius: borderRadius!,
                      fillColor: theme.fillColor,
                      borderColor: theme.borderColor,
                    )
                  : WiredRectangleBase(
                      fillColor: theme.fillColor,
                      borderColor: theme.borderColor,
                    ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Padding(padding: padding ?? const EdgeInsets.all(20.0), child: child),
        ],
      ),
    );
  }
}
