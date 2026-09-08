import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn filled button, corresponding to Flutter's [FilledButton].
///
/// The button has an opaque ink fill with a sketchy hand-drawn border.
class WiredFilledButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;

  /// Fill color. Defaults to `borderColor`.
  final Color? fillColor;

  /// Text/icon color. Defaults to black or white for contrast with the fill.
  final Color? foregroundColor;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const WiredFilledButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fillColor,
    this.foregroundColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final fill = fillColor ?? theme.borderColor;
    final fg =
        foregroundColor ??
        (fill.computeLuminance() > 0.179 ? Colors.black : Colors.white);

    return Semantics(
      label: semanticLabel,
      button: true,
      child: buildWiredElement(
        child: Container(
          height: kWiredButtonHeight,
          decoration: RoughBoxDecoration(
            drawConfig: theme.drawConfig,
            shape: RoughBoxShape.rectangle,
            borderStyle: RoughDrawingStyle(
              width: theme.strokeWidth,
              color: theme.borderColor,
            ),
            fillStyle: RoughDrawingStyle(color: fill),
            filler: SolidFiller(),
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
      ),
    );
  }
}
