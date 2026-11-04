import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A bottom navigation bar item.
class WiredBottomNavItem {
  /// The icon drawn for this destination, at 24 logical pixels.
  final IconData icon;

  /// The text shown under the icon.
  final String label;

  /// Creates a bottom navigation bar item.
  const WiredBottomNavItem({required this.icon, required this.label});
}

/// A bottom navigation bar with hand-drawn selection indicator.
class WiredBottomNavigationBar extends HookWidget {
  /// The destinations, laid out evenly from start to end.
  final List<WiredBottomNavItem> items;

  /// The index into [items] of the selected destination, which gets a
  /// hand-drawn circle. Defaults to 0.
  final int currentIndex;

  /// Called with the index of the tapped item. The bar does not change
  /// [currentIndex] itself; rebuild with the new index.
  final ValueChanged<int>? onTap;

  /// Creates a hand-drawn bottom navigation bar.
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
          height: theme.inkExtent,
          child: WiredCanvas(
            painter: WiredLineBase(
              x1: 0,
              y1: 0,
              x2: double.infinity,
              y2: 0,
              strokeWidth: theme.strokeWidth,
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
                        strokeWidth: theme.strokeWidth,
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
