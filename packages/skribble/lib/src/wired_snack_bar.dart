import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_theme.dart';

/// Shows a hand-drawn snack bar.
void showWiredSnackBar(
  BuildContext context, {
  required Widget content,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: content,
      duration: duration,
      action: action,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(),
      padding: EdgeInsets.zero,
    ),
  );
}

/// A snack bar content wrapper with a hand-drawn border.
class WiredSnackBarContent extends HookWidget {
  final Widget child;
  final Widget? action;

  const WiredSnackBarContent({super.key, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: RoughBoxDecoration(
        shape: RoughBoxShape.rectangle,
        borderStyle: RoughDrawingStyle(width: 1.5, color: theme.borderColor),
        fillStyle: RoughDrawingStyle(color: theme.fillColor),
        filler: SolidFiller(FillerConfig.build()),
      ),
      child: Row(
        children: [
          Expanded(
            child: DefaultTextStyle(
              style: TextStyle(color: theme.textColor, fontSize: 14),
              child: child,
            ),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      ),
    );
  }
}
