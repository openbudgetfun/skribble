import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// An outlined button with a thick hand-drawn border and no fill.
class WiredOutlinedButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const WiredOutlinedButton({
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
          child: Container(
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
