import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A bottom navigation bar item.
class WiredBottomNavItem {
  final IconData icon;
  final String label;

  const WiredBottomNavItem({required this.icon, required this.label});
}

/// A bottom navigation bar with hand-drawn selection indicator.
class WiredBottomNavigationBar extends HookWidget {
  final List<WiredBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const WiredBottomNavigationBar({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
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
              strokeWidth: 2,
              borderColor: theme.borderColor,
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
        SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++)
                _buildItem(
                  items[i],
                  i == currentIndex,
                  () => onTap?.call(i),
                  theme,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItem(
    WiredBottomNavItem item,
    bool selected,
    VoidCallback onTap,
    WiredThemeData theme,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (selected)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: WiredCanvas(
                      painter: WiredCircleBase(
                        diameterRatio: 0.9,
                        borderColor: theme.borderColor,
                      ),
                      fillerType: RoughFilter.noFiller,
                    ),
                  ),
                WiredIcon(
                  icon: item.icon,
                  color: selected ? theme.borderColor : theme.disabledTextColor,
                  size: 24,
                  fillStyle: WiredIconFillStyle.solid,
                  strokeWidth: 1.2,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? theme.textColor : theme.disabledTextColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
