import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_ink_response.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A text button with a hand-drawn underline.
class WiredTextButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  const WiredTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return WiredInkResponse(
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
