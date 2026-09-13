import 'package:flutter/material.dart';

import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_button_base.dart';
import 'wired_theme.dart';

/// A hand-drawn button with a sketchy rectangle border.
///
/// Reads colors from the nearest [WiredTheme] ancestor, falling back
/// to the default constants when no theme is provided.
class WiredButton extends WiredButtonBase {
  /// Corner radii drawn with the theme's roughness. Use [BorderRadius.zero]
  /// for square corners.
  final BorderRadius borderRadius;

  /// Creates a sketchy button. See [WiredButtonBase] for the shared
  /// parameters.
  const WiredButton({
    super.key,
    required super.child,
    super.onPressed,
    super.semanticLabel,
    super.inkInteraction,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return buildWiredButton(
      decorationBuilder: (context) => RoughBoxDecoration(
        progress: WiredDrawTransition.progressOf(context),
        pressure: WiredInkResponse.pressureOf(context),
        drawConfig: theme.drawConfig,
        shape: borderRadius == BorderRadius.zero
            ? RoughBoxShape.rectangle
            : RoughBoxShape.roundedRectangle,
        borderRadius: borderRadius,
        borderStyle: RoughDrawingStyle(
          width: theme.strokeWidth,
          color: theme.borderColor,
        ),
      ),
      textStyle: TextButton.styleFrom(
        foregroundColor: theme.textColor,
        disabledForegroundColor: theme.disabledTextColor,
      ),
    );
  }
}
