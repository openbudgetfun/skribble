import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_button_base.dart';
import 'wired_theme.dart';

/// A hand-drawn filled button, corresponding to Flutter's [FilledButton].
///
/// The button is washed with the theme's highlighter, its `markerColor`,
/// inside a sketchy hand-drawn border, like a button coloured in with a
/// marker. Pass [fillColor] for a stronger or branded colour.
class WiredFilledButton extends WiredButtonBase {
  /// Fill color. Defaults to the theme's `markerColor`.
  final Color? fillColor;

  /// Text/icon color. Defaults to whichever of the theme's text and paper
  /// colours contrasts more with the fill.
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
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final fill = fillColor ?? theme.markerColor;
    final fg =
        foregroundColor ?? _contrasting(fill, theme.textColor, theme.fillColor);

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

/// Whichever of [a] and [b] has the higher contrast ratio against [fill].
Color _contrasting(Color fill, Color a, Color b) {
  double ratio(Color c) {
    final l1 = fill.computeLuminance();
    final l2 = c.computeLuminance();
    return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
  }

  return ratio(a) >= ratio(b) ? a : b;
}
