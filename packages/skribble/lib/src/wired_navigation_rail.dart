import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A destination for the navigation rail.
class WiredNavigationRailDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const WiredNavigationRailDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// A vertical navigation rail with hand-drawn selection indicators.
class WiredNavigationRail extends HookWidget {
  final List<WiredNavigationRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Widget? leading;
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
          width: 2,
          child: WiredCanvas(
            painter: WiredLineBase(
              x1: 0,
              y1: 0,
              x2: 0,
              y2: double.infinity,
              strokeWidth: 2,
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
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 72,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (selected)
                    SizedBox(
                      width: 48,
                      height: 28,
                      child: WiredCanvas(
                        painter: WiredRoundedRectangleBase(
                          borderRadius: BorderRadius.circular(14),
                          fillColor: theme.borderColor,
                          borderColor: theme.borderColor,
                        ),
                        fillerType: RoughFilter.hachureFiller,
                        fillerConfig: FillerConfig.build(hachureGap: 2.0),
                      ),
                    ),
                  Icon(
                    selected ? (dest.selectedIcon ?? dest.icon) : dest.icon,
                    color: selected ? theme.fillColor : theme.disabledTextColor,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                dest.label,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? theme.textColor : theme.disabledTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
