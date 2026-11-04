import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A choice chip with a hand-drawn border and selection state.
///
/// The choice chip is wrapped in [Semantics] for accessibility, providing
/// screen readers with the selected and enabled state. It joins focus
/// traversal while enabled and toggles with a tap, Enter, or Space.
class WiredChoiceChip extends HookWidget {
  /// The chip label.
  final Widget label;

  /// Whether the chip is selected.
  final bool selected;

  /// Called with the toggled selection when the chip is activated.
  ///
  /// Null disables the chip: it ignores taps and keys, leaves focus
  /// traversal, and reports itself disabled.
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
    final onActivate = onSelected == null ? null : () => onSelected!(!selected);
    return Semantics(
      label: semanticLabel,
      selected: selected,
      button: true,
      enabled: onActivate != null,
      child: buildWiredElement(
        child: WiredActivatable(
          onActivate: onActivate,
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
                      // A semantic label replaces the label's own text, not joins it.
                      child: semanticLabel == null
                          ? label
                          : ExcludeSemantics(child: label),
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
