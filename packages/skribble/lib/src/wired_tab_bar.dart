import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A tab bar with hand-drawn underline indicators.
///
/// Each label stays on one line, with an ellipsis when it does not fit, and
/// the selected tab's underline sits below it, clear of its letters. Tabs
/// take keyboard focus: the arrow keys move between them and Enter or Space
/// selects one. Screen readers hear each tab as a selectable button, such
/// as `Reviews, tab 2 of 4`.
class WiredTabBar extends HookWidget implements PreferredSizeWidget {
  /// The tab labels, in order.
  final List<String> tabs;

  /// The index of the selected tab.
  final int selectedIndex;

  /// Called with a tab's index when it is tapped or activated.
  final ValueChanged<int>? onTap;

  /// The bar's height, including its ink line.
  final double height;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  const WiredTabBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onTap,
    this.height = 48.0,
    this.semanticLabel,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel ?? 'Tab bar',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            // The ink line below takes the rest, so the bar is exactly
            // [preferredSize] tall, as an app bar's `bottom` must be.
            height: math.max(0, height - theme.inkExtent),
            child: Row(
              children: [
                for (int i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _buildTab(tabs[i], i == selectedIndex, i, theme),
                  ),
              ],
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
        ],
      ),
    );
  }

  Widget _buildTab(
    String label,
    bool selected,
    int index,
    WiredThemeData theme,
  ) {
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: '$label, tab ${index + 1} of ${tabs.length}',
      child: WiredActivatable(
        onActivate: () => onTap?.call(index),
        // Transparent paint makes the whole cell, not just its letters,
        // respond to a tap.
        child: ColoredBox(
          color: const Color(0x00000000),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    // The tab's label above already says this, with the
                    // tab's position.
                    child: ExcludeSemantics(
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? theme.textColor
                              : theme.disabledTextColor,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (selected)
                SizedBox(
                  height: theme.inkExtent,
                  child: WiredCanvas(
                    painter: WiredLineBase(
                      x1: 0,
                      y1: 0,
                      x2: double.infinity,
                      y2: 0,
                      strokeWidth: 3,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.noFiller,
                  ),
                )
              else
                SizedBox(height: theme.inkExtent),
            ],
          ),
        ),
      ),
    );
  }
}
