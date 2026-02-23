import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'const.dart';
import 'rough/skribble_rough.dart';

/// A tooltip with a hand-drawn border.
class WiredTooltip extends HookWidget {
  final Widget child;
  final String message;
  final Duration? waitDuration;
  final Duration? showDuration;

  const WiredTooltip({
    super.key,
    required this.child,
    required this.message,
    this.waitDuration,
    this.showDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      waitDuration: waitDuration,
      showDuration: showDuration,
      decoration: RoughBoxDecoration(
        shape: RoughBoxShape.rectangle,
        borderStyle: RoughDrawingStyle(width: 1, color: borderColor),
        fillStyle: RoughDrawingStyle(color: filledColor),
      ),
      textStyle: TextStyle(color: textColor, fontSize: 12),
      child: child,
    );
  }
}
