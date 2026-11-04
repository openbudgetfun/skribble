import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A list tile with a hand-drawn separator line.
///
/// The list tile is wrapped in [Semantics] for accessibility, providing
/// screen readers with the title and tap action when applicable.
class WiredListTile extends HookWidget {
  /// Widget shown before the title, such as an icon or avatar.
  final Widget? leading;

  /// Primary content of the tile, drawn at 16 logical pixels in the theme's
  /// text color.
  final Widget? title;

  /// Secondary content below [title], drawn at 14 logical pixels in the
  /// theme's disabled text color.
  final Widget? subtitle;

  /// Widget shown after the title, such as an icon or a control.
  final Widget? trailing;

  /// Called when the tile is tapped. When null, the tile is not tappable.
  final VoidCallback? onTap;

  /// <!-- {=dartTileShowDivider|trim|linePrefix:"  /// "} -->
  /// Whether a hand-drawn line is drawn below the tile. Defaults to true.
  /// <!-- {/dartTileShowDivider} -->
  final bool showDivider;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates a list tile with a hand-drawn separator line.
  const WiredListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 16)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          DefaultTextStyle.merge(
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 16,
                            ),
                            child: title!,
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          DefaultTextStyle.merge(
                            style: TextStyle(
                              color: theme.disabledTextColor,
                              fontSize: 14,
                            ),
                            child: subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 16),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
          if (showDivider)
            SizedBox(
              height: theme.inkExtent,
              child: WiredCanvas(
                painter: WiredLineBase(
                  strokeWidth: theme.strokeWidth,
                  x1: 0,
                  y1: 0,
                  x2: double.infinity,
                  y2: 0,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
        ],
      ),
    );
  }
}
