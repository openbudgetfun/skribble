import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_draw.dart';
import 'motion/wired_ink_interaction.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// An elevated button with hand-drawn fill and slight offset shadow.
class WiredElevatedButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  /// Overrides the theme’s decorative ink feedback for this control.
  final WiredInkInteraction? inkInteraction;

  const WiredElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.inkInteraction,
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
          child: Stack(
            children: [
              // Shadow offset
              Positioned(
                left: 2,
                top: 2,
                right: -2,
                bottom: -2,
                child: Container(
                  decoration: RoughBoxDecoration(
                    progress: WiredDrawTransition.progressOf(context),
                    pressure: WiredInkResponse.pressureOf(context),
                    drawConfig: theme.drawConfig,
                    shape: RoughBoxShape.rectangle,
                    borderStyle: RoughDrawingStyle(
                      width: 0.5,
                      color: theme.borderColor,
                    ),
                    fillStyle: RoughDrawingStyle(color: theme.borderColor),
                    filler: HachureFiller(FillerConfig.build(hachureGap: 2)),
                  ),
                ),
              ),
              Container(
                height: kWiredButtonHeight,
                decoration: RoughBoxDecoration(
                  progress: WiredDrawTransition.progressOf(context),
                  pressure: WiredInkResponse.pressureOf(context),
                  drawConfig: theme.drawConfig,
                  shape: RoughBoxShape.rectangle,
                  borderStyle: RoughDrawingStyle(
                    width: theme.strokeWidth,
                    color: theme.borderColor,
                  ),
                  fillStyle: RoughDrawingStyle(color: theme.fillColor),
                  filler: HachureFiller(FillerConfig.build(hachureGap: 3)),
                ),
                child: SizedBox(
                  height: double.infinity,
                  child: TextButton(
                    statesController: states,
                    style: TextButton.styleFrom(
                      foregroundColor: theme.textColor,
                    ),
                    onPressed: onPressed,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
