import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'generated/skribble_glyphs.g.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// An expandable tile with a hand-drawn border.
///
/// The expansion tile is wrapped in [Semantics] for accessibility, providing
/// screen readers with the expanded state information.
class WiredExpansionTile extends HookWidget {
  /// The tile's primary content, usually a [Text].
  final Widget title;

  /// Secondary content shown below [title].
  final Widget? subtitle;

  /// A widget shown before the title, such as an icon.
  final Widget? leading;

  /// The widgets revealed when the tile is expanded. Defaults to none.
  final List<Widget> children;

  /// Whether the tile starts expanded. Defaults to false.
  ///
  /// Only read on the first build; afterwards the tile tracks its own
  /// expanded state.
  final bool initiallyExpanded;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates an expandable tile with a hand-drawn border.
  const WiredExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.children = const [],
    this.initiallyExpanded = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isExpanded = useState(initiallyExpanded);

    return Semantics(
      label: semanticLabel,
      button: true,
      expanded: isExpanded.value,
      onTap: () => isExpanded.value = !isExpanded.value,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => isExpanded.value = !isExpanded.value,
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
                        DefaultTextStyle.merge(
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 16,
                          ),
                          child: title,
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
                  AnimatedRotation(
                    turns: isExpanded.value ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: WiredSvgIcon(
                      data: SkribbleGlyphs.chevronDown,
                      color: theme.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          if (isExpanded.value)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}
