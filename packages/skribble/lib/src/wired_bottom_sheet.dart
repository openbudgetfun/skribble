import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A bottom sheet with a hand-drawn top border and rounded corners.
class WiredBottomSheet extends HookWidget {
  final Widget child;

  const WiredBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 2,
          child: WiredCanvas(
            painter: WiredLineBase(
              x1: 0,
              y1: 0,
              x2: double.infinity,
              y2: 0,
              strokeWidth: 2,
              borderColor: theme.borderColor,
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
        // Drag handle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: SizedBox(
              width: 40,
              height: 4,
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(
                  borderRadius: BorderRadius.circular(2),
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.hachureFiller,
                fillerConfig: FillerConfig.build(hachureGap: 1.0),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Shows a modal bottom sheet with hand-drawn styling.
Future<T?> showWiredBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: (context) => WiredBottomSheet(child: builder(context)),
  );
}
