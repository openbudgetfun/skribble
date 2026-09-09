import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_draw.dart';
import 'motion/wired_ink_interaction.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn filled button, corresponding to Flutter's [FilledButton].
///
/// The button has an opaque ink fill with a sketchy hand-drawn border.
class WiredFilledButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;

  /// Fill color. Defaults to `borderColor`.
  final Color? fillColor;

  /// Text/icon color. Defaults to black or white for contrast with the fill.
  final Color? foregroundColor;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  /// Overrides the theme’s decorative ink feedback for this control.
  final WiredInkInteraction? inkInteraction;

  /// Corner radii drawn with the theme's roughness. Use [BorderRadius.zero]
  /// for square corners.
  final BorderRadius borderRadius;

  const WiredFilledButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fillColor,
    this.foregroundColor,
    this.semanticLabel,
    this.inkInteraction,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final fill = fillColor ?? theme.borderColor;
    final fg =
        foregroundColor ??
        (fill.computeLuminance() > 0.179 ? Colors.black : Colors.white);

    return WiredInkResponse(
      interaction: inkInteraction,
      builder: (context, states) => Semantics(
        label: semanticLabel,
        button: true,
        child: buildWiredElement(
          child: Container(
            height: kWiredButtonHeight,
            decoration: RoughBoxDecoration(
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
              filler: SolidFiller(
                FillerConfig.build(drawConfig: theme.drawConfig),
              ),
            ),
            child: SizedBox(
              height: double.infinity,
              child: TextButton(
                statesController: states,
                style: TextButton.styleFrom(
                  foregroundColor: fg,
                  disabledForegroundColor: fg.withValues(alpha: 0.75),
                ),
                onPressed: onPressed,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
