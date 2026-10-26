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

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  const WiredChoiceChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.semanticLabel,
    this.seed,
  });

  /// Varies the hand behind this widget's ink. The same seed always draws
  /// the same wobble, so neighbouring shapes of the same size need different
  /// seeds to stop them reading as copies of each other. Null keeps the
  /// theme's seed.
  final int? seed;

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
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: kWiredChipHeight),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: WiredCanvas(
                      painter: WiredRoundedRectangleBase(
                        strokeWidth: theme.strokeWidth,
                        borderRadius: BorderRadius.circular(16),
                        fillColor: selected
                            ? theme.borderColor
                            : theme.fillColor,
                        borderColor: theme.borderColor,
                      ),
                      seed: seed,
                      fillerType: selected
                          ? RoughFilter.solidFiller
                          : RoughFilter.noFiller,
                      fillerConfig: FillerConfig.build(hachureGap: 3.0),
                    ),
                  ),
                  Padding(
                    padding: kWiredButtonPadding,
                    child: DefaultTextStyle.merge(
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
