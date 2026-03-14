import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A hand-drawn input chip, corresponding to Flutter's [InputChip].
///
/// Supports selection, deletion, and an optional avatar, all wrapped
/// in a sketchy rounded-rectangle border.
class WiredInputChip extends HookWidget {
  final Widget label;
  final Widget? avatar;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;

  const WiredInputChip({
    super.key,
    required this.label,
    this.avatar,
    this.selected = false,
    this.enabled = true,
    this.onSelected,
    this.onDeleted,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: GestureDetector(
        onTap: enabled
            ? () {
                onPressed?.call();
                onSelected?.call(!selected);
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: IntrinsicWidth(
            child: SizedBox(
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: WiredCanvas(
                      painter: WiredRoundedRectangleBase(
                        borderRadius: BorderRadius.circular(16),
                        borderColor: theme.borderColor,
                      ),
                      fillerType: selected
                          ? RoughFilter.hachureFiller
                          : RoughFilter.noFiller,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (avatar != null) ...[
                          avatar!,
                          const SizedBox(width: 6),
                        ],
                        DefaultTextStyle(
                          style: TextStyle(
                            color: selected ? Colors.white : theme.textColor,
                            fontSize: 13,
                          ),
                          child: label,
                        ),
                        if (onDeleted != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onDeleted,
                            child: WiredIcon(
                              icon: Icons.close,
                              size: 16,
                              color: selected ? Colors.white : theme.textColor,
                              fillStyle: WiredIconFillStyle.solid,
                              strokeWidth: 1.1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A hand-drawn action chip, corresponding to Flutter's [ActionChip].
///
/// Tappable chip with an optional avatar and hand-drawn border.
class WiredActionChip extends HookWidget {
  final Widget label;
  final Widget? avatar;
  final VoidCallback? onPressed;

  const WiredActionChip({
    super.key,
    required this.label,
    this.avatar,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: GestureDetector(
        onTap: onPressed,
        child: IntrinsicWidth(
          child: SizedBox(
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: WiredCanvas(
                    painter: WiredRoundedRectangleBase(
                      borderRadius: BorderRadius.circular(16),
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.noFiller,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (avatar != null) ...[
                        avatar!,
                        const SizedBox(width: 6),
                      ],
                      DefaultTextStyle(
                        style: TextStyle(color: theme.textColor, fontSize: 13),
                        child: label,
                      ),
                    ],
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
