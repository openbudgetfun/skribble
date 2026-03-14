import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A navigation bar destination.
class WiredNavigationDestination {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const WiredNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Material 3 style navigation bar with hand-drawn rounded rect indicators.
class WiredNavigationBar extends HookWidget {
  final List<WiredNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  const WiredNavigationBar({
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 2,
          child: WiredCanvas(
            painter: WiredLineBase(
              x1: 0,
              y1: 0,
              x2: double.infinity,
              y2: 0,
              borderColor: theme.borderColor,
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      ],
    );
  }

  Widget _buildDestination(
    WiredNavigationDestination dest,
    bool selected,
    VoidCallback onTap,
    WiredThemeData theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (selected)
                  SizedBox(
                    width: 56,
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
                WiredIcon(
                  icon: selected ? (dest.selectedIcon ?? dest.icon) : dest.icon,
                  color: selected ? theme.fillColor : theme.disabledTextColor,
                  size: 24,
                  fillStyle: WiredIconFillStyle.solid,
                  strokeWidth: 1.2,
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
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
