import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_theme.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A hand-drawn tab bar corresponding to Flutter's [CupertinoTabBar].
///
/// Provides the same API as [CupertinoTabBar] with a sketchy hand-drawn
/// top border and selection indicator.
class WiredCupertinoTabBar extends HookWidget {
  /// The tab items. Should have at least two items.
  final List<BottomNavigationBarItem> items;

  /// The currently selected tab index.
  final int currentIndex;

  /// Called when a tab is tapped.
  final ValueChanged<int>? onTap;

  /// The active icon/label color.
  final Color activeColor;

  /// The inactive icon/label color.
  final Color inactiveColor;

  /// Background color of the tab bar.
  final Color? backgroundColor;

  /// Height of the tab bar.
  final double height;

  /// The size of tab bar icons.
  final double iconSize;

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

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final bgColor = backgroundColor ?? theme.fillColor;

    return buildWiredElement(
      child: SizedBox(
        height: height + MediaQuery.of(context).padding.bottom,
        child: Stack(
          children: [
            // Background
            Positioned.fill(child: Container(color: bgColor)),
            // Top border line (sketchy)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 3,
              child: WiredCanvas(
                painter: WiredLineBase(
                  x1: 0,
                  y1: 1,
                  x2: double.maxFinite,
                  y2: 1,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            // Tab items
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: height,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTap?.call(i),
                        behavior: HitTestBehavior.opaque,
                        child: _buildTabItem(i),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final selected = index == currentIndex;
    final color = selected ? activeColor : inactiveColor;
    final item = items[index];
    final icon = selected ? (item.activeIcon ?? item.icon) : item.icon;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
      ],
    );
  }
}
