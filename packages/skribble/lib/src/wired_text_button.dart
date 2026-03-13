import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_theme.dart';
import 'wired_base.dart';

/// A text button with a hand-drawn underline.
class WiredTextButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const WiredTextButton({super.key, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: theme.textColor),
              onPressed: onPressed,
              child: child,
            ),
            SizedBox(
              height: 2,
              child: WiredCanvas(
                painter: WiredLineBase(
                  x1: 0,
                  y1: 0,
                  x2: double.infinity,
                  y2: 0,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
