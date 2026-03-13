import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn horizontal divider line, corresponding to Flutter's
/// [Divider].
///
/// Renders a sketchy line using `WiredLineBase` with the border color
/// from the nearest `WiredTheme` ancestor.
class WiredDivider extends HookWidget {
  const WiredDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Stack(
      children: [
        SizedBox(
          height: 1,
          width: double.infinity,
          child: WiredCanvas(
            painter: WiredLineBase(
              x1: 0,
              y1: 0,
              x2: double.infinity,
              y2: 0,
              borderColor: theme.borderColor,
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
        Divider(color: Colors.transparent),
      ],
    );
  }
}
