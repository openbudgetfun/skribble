import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_bottom_nav.dart';
import 'wired_theme.dart';

/// A hand-drawn tab bar corresponding to Flutter's [CupertinoTabBar].
///
/// Provides the same API as [CupertinoTabBar] with a sketchy hand-drawn
/// top border and selection indicator.
class WiredCupertinoTabBar extends HookWidget {
  /// The tab items. Should have at least two items.
  final List<BottomNavigationBarItem> items;

  /// The currently selected tab index.
  final int currentIndex;

  /// Called with a tab's index when it is tapped or activated with Enter or
  /// Space. Null disables the tabs.
  final ValueChanged<int>? onTap;

  /// The active icon/label color.
  final Color activeColor;

  /// The inactive icon/label color.
  final Color inactiveColor;

  /// Background color of the tab bar.
  final Color? backgroundColor;

  /// The least height of the tab bar, above the bottom safe area. The bar
  /// grows past it when larger text needs the room.
  final double height;

  /// The size of tab bar icons.
  final double iconSize;

  /// Creates a hand-drawn tab bar.
  const WiredCupertinoTabBar({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.activeColor = CupertinoColors.activeBlue,
    this.inactiveColor = CupertinoColors.inactiveGray,
    this.backgroundColor,
    this.height = 50,
    this.iconSize = 26,
  });

  /// Creates tabs from skribble's icon-and-label destinations.
  /// [items] must contain at least two destinations.
  factory WiredCupertinoTabBar.destinations({
    Key? key,
    required List<WiredBottomNavItem> items,
    int currentIndex = 0,
    ValueChanged<int>? onTap,
    Color activeColor = CupertinoColors.activeBlue,
    Color inactiveColor = CupertinoColors.inactiveGray,
    Color? backgroundColor,
    double height = 50,
    double iconSize = 26,
  }) => WiredCupertinoTabBar(
    key: key,
    items: [
      for (final item in items)
        BottomNavigationBarItem(icon: Icon(item.icon), label: item.label),
    ],
    currentIndex: currentIndex,
    onTap: onTap,
    activeColor: activeColor,
    inactiveColor: inactiveColor,
    backgroundColor: backgroundColor,
    height: height,
    iconSize: iconSize,
  );

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final bgColor = backgroundColor ?? theme.fillColor;

    return buildWiredElement(
      // The background reaches down through the bottom safe area.
      child: ColoredBox(
        color: bgColor,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: Stack(
            children: [
              // Top border line (sketchy)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: theme.inkExtent,
                child: WiredCanvas(
                  painter: WiredLineBase(
                    strokeWidth: theme.strokeWidth,
                    x1: 0,
                    y1: 1,
                    x2: double.maxFinite,
                    y2: 1,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              // Tab items. The bar is at least [height] tall and grows with
              // larger text instead of overflowing.
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: Semantics(
                            container: true,
                            button: true,
                            selected: i == currentIndex,
                            inMutuallyExclusiveGroup: true,
                            enabled: onTap != null,
                            child: WiredActivatable(
                              onActivate: onTap == null
                                  ? null
                                  : () => onTap!(i),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: _buildTabItem(i),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final selected = index == currentIndex;
    final color = selected ? activeColor : inactiveColor;
    final item = items[index];
    final icon = selected ? item.activeIcon : item.icon;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        IconTheme(
          data: IconThemeData(color: color, size: iconSize),
          child: icon,
        ),
        if (item.label != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              item.label!,
              style: TextStyle(fontSize: 10, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 4),
      ],
    );
  }
}
