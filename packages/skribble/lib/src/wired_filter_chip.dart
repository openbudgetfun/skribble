import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A filter chip with a hand-drawn border and optional checkmark.
class WiredFilterChip extends HookWidget {
  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  const WiredFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: GestureDetector(
        onTap: () => onSelected?.call(!selected),
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
                      fillColor: selected ? theme.borderColor : theme.fillColor,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: selected
                        ? RoughFilter.hachureFiller
                        : RoughFilter.noFiller,
                    fillerConfig: FillerConfig.build(hachureGap: 3.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        WiredIcon(
                          icon: Icons.check,
                          size: 16,
                          color: theme.fillColor,
                          fillStyle: WiredIconFillStyle.solid,
                          strokeWidth: 1.1,
                        ),
                        const SizedBox(width: 4),
                      ],
                      DefaultTextStyle(
                        style: TextStyle(
                          color: selected ? theme.fillColor : theme.textColor,
                          fontSize: 13,
                        ),
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
