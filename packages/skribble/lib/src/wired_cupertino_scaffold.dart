import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A hand-drawn page scaffold, corresponding to [CupertinoPageScaffold].
///
/// Provides a page with a hand-drawn navigation bar at the top and
/// content below.
class WiredPageScaffold extends HookWidget {
  /// The navigation bar at the top. Typically a [WiredAppBar] or similar.
  final Widget? navigationBar;

  /// The content of the page.
  final Widget child;

  /// Background color. Defaults to the Skribble cream background.
  final Color? backgroundColor;

  const WiredPageScaffold({
    super.key,
    this.navigationBar,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: Scaffold(
        backgroundColor: backgroundColor ?? filledColor.withValues(alpha: 0.3),
        body: Column(
          children: [
            if (navigationBar != null) navigationBar!,
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// A hand-drawn tab scaffold, corresponding to [CupertinoTabScaffold].
///
/// Provides a tabbed layout with a hand-drawn bottom tab bar and
/// page content that switches based on the selected tab.
class WiredTabScaffold extends HookWidget {
  /// Tab bar items. Each needs an icon and label.
  final List<WiredTabItem> tabs;

  /// Builder for the page content at each tab index.
  final Widget Function(BuildContext context, int index) tabBuilder;

  /// Initial tab index.
  final int initialIndex;

  const WiredTabScaffold({
    super.key,
    required this.tabs,
    required this.tabBuilder,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(initialIndex);

    return buildWiredElement(
      child: Scaffold(
        backgroundColor: filledColor.withValues(alpha: 0.3),
        body: IndexedStack(
          index: currentIndex.value,
          children: [
            for (var i = 0; i < tabs.length; i++) tabBuilder(context, i),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: 64,
          child: Stack(
            children: [
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRectangleBase(),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => currentIndex.value = i,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tabs[i].icon,
                              color: currentIndex.value == i
                                  ? borderColor
                                  : textColor.withValues(alpha: 0.5),
                              size: 22,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tabs[i].label,
                              style: TextStyle(
                                fontSize: 11,
                                color: currentIndex.value == i
                                    ? borderColor
                                    : textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tab item definition for [WiredTabScaffold].
class WiredTabItem {
  final IconData icon;
  final String label;

  const WiredTabItem({required this.icon, required this.label});
}
