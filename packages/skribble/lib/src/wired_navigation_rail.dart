import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A destination for the navigation rail.
class WiredNavigationRailDestination {
  /// The destination's icon.
  final IconData icon;

  /// The icon shown while the destination is selected. Defaults to [icon].
  final IconData? selectedIcon;

  /// The destination's label, also read by screen readers.
  final String label;

  const WiredNavigationRailDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// A vertical navigation rail with hand-drawn selection indicators.
///
/// Each destination takes keyboard focus, so the arrow keys move between
/// them and Enter or Space selects one, and is announced as a selectable
/// button.
class WiredNavigationRail extends HookWidget {
  /// The destinations, top to bottom.
  final List<WiredNavigationRailDestination> destinations;

  /// The index of the selected destination.
  final int selectedIndex;

  /// Called with a destination's index when it is tapped or activated.
  final ValueChanged<int>? onDestinationSelected;

  /// A widget above the destinations, such as a menu button.
  final Widget? leading;

  /// A widget at the bottom of the rail.
  final Widget? trailing;

  const WiredNavigationRail({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72,
          child: Column(
            children: [
              if (leading != null) ...[
                const SizedBox(height: 8),
                leading!,
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              for (int i = 0; i < destinations.length; i++)
                _buildDestination(
                  destinations[i],
                  i == selectedIndex,
                  () => onDestinationSelected?.call(i),
                  theme,
                ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        SizedBox(
          width: theme.inkExtent,
          child: WiredCanvas(
            painter: WiredLineBase(
              x1: 0,
              y1: 0,
              x2: 0,
              y2: double.infinity,
              strokeWidth: theme.strokeWidth,
              borderColor: theme.borderColor,
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
      ],
    );
  }

  Widget _buildDestination(
    WiredNavigationRailDestination dest,
    bool selected,
    VoidCallback onTap,
    WiredThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: WiredActivatable(
          onActivate: onTap,
          // Transparent paint makes the whole cell respond to a tap.
          child: ColoredBox(
            color: const Color(0x00000000),
            // At least 56 tall, and taller when the label grows.
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 72,
                maxWidth: 72,
                minHeight: 56,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (selected)
                        SizedBox(
                          width: 56,
                          height: 40,
                          child: WiredCanvas(
                            painter: WiredRoundedRectangleBase(
                              strokeWidth: theme.strokeWidth,
                              borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 2),
                  Text(
                    dest.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: selected
                          ? theme.textColor
                          : theme.disabledTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
