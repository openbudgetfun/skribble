import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn filled button, corresponding to Flutter's [FilledButton].
///
/// The button has a solid hachure fill with the sketchy hand-drawn border.
class WiredFilledButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;

  /// Fill color for the hachure pattern. Defaults to `borderColor`.
  final Color? fillColor;

  /// Text/icon color. Defaults to white when filled.
  final Color? foregroundColor;

  const WiredFilledButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fillColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final fill = fillColor ?? theme.borderColor;
    final fg = foregroundColor ?? Colors.white;

    return buildWiredElement(
      child: Container(
        height: 42.0,
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.rectangle,
          borderStyle: RoughDrawingStyle(width: 1, color: theme.borderColor),
          fillStyle: RoughDrawingStyle(color: fill),
          filler: HachureFiller(FillerConfig.build(hachureGap: 2)),
        ),
        child: SizedBox(
          height: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(foregroundColor: fg),
            onPressed: onPressed,
            child: child,
          ),
        ),
      ),
    );
  }
}
