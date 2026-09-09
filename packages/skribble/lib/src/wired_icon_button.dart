import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_ink_interaction.dart';
import 'motion/wired_ink_response.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// An icon button with a hand-drawn circle border.
class WiredIconButton extends HookWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  /// Overrides the theme’s decorative ink feedback for this control.
  final WiredInkInteraction? inkInteraction;

  const WiredIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48.0,
    this.iconColor,
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
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                WiredCanvas(
                  painter: WiredCircleBase(
                    strokeWidth: theme.strokeWidth,
                    diameterRatio: 0.85,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
                IconButton(
                  statesController: states,
                  icon: WiredIcon(
                    icon: icon,
                    color: iconColor ?? theme.textColor,
                    size: size * 0.5,
                    fillStyle: WiredIconFillStyle.solid,
                    strokeWidth: 1.4,
                  ),
                  onPressed: onPressed,
                  iconSize: size * 0.5,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(maxWidth: size, maxHeight: size),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
