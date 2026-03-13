import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_theme.dart';
import 'wired_base.dart';

/// A hand-drawn sliver app bar corresponding to Flutter's [SliverAppBar].
///
/// Provides a collapsible app bar with a sketchy bottom border line
/// and optional flexible space.
class WiredSliverAppBar extends HookWidget {
  /// The title widget.
  final Widget? title;

  /// The leading widget.
  final Widget? leading;

  /// Trailing action widgets.
  final List<Widget>? actions;

  /// The flexible space content, typically an image or expanded area.
  final Widget? flexibleSpace;

  /// The expanded height when fully expanded.
  final double? expandedHeight;

  /// The collapsed height.
  final double? collapsedHeight;

  /// Whether the app bar should remain visible when scrolled.
  final bool pinned;

  /// Whether the app bar should become visible as soon as the user
  /// scrolls towards it.
  final bool floating;

  /// Whether the flexible space should stretch when overscrolled.
  final bool stretch;

  /// Background color.
  final Color? backgroundColor;

  /// Foreground color for title and icons.
  final Color? foregroundColor;

  /// Whether to automatically imply a leading widget.
  final bool automaticallyImplyLeading;

  /// The bottom widget, typically a [TabBar].
  final PreferredSizeWidget? bottom;

  const WiredSliverAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.flexibleSpace,
    this.expandedHeight,
    this.collapsedHeight,
    this.pinned = false,
    this.floating = false,
    this.stretch = false,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final bgColor = backgroundColor ?? theme.fillColor;
    final fgColor = foregroundColor ?? theme.textColor;

    return SliverAppBar(
      title: title != null
          ? DefaultTextStyle(
              style: TextStyle(
                color: fgColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              child: title!,
            )
          : null,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      pinned: pinned,
      floating: floating,
      stretch: stretch,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      bottom: bottom,
      flexibleSpace: flexibleSpace != null
          ? FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  flexibleSpace!,
                  // Sketchy bottom border over the flexible space
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 3,
                    child: buildWiredElement(
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
                  ),
                ],
              ),
            )
          : FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: bgColor),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 3,
                    child: buildWiredElement(
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
                  ),
                ],
              ),
            ),
    );
  }
}
