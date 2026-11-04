import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_loading_indicator.dart';
import 'wired_theme.dart';

/// A hand-drawn refresh indicator, corresponding to Flutter's `RefreshIndicator`.
///
/// Wraps Flutter's `RefreshIndicator` with a sketchy loading indicator
/// and hand-drawn styling that fits the skribble aesthetic.
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
      child: child,
    );
  }
}

/// A hand-drawn refresh indicator with custom loading animation.
///
/// This variant uses the [WiredLoadingIndicator] for a more
/// hand-drawn feel during the refresh operation. Pulling the scrollable
/// [child] more than 50 pixels past its top calls [onRefresh], with
/// clamping (Android) and bouncing (iOS) scroll physics alike.
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
    final isMounted = useIsMounted();
    // A pull arrives as many small overscroll steps, so they are added up
    // until the drag ends.
    final pulled = useRef(0.0);
    // One pull refreshes once: the next refresh waits for a new drag.
    final armed = useRef(true);

    void refresh() {
      isRefreshing.value = true;
      pulled.value = 0;
      armed.value = false;
      // whenComplete resets the spinner whether the refresh succeeds or
      // fails; the error itself still propagates to the zone. The widget may
      // be gone by then, and a disposed state must not be written.
      unawaited(
        onRefresh().whenComplete(() {
          if (isMounted()) isRefreshing.value = false;
        }),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth != 0) return false;
        switch (notification) {
          case ScrollStartNotification():
          case ScrollEndNotification():
            pulled.value = 0;
            armed.value = true;
          // Clamping physics, as on Android, report the pull as overscroll.
          case OverscrollNotification(:final overscroll) when overscroll < 0:
            pulled.value += -overscroll;
          // Bouncing physics, as on iOS, scroll past the top instead.
          case ScrollUpdateNotification(:final metrics, :final dragDetails)
              when dragDetails != null &&
                  metrics.pixels < metrics.minScrollExtent:
            pulled.value = metrics.minScrollExtent - metrics.pixels;
          default:
            break;
        }
        if (!isRefreshing.value &&
            armed.value &&
            pulled.value > _kPullToRefreshDistance) {
          refresh();
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

/// How far, in logical pixels, a list is pulled past its top to refresh.
const double _kPullToRefreshDistance = 50;
