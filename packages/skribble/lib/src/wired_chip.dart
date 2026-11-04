import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_chip_delete_button.dart';
import 'wired_theme.dart';

/// A chip with a hand-drawn rounded rectangle border.
///
/// The chip is wrapped in [Semantics] for accessibility. The chip itself is
/// not a button; when [onDeleted] is set, its close mark is a separate,
/// focusable button labelled [deleteButtonSemanticLabel].
class WiredChip extends HookWidget {
  /// The chip label.
  final Widget label;

  /// A widget shown before the label, such as an avatar.
  final Widget? avatar;

  /// Called when the close mark is tapped or activated with Enter or Space.
  /// Adds the close mark when set.
  final VoidCallback? onDeleted;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// The label read for the close mark's button. Defaults to `Delete`.
  final String? deleteButtonSemanticLabel;

  const WiredChip({
    super.key,
    required this.label,
    this.avatar,
    this.onDeleted,
    this.semanticLabel,
    this.seed,
    this.deleteButtonSemanticLabel,
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
      container: true,
      label: semanticLabel,
      child: buildWiredElement(
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
                    seed: seed,
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
                        const SizedBox(width: 8),
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
                      if (onDeleted != null) ...[
                        const SizedBox(width: 4),
                        WiredChipDeleteButton(
                          onDeleted: onDeleted!,
                          color: theme.textColor,
                          semanticLabel: deleteButtonSemanticLabel,
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
    );
  }
}
