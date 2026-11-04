import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'generated/skribble_glyphs.g.dart';
import 'rough/skribble_rough.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A filter chip with a hand-drawn border and optional checkmark.
///
/// The filter chip is wrapped in [Semantics] for accessibility, providing
/// screen readers with the selected and enabled state. It joins focus
/// traversal while enabled and toggles with a tap, Enter, or Space.
class WiredFilterChip extends HookWidget {
  /// The chip label.
  final Widget label;

  /// Whether the filter is on. A selected chip shows a checkmark.
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

  const WiredFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
    this.semanticLabel,
  });

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
                      fillerType: selected
                          ? RoughFilter.solidFiller
                          : RoughFilter.noFiller,
                      fillerConfig: FillerConfig.build(hachureGap: 3.0),
                    ),
                  ),
                  Padding(
                    padding: kWiredButtonPadding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          WiredSvgIcon(
                            data: SkribbleGlyphs.check,
                            size: 16,
                            color: theme.fillColor,
                            weight: 300,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: DefaultTextStyle.merge(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selected
                                  ? theme.fillColor
                                  : theme.textColor,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
