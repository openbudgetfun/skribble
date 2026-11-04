import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A bottom navigation bar item.
class WiredBottomNavItem {
  /// The item's icon.
  final IconData icon;

  /// The item's label, also read by screen readers.
  final String label;

  /// Creates a bottom navigation bar item.
  const WiredBottomNavItem({required this.icon, required this.label});
}

/// A bottom navigation bar with hand-drawn selection indicator.
///
/// The bar is at least 60 pixels tall and grows with larger text. It pads
/// itself above the home indicator of notched phones. Each item takes
/// keyboard focus and is announced as a selectable button.
class WiredBottomNavigationBar extends HookWidget {
  /// The items, in order.
  final List<WiredBottomNavItem> items;

  /// The index of the selected item.
  final int currentIndex;

  /// Called with an item's index when it is tapped or activated.
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
        SafeArea(
          top: false,
          child: ConstrainedBox(
            // At least 60 tall, and taller when the labels grow.
            constraints: const BoxConstraints(minHeight: 60),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (selected)
                      // Wide enough that the ring keeps clear of the
                      // 24-pixel icon's corners, not just its sides.
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: WiredCanvas(
                          painter: WiredCircleBase(
                            strokeWidth: theme.strokeWidth,
                            diameterRatio: 0.95,
                            borderColor: theme.borderColor,
                          ),
                          fillerType: RoughFilter.noFiller,
                        ),
                      ),
                    WiredIcon(
                      icon: item.icon,
                      color: selected
                          ? theme.borderColor
                          : theme.disabledTextColor,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
