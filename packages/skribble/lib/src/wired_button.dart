import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_draw.dart';
import 'motion/wired_ink_interaction.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn button with a sketchy rectangle border.
///
/// Reads colors from the nearest [WiredTheme] ancestor, falling back
/// to the default constants when no theme is provided.
class WiredButton extends HookWidget {
  /// The button label.
  final Widget child;

  /// Called when the button is tapped.
  final void Function() onPressed;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  /// Overrides the theme’s decorative ink feedback for this control.
  final WiredInkInteraction? inkInteraction;

  /// Corner radii drawn with the theme's roughness. Use [BorderRadius.zero]
  /// for square corners.
  final BorderRadius borderRadius;

  const WiredButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.inkInteraction,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return WiredInkResponse(
      interaction: inkInteraction,
      builder: (context, states) => Semantics(
        label: semanticLabel,
        button: true,
        child: buildWiredElement(
          child: Container(
            padding: EdgeInsets.zero,
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
            ),
            child: SizedBox(
              height: double.infinity,
              child: TextButton(
                statesController: states,
                style: TextButton.styleFrom(foregroundColor: theme.textColor),
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
