import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A navigation bar destination.
class WiredNavigationDestination {
  /// <!-- {=dartDestinationIcon|trim|linePrefix:"  /// "} -->
  /// The icon shown when this destination is not selected.
  /// <!-- {/dartDestinationIcon} -->
  final IconData icon;

  /// <!-- {=dartDestinationSelectedIcon|trim|linePrefix:"  /// "} -->
  /// The icon shown when this destination is selected. Defaults to [icon].
  /// <!-- {/dartDestinationSelectedIcon} -->
  final IconData? selectedIcon;

  /// The destination's label, also read by screen readers.
  final String label;

  /// Creates a navigation bar destination.
  const WiredNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Material 3 style navigation bar with hand-drawn rounded rect indicators.
///
/// The bar is at least 80 pixels tall and grows with larger text. It pads
/// itself above the home indicator of notched phones. Each destination
/// takes keyboard focus and is announced as a selectable button.
class WiredNavigationBar extends HookWidget {
  /// The destinations, in order.
  final List<WiredNavigationDestination> destinations;

  /// The index of the selected destination.
  final int selectedIndex;

  /// Called with a destination's index when it is tapped or activated.
  final ValueChanged<int>? onDestinationSelected;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates a navigation bar with hand-drawn selection indicators.
  const WiredNavigationBar({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel ?? 'Navigation bar',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          SafeArea(
            top: false,
            child: ConstrainedBox(
              // At least 80 tall, and taller when the labels grow.
              constraints: const BoxConstraints(minHeight: 80),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < destinations.length; i++)
                      _buildDestination(
                        destinations[i],
                        i == selectedIndex,
                        () => onDestinationSelected?.call(i),
                        theme,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestination(
    WiredNavigationDestination dest,
    bool selected,
    VoidCallback onTap,
    WiredThemeData theme,
  ) {
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: WiredActivatable(
        onActivate: onTap,
        // Transparent paint makes the whole cell respond to a tap.
        child: ColoredBox(
          color: const Color(0x00000000),
          child: SizedBox(
            width: 72,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (selected)
                      SizedBox(
                        width: 64,
                        height: 34,
                        child: WiredCanvas(
                          painter: WiredRoundedRectangleBase(
                            strokeWidth: theme.strokeWidth,
                            borderRadius: BorderRadius.circular(17),
                            fillColor: theme.markerColor,
                            borderColor: theme.borderColor,
                          ),
                          fillerType: RoughFilter.solidFiller,
                        ),
                      ),
                    WiredIcon(
                      icon: selected
                          ? (dest.selectedIcon ?? dest.icon)
                          : dest.icon,
                      color: selected
                          ? theme.textColor
                          : theme.disabledTextColor,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dest.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? theme.textColor : theme.disabledTextColor,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
