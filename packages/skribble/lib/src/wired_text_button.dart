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
      builder: (context, states) => Semantics(
        label: semanticLabel,
        button: true,
        child: buildWiredElement(
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  statesController: states,
                  style: TextButton.styleFrom(foregroundColor: theme.textColor),
                  onPressed: onPressed,
                  child: child,
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
