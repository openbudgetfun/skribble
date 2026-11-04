import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'generated/skribble_glyphs.g.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A hand-drawn input chip, corresponding to Flutter's [InputChip].
///
/// Supports selection, deletion, and an optional avatar, all wrapped
/// in a sketchy rounded-rectangle border.
///
/// The input chip is wrapped in [Semantics] for accessibility, providing
/// screen readers with the selected state and delete action.
class WiredInputChip extends HookWidget {
  /// <!-- {=dartChipLabel|trim|linePrefix:"  /// "} -->
  /// The chip's label, usually a [Text].
  /// <!-- {/dartChipLabel} -->
  ///
  /// Shown on one line, clipped with an ellipsis.
  final Widget label;

  /// Optional widget shown before the [label], such as a WiredAvatar.
  final Widget? avatar;

  /// Whether the chip is selected. Selected chips are filled with ink and draw
  /// their label in white. Defaults to false.
  final bool selected;

  /// Whether the chip responds to taps. Disabled chips are drawn at half
  /// opacity. Defaults to true.
  final bool enabled;

  /// Called with the opposite of [selected] when the chip is tapped.
  final ValueChanged<bool>? onSelected;

  /// Called when the delete icon is tapped. When null, no delete icon is shown.
  final VoidCallback? onDeleted;

  /// Called when the chip is tapped, before [onSelected].
  final VoidCallback? onPressed;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates a hand-drawn input chip.
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel,
      selected: selected,
      button: enabled,
      onTap: enabled
          ? () {
              onPressed?.call();
              onSelected?.call(!selected);
            }
          : null,
      child: buildWiredElement(
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
                        fillerType: selected
                            ? RoughFilter.solidFiller
                            : RoughFilter.noFiller,
                      ),
                    ),
                    Padding(
                      padding: kWiredInkPadding,
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
                                color: selected
                                    ? Colors.white
                                    : theme.textColor,
                                fontSize: 13,
                              ),
                              child: label,
                            ),
                          ),
                          if (onDeleted != null) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: onDeleted,
                              child: WiredSvgIcon(
                                data: SkribbleGlyphs.close,
                                size: 16,
                                color: selected
                                    ? Colors.white
                                    : theme.textColor,
                                weight: 300,
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
/// screen readers with the tap action.
class WiredActionChip extends HookWidget {
  /// <!-- {=dartChipLabel|trim|linePrefix:"  /// "} -->
  /// The chip's label, usually a [Text].
  /// <!-- {/dartChipLabel} -->
  final Widget label;

  /// Optional widget shown before the [label], such as a WiredAvatar.
  final Widget? avatar;

  /// Called when the chip is tapped.
  final VoidCallback? onPressed;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates a hand-drawn action chip.
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
      onTap: onPressed,
      child: buildWiredElement(
        child: GestureDetector(
          onTap: onPressed,
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
                    padding: kWiredInkPadding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (avatar != null) ...[
                          avatar!,
                          const SizedBox(width: 6),
                        ],
                        DefaultTextStyle.merge(
                          style: TextStyle(
                            color: theme.textColor,
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
      ),
    );
  }
}
