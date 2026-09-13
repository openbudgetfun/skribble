import 'package:flutter/material.dart';

import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_button_base.dart';
import 'wired_theme.dart';

/// A hand-drawn filled button, corresponding to Flutter's [FilledButton].
///
/// The button has an opaque ink fill with a sketchy hand-drawn border.
class WiredFilledButton extends WiredButtonBase {
  /// Fill color. Defaults to `borderColor`.
  final Color? fillColor;

  /// Text/icon color. Defaults to black or white for contrast with the fill.
  final Color? foregroundColor;

  /// Corner radii drawn with the theme's roughness. Use [BorderRadius.zero]
  /// for square corners.
  final BorderRadius borderRadius;

  /// Creates a filled button. See [WiredButtonBase] for the shared
  /// parameters.
  const WiredFilledButton({
    super.key,
    required super.child,
    super.onPressed,
    this.fillColor,
    this.foregroundColor,
    super.semanticLabel,
    super.inkInteraction,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final fill = fillColor ?? theme.borderColor;
    final fg =
        foregroundColor ??
        (fill.computeLuminance() > 0.179 ? Colors.black : Colors.white);

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
        fillStyle: RoughDrawingStyle(color: fill),
        filler: SolidFiller(FillerConfig.build(drawConfig: theme.drawConfig)),
      ),
      textStyle: TextButton.styleFrom(
        foregroundColor: fg,
        disabledForegroundColor: fg.withValues(alpha: 0.75),
      ),
    );
  }
}
