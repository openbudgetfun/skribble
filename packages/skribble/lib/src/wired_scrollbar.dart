import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn scrollbar, corresponding to `CupertinoScrollbar`.
///
/// Wraps Flutter's [Scrollbar] with a sketchy thumb style.
class WiredScrollbar extends HookWidget {
  /// The scrollable content.
  final Widget child;

  /// Optional scroll controller.
  final ScrollController? controller;

  /// Whether the scrollbar is always visible.
  final bool thumbVisibility;

  /// Thickness of the scrollbar thumb.
  final double thickness;

  /// Radius of the scrollbar thumb corners.
  final Radius? radius;

  const WiredScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.thumbVisibility = false,
    this.thickness = 6,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(
              theme.borderColor.withValues(alpha: 0.6),
            ),
            trackColor: WidgetStateProperty.all(
              theme.borderColor.withValues(alpha: 0.1),
            ),
            thickness: WidgetStateProperty.all(thickness),
            radius: radius ?? const Radius.circular(3),
          ),
        ),
        child: Scrollbar(
          controller: controller,
          thumbVisibility: thumbVisibility,
          child: child,
        ),
      ),
    );
  }
}
