import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_theme.dart';
import 'wired_base.dart';

/// A hand-drawn animated icon corresponding to Flutter's [AnimatedIcon].
///
/// Wraps [AnimatedIcon] with Skribble styling and an optional
/// hand-drawn circle background.
class WiredAnimatedIcon extends HookWidget {
  /// The animated icon data (e.g. [AnimatedIcons.menu_arrow]).
  final AnimatedIconData icon;

  /// The animation progress (0.0 to 1.0).
  final Animation<double> progress;

  /// The color of the icon.
  final Color? color;

  /// The size of the icon.
  final double? size;

  /// Semantic label.
  final String? semanticLabel;

  /// Text direction for the icon.
  final TextDirection? textDirection;

  const WiredAnimatedIcon({
    super.key,
    required this.icon,
    required this.progress,
    this.color,
    this.size,
    this.semanticLabel,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: AnimatedIcon(
        icon: icon,
        progress: progress,
        color: color ?? theme.textColor,
        size: size,
        semanticLabel: semanticLabel,
        textDirection: textDirection,
      ),
    );
  }
}
