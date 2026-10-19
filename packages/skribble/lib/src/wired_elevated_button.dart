import 'package:flutter/material.dart';

import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_button_base.dart';
import 'wired_theme.dart';

/// An elevated button: a paper face over a lightly pencilled offset shadow.
class WiredElevatedButton extends WiredButtonBase {
  /// Corner radii drawn with the theme's roughness. Use [BorderRadius.zero]
  /// for square corners.
  final BorderRadius borderRadius;

  /// Creates an elevated button. See [WiredButtonBase] for the shared
  /// parameters.
  const WiredElevatedButton({
    super.key,
    required super.child,
    super.onPressed,
    super.semanticLabel,
    super.inkInteraction,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return buildWiredButton(
      backgroundBuilder: (context) => Positioned(
        left: 2,
        top: 2,
        right: -2,
        bottom: -2,
        child: Container(
          decoration: RoughBoxDecoration(
            progress: WiredDrawTransition.progressOf(context),
            pressure: WiredInkResponse.pressureOf(context),
            drawConfig: theme.drawConfig,
            shape: borderRadius == BorderRadius.zero
                ? RoughBoxShape.rectangle
                : RoughBoxShape.roundedRectangle,
            borderRadius: borderRadius,
            borderStyle: RoughDrawingStyle(
              width: 0.5,
              color: theme.borderColor.withValues(alpha: 0.4),
            ),
            fillStyle: RoughDrawingStyle(
              color: theme.borderColor.withValues(alpha: 0.4),
            ),
            filler: HachureFiller(FillerConfig.build(hachureGap: 3)),
          ),
        ),
      ),
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
        fillStyle: RoughDrawingStyle(color: theme.fillColor),
        filler: SolidFiller(FillerConfig.build(drawConfig: theme.drawConfig)),
      ),
      textStyle: TextButton.styleFrom(foregroundColor: theme.textColor),
    );
  }
}
