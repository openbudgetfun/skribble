import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_ink_interaction.dart';
import 'motion/wired_ink_response.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// An icon button with a hand-drawn circle border.
///
/// Mirrors Material's `IconButton`. The overall frame is [size] and the glyph
/// is [iconSize], which defaults to half of the frame; [color] and [iconColor]
/// are interchangeable, with [color] taking precedence so Material's parameter
/// name works when migrating.
class WiredIconButton extends HookWidget {
  /// The icon to draw.
  final IconData icon;

  /// Called when the button is tapped. Null disables the button.
  final VoidCallback? onPressed;

  /// The width and height of the hand-drawn circle frame.
  final double size;

  /// The size of the glyph. Defaults to half of [size].
  ///
  /// Mirrors Material's `IconButton.iconSize`.
  final double? iconSize;

  /// The glyph color. Defaults to [color], then to the theme's text color.
  final Color? iconColor;

  /// The glyph color, mirroring Material's `IconButton.color`.
  ///
  /// Takes precedence over [iconColor] when both are set.
  final Color? color;

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
    this.iconSize,
    this.iconColor,
    this.color,
    this.semanticLabel,
    this.inkInteraction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final effectiveIconSize = iconSize ?? size * 0.5;
    final effectiveIconColor = color ?? iconColor ?? theme.textColor;
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
                    color: effectiveIconColor,
                    size: effectiveIconSize,
                    fillStyle: WiredIconFillStyle.solid,
                    strokeWidth: 1.4,
                  ),
                  onPressed: onPressed,
                  iconSize: effectiveIconSize,
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
