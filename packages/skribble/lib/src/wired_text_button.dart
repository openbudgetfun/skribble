import 'package:flutter/material.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_ink_response.dart';
import 'wired_base.dart';
import 'wired_button_base.dart';
import 'wired_theme.dart';

/// A text button with a hand-drawn underline.
class WiredTextButton extends WiredButtonBase {
  /// Creates a text button. See [WiredButtonBase] for the shared parameters.
  const WiredTextButton({
    super.key,
    required super.child,
    super.onPressed,
    super.semanticLabel,
    super.inkInteraction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return WiredInkResponse(
      interaction: inkInteraction,
      builder: (context, states) => wiredButtonSemantics(
        label: semanticLabel,
        enabled: onPressed != null,
        labelChild: child,
        control: (label) => buildWiredElement(
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  statesController: states,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.textColor,
                    disabledForegroundColor: theme.disabledTextColor,
                    // The same room around the label on every platform and
                    // at every text scale, so the underline never touches
                    // it. (Material shrinks its own padding to nothing at
                    // large text scales and on desktop densities.)
                    padding: kWiredInkPadding,
                    visualDensity: VisualDensity.standard,
                  ),
                  onPressed: onPressed,
                  child: label,
                ),
                SizedBox(
                  height: theme.inkExtent,
                  child: WiredCanvas(
                    painter: WiredLineBase(
                      strokeWidth: theme.strokeWidth,
                      x1: 0,
                      y1: 0,
                      x2: double.infinity,
                      y2: 0,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.noFiller,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
