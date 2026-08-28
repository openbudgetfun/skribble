import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_loading_indicator.dart';
import 'wired_theme.dart';

/// A hand-drawn refresh indicator, corresponding to Flutter's `RefreshIndicator`.
///
/// Wraps Flutter's `RefreshIndicator` with a sketchy loading indicator
/// and hand-drawn styling that fits the Skribble aesthetic.
///
/// ## Example
///
/// ```dart
/// WiredRefreshIndicator(
///   onRefresh: () async {
///     await Future.delayed(Duration(seconds: 1));
///   },
///   child: ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (context, index) => ListTile(title: Text(items[index])),
///   ),
/// )
/// ```
class WiredRefreshIndicator extends HookWidget {
  /// The child widget that can be pulled to refresh.
  final Widget child;

  /// The callback that is called when the user pulls to refresh.
  ///
  /// Should return a [Future] that completes when the refresh is done.
  final Future<void> Function() onRefresh;

  /// The displacement from the top of the widget to show the indicator.
  final double displacement;

  /// The edge offset for the refresh indicator.
  final double edgeOffset;

  /// The color of the refresh indicator. Defaults to theme border color.
  final Color? color;

  /// The background color of the refresh indicator. Defaults to theme fill color.
  final Color? backgroundColor;

  /// The semantics label for accessibility.
  final String? semanticLabel;

  /// Creates a hand-drawn refresh indicator.
  const WiredRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.color,
    this.backgroundColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final effectiveColor = color ?? theme.borderColor;
    final effectiveBgColor = backgroundColor ?? theme.fillColor;

    return RefreshIndicator(
      onRefresh: onRefresh,
      displacement: displacement,
      edgeOffset: edgeOffset,
      color: effectiveColor,
      backgroundColor: effectiveBgColor,
      semanticsLabel: semanticLabel,
      semanticsValue: semanticLabel,
      child: child,
    );
  }
}

/// A hand-drawn refresh indicator with custom loading animation.
///
/// This variant uses the [WiredLoadingIndicator] for a more
/// hand-drawn feel during the refresh operation.
///
/// ## Example
///
/// ```dart
/// WiredCustomRefreshIndicator(
///   onRefresh: () async {
///     await Future.delayed(Duration(seconds: 1));
///   },
///   child: ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (context, index) => ListTile(title: Text(items[index])),
///   ),
/// )
/// ```
class WiredCustomRefreshIndicator extends HookWidget {
  /// The child widget that can be pulled to refresh.
  final Widget child;

  /// The callback that is called when the user pulls to refresh.
  ///
  /// Should return a [Future] that completes when the refresh is done.
  final Future<void> Function() onRefresh;

  /// The size of the loading indicator.
  final double indicatorSize;

  /// The color of the loading indicator. Defaults to theme border color.
  final Color? color;

  /// Creates a hand-drawn custom refresh indicator.
  const WiredCustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.indicatorSize = 32.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final effectiveColor = color ?? theme.borderColor;
    final isRefreshing = useState(false);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Handle overscroll to trigger refresh
        if (notification is OverscrollNotification &&
            notification.overscroll < -50 &&
            !isRefreshing.value) {
          isRefreshing.value = true;
          unawaited(
            onRefresh().then((_) {
              isRefreshing.value = false;
            }),
          );
          return true;
        }
        return false;
      },
      child: Stack(
        children: [
          child,
          if (isRefreshing.value)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: WiredLoadingIndicator(
                  size: indicatorSize,
                  color: effectiveColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
