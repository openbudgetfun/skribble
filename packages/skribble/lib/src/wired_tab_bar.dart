import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A tab bar with hand-drawn underline indicators.
class WiredTabBar extends HookWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final double height;

  const WiredTabBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onTap,
    this.height = 48.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height - 2,
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
      ],
    );
  }

  Widget _buildTab(
    String label,
    bool selected,
    int index,
    WiredThemeData theme,
  ) {
    return GestureDetector(
      onTap: () => onTap?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? theme.textColor : theme.disabledTextColor,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (selected)
            SizedBox(
              height: 3,
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
            const SizedBox(height: 3),
        ],
      ),
    );
  }
}
