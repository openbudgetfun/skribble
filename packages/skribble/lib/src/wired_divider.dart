import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn horizontal divider line, corresponding to Flutter's
/// `Divider`.
///
/// Takes 16 pixels of height, like Material's divider, and draws a sketchy
/// `WiredLineBase` across the middle of them in the border color of the
/// nearest `WiredTheme`, so the space above and below the line is even.
class WiredDivider extends HookWidget {
  /// Creates a hand-drawn horizontal divider.
  const WiredDivider({super.key});

  /// The height the divider takes, line included.
  static const double height = 16;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          height: theme.inkExtent,
          width: double.infinity,
          child: WiredCanvas(
            painter: WiredLineBase(
              strokeWidth: theme.strokeWidth,
              x1: 0,
              y1: 0,
              x2: double.infinity,
              y2: 0,
              borderColor: theme.borderColor,
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
      ),
    );
  }
}
