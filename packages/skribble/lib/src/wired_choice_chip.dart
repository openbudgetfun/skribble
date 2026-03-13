import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_theme.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A choice chip with a hand-drawn border and selection state.
class WiredChoiceChip extends HookWidget {
  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  const WiredChoiceChip({
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
                    ),
                    fillerType: selected
                        ? RoughFilter.hachureFiller
                        : RoughFilter.noFiller,
                    fillerConfig: FillerConfig.build(hachureGap: 3.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: selected ? theme.fillColor : theme.textColor,
                      fontSize: 13,
                    ),
                    child: label,
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
