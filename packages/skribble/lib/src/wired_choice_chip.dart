import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A choice chip with a hand-drawn border and selection state.
///
/// The choice chip is wrapped in [Semantics] for accessibility, providing
/// screen readers with the selected state information.
class WiredChoiceChip extends HookWidget {
  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredChoiceChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel,
      selected: selected,
      button: true,
      onTap: () => onSelected?.call(!selected),
      child: buildWiredElement(
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
      ),
    );
  }
}
