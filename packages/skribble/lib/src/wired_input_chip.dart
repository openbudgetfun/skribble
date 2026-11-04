import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_chip_delete_button.dart';
import 'wired_theme.dart';

/// A hand-drawn input chip, corresponding to Flutter's [InputChip].
///
/// Supports selection, deletion, and an optional avatar, all wrapped
/// in a sketchy rounded-rectangle border.
///
/// The input chip is wrapped in [Semantics] for accessibility, providing
/// screen readers with the selected and enabled state. It joins focus
/// traversal when it can be pressed or selected, and activates with a tap,
/// Enter, or Space. The close mark is a separate, focusable button labelled
/// [deleteButtonSemanticLabel].
class WiredInputChip extends HookWidget {
  /// The chip label.
  final Widget label;

  /// A widget shown before the label, such as an avatar.
  final Widget? avatar;

  /// Whether the chip is selected. A selected chip is filled with ink and
  /// writes its label in the paper colour.
  final bool selected;

  /// Whether the chip responds to input. A disabled chip is drawn at half
  /// opacity, ignores taps and keys, and leaves focus traversal.
  final bool enabled;

  /// Called with the toggled selection when the chip is activated.
  final ValueChanged<bool>? onSelected;

  /// Called when the close mark is activated. Adds the close mark when set.
  final VoidCallback? onDeleted;

  /// Called when the chip is activated, before [onSelected].
  final VoidCallback? onPressed;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// The label read for the close mark's button. Defaults to `Delete`.
  final String? deleteButtonSemanticLabel;

  const WiredInputChip({
    super.key,
    required this.label,
    this.avatar,
    this.selected = false,
    this.enabled = true,
    this.onSelected,
    this.onDeleted,
    this.onPressed,
    this.semanticLabel,
    this.deleteButtonSemanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final canActivate = enabled && (onPressed != null || onSelected != null);
    final onActivate = canActivate
        ? () {
            onPressed?.call();
            onSelected?.call(!selected);
          }
        : null;
    // Selected chips use the same solid ink as choice and filter chips, with
    // the label in the paper colour so it reads in light and dark themes.
    final foreground = selected ? theme.fillColor : theme.textColor;

    return Semantics(
      label: semanticLabel,
      selected: selected,
      button: canActivate,
      enabled: canActivate,
      child: buildWiredElement(
        child: WiredActivatable(
          onActivate: onActivate,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
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
                      ),
                    ),
                    Padding(
                      padding: kWiredButtonPadding,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (avatar != null) ...[
                            avatar!,
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: DefaultTextStyle.merge(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: foreground,
                                fontSize: 13,
                              ),
                              // A semantic label replaces the label's own text, not joins it.
                              child: semanticLabel == null
                                  ? label
                                  : ExcludeSemantics(child: label),
                            ),
                          ),
                          if (onDeleted != null) ...[
                            const SizedBox(width: 4),
                            IgnorePointer(
                              ignoring: !enabled,
                              child: ExcludeFocus(
                                excluding: !enabled,
                                child: WiredChipDeleteButton(
                                  onDeleted: onDeleted!,
                                  color: foreground,
                                  semanticLabel: deleteButtonSemanticLabel,
                                ),
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
      ),
    );
  }
}

/// A hand-drawn action chip, corresponding to Flutter's [ActionChip].
///
/// Tappable chip with an optional avatar and hand-drawn border.
///
/// The action chip is wrapped in [Semantics] for accessibility, providing
/// screen readers with the tap action and enabled state. It joins focus
/// traversal while enabled and activates with a tap, Enter, or Space.
class WiredActionChip extends HookWidget {
  /// The chip label.
  final Widget label;

  /// A widget shown before the label, such as an icon.
  final Widget? avatar;

  /// Called when the chip is activated. Null disables the chip.
  final VoidCallback? onPressed;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  const WiredActionChip({
    super.key,
    required this.label,
    this.avatar,
    this.onPressed,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: buildWiredElement(
        child: WiredActivatable(
          onActivate: onPressed,
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
                        borderColor: theme.borderColor,
                      ),
                      fillerType: RoughFilter.noFiller,
                    ),
                  ),
                  Padding(
                    padding: kWiredButtonPadding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (avatar != null) ...[
                          avatar!,
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: DefaultTextStyle.merge(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textColor,
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
