import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A floating action button: a hand-drawn circle washed with the theme's
/// `markerColor`, with its icon in the theme's text colour.
class WiredFloatingActionButton extends HookWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  const WiredFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56.0,
    this.iconColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: buildWiredElement(
        child: WiredActivatable(
          onActivate: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                WiredCanvas(
                  painter: WiredCircleBase(
                    strokeWidth: theme.strokeWidth,
                    diameterRatio: 0.9,
                    fillColor: theme.markerColor,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.solidFiller,
                ),
                WiredIcon(
                  icon: icon,
                  color: iconColor ?? theme.textColor,
                  size: size * 0.43,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
