import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// An outlined button with a thick hand-drawn border and no fill.
class WiredOutlinedButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const WiredOutlinedButton({super.key, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Container(
        height: 42.0,
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.rectangle,
          borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),
        ),
        child: SizedBox(
          height: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.textColor),
            onPressed: onPressed,
            child: child,
          ),
        ),
      ),
    );
  }
}
