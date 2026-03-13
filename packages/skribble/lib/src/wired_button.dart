import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn button with a sketchy rectangle border.
///
/// Reads colors from the nearest [WiredTheme] ancestor, falling back
/// to the default constants when no theme is provided.
class WiredButton extends HookWidget {
  /// The button label.
  final Widget child;

  /// Called when the button is tapped.
  final void Function() onPressed;

  const WiredButton({super.key, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return buildWiredElement(
      child: Container(
        padding: EdgeInsets.zero,
        height: kWiredButtonHeight,
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.rectangle,
          borderStyle: RoughDrawingStyle(width: 1, color: theme.borderColor),
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
