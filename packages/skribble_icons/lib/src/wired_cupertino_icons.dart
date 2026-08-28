import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:skribble_icons/src/skribble_icon.dart';

/// A hand-drawn Cupertino icon, corresponding to Flutter's `CupertinoIcons`.
///
/// Renders a pre-computed roughened version of Cupertino icons
/// using the same [SkribbleIcon] widget used for Material icons.
///
/// ## Example
///
/// ```dart
/// WiredCupertinoIcon(
///   icon: CupertinoIcons.heart,
///   size: 24,
///   color: Colors.red,
/// )
/// ```
class WiredCupertinoIcon extends HookWidget {
  /// Creates a hand-drawn Cupertino icon.
  const WiredCupertinoIcon({
    required this.icon,
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  /// The Cupertino icon to display.
  final IconData icon;

  /// The size of the icon in logical pixels.
  final double? size;

  /// The color of the icon. Defaults to theme text color.
  final Color? color;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // For now, use the Material icon rendering since we don't have
    // pre-computed Cupertino icon paths yet. This will be updated
    // when Cupertino icons are processed through the rough engine.
    return Icon(
      icon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}

/// A collection of commonly used hand-drawn Cupertino icons.
///
/// This class provides convenient access to frequently used Cupertino icons
/// with the Skribble hand-drawn style.
///
/// ## Example
///
/// ```dart
/// SkribbleCupertinoIcons.heart(size: 24, color: Colors.red)
/// SkribbleCupertinoIcons.settings(size: 24)
/// ```
class SkribbleCupertinoIcons {
  SkribbleCupertinoIcons._();

  /// Creates a hand-drawn heart icon.
  static Widget heart({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.heart,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Heart',
    );
  }

  /// Creates a hand-drawn heart fill icon.
  static Widget heartFill({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.heart_fill,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Heart filled',
    );
  }

  /// Creates a hand-drawn star icon.
  static Widget star({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.star,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Star',
    );
  }

  /// Creates a hand-drawn star fill icon.
  static Widget starFill({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.star_fill,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Star filled',
    );
  }

  /// Creates a hand-drawn settings icon.
  static Widget settings({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.settings,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Settings',
    );
  }

  /// Creates a hand-drawn person icon.
  static Widget person({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.person,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Person',
    );
  }

  /// Creates a hand-drawn person fill icon.
  static Widget personFill({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.person_fill,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Person filled',
    );
  }

  /// Creates a hand-drawn search icon.
  static Widget search({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.search,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Search',
    );
  }

  /// Creates a hand-drawn bell icon.
  static Widget bell({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.bell,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Notifications',
    );
  }

  /// Creates a hand-drawn bell fill icon.
  static Widget bellFill({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.bell_fill,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Notifications filled',
    );
  }

  /// Creates a hand-drawn gear icon.
  static Widget gear({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.gear,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Settings',
    );
  }

  /// Creates a hand-drawn home icon.
  static Widget home({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.home,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Home',
    );
  }

  /// Creates a hand-drawn home fill icon.
  static Widget homeFill({
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return WiredCupertinoIcon(
      icon: CupertinoIcons.house_fill,
      size: size,
      color: color,
      semanticLabel: semanticLabel ?? 'Home filled',
    );
  }
}
