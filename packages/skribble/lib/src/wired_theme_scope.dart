import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_motion.dart';
import 'wired_theme.dart';

/// Installs [WiredThemeData] for a widgets-only subtree.
///
/// This is the Material-free half of [WiredTheme]. It cascades the palette,
/// font, and motion policy to every descendant without depending on
/// `package:flutter/material.dart`, which makes it the theme boundary used by
/// `SkribbleApp`.
///
/// Use `WiredTheme` instead when the subtree also hosts Material widgets and
/// their `ThemeData` must stay in sync with the Skribble palette. A
/// [WiredThemeScope] nested inside a [WiredTheme] overrides the palette for
/// the subtree while leaving the surrounding Material theme untouched.
///
/// `WiredTheme.of(context)` finds both boundaries, so widgets do not need to
/// care which one is installed above them.
class WiredThemeScope extends HookWidget {
  /// Creates a theme boundary for a widgets-only subtree.
  const WiredThemeScope({super.key, required this.data, required this.child});

  /// The resolved theme for this subtree.
  final WiredThemeData data;

  /// The subtree that inherits this theme.
  final Widget child;

  /// Returns the nearest theme, or the playful default when none is installed.
  static WiredThemeData of(BuildContext context) =>
      maybeOf(context) ?? WiredThemeData.defaultTheme;

  /// Returns the nearest theme, or null when no boundary is installed.
  ///
  /// Prefer [of] unless you need to distinguish "no Skribble theme is
  /// installed" from "the default theme is installed".
  static WiredThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_WiredThemeScope>()?.data;

  @override
  Widget build(BuildContext context) {
    return _WiredThemeScope(
      data: data,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontFamily: data.fontFamily,
          package: data.fontPackage,
          color: data.textColor,
        ),
        child: WiredMotion(enabled: data.motionEnabled, child: child),
      ),
    );
  }
}

class _WiredThemeScope extends InheritedTheme {
  const _WiredThemeScope({required this.data, required super.child});

  final WiredThemeData data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      WiredThemeScope(data: data, child: child);

  @override
  bool updateShouldNotify(_WiredThemeScope oldWidget) => data != oldWidget.data;
}
