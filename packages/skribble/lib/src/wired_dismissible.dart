import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A hand-drawn dismissible wrapper corresponding to Flutter's [Dismissible].
///
/// Wraps [Dismissible] with a hand-drawn background shown during swipe.
class WiredDismissible extends HookWidget {
  /// The unique key for this dismissible.
  final Key dismissKey;

  /// The child widget.
  final Widget child;

  /// Called when the item is dismissed.
  final DismissDirectionCallback? onDismissed;

  /// Called to confirm dismiss.
  final ConfirmDismissCallback? confirmDismiss;

  /// The direction(s) in which the item can be dismissed.
  final DismissDirection direction;

  /// The background shown when swiping right (or down).
  final Widget? background;

  /// The background shown when swiping left (or up).
  final Widget? secondaryBackground;

  /// Duration of the resize animation after dismiss.
  final Duration resizeDuration;

  /// Duration of the dismiss animation.
  final Duration movementDuration;

  /// The dismiss threshold fraction.
  final Map<DismissDirection, double>? dismissThresholds;

  /// Color for the default delete background. Defaults to the theme's
  /// `errorColor`, so the swipe reads as a warning in every theme.
  final Color? deleteColor;

  /// Icon for the default delete background.
  final IconData deleteIcon;

  /// Creates a dismissible wrapper with a hand-drawn swipe background.
  const WiredDismissible({
    super.key,
    required this.dismissKey,
    required this.child,
    this.onDismissed,
    this.confirmDismiss,
    this.direction = DismissDirection.horizontal,
    this.background,
    this.secondaryBackground,
    this.resizeDuration = const Duration(milliseconds: 300),
    this.movementDuration = const Duration(milliseconds: 200),
    this.dismissThresholds,
    this.deleteColor,
    this.deleteIcon = Icons.delete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Dismissible(
        key: dismissKey,
        direction: direction,
        onDismissed: onDismissed,
        confirmDismiss: confirmDismiss,
        resizeDuration: resizeDuration,
        movementDuration: movementDuration,
        dismissThresholds: dismissThresholds ?? const {},
        background: background ?? _buildDefaultBackground(false, theme),
        secondaryBackground:
            secondaryBackground ?? _buildDefaultBackground(true, theme),
        child: child,
      ),
    );
  }

  Widget _buildDefaultBackground(bool isSecondary, WiredThemeData theme) {
    final wash = deleteColor ?? theme.errorColor;
    // The theme's ink or its paper, whichever stands out more on the wash,
    // so the icon reads in light and dark themes alike.
    double contrast(Color a, Color b) {
      final (light, dark) = a.computeLuminance() > b.computeLuminance()
          ? (a, b)
          : (b, a);
      return (light.computeLuminance() + .05) / (dark.computeLuminance() + .05);
    }

    final iconColor =
        contrast(theme.textColor, wash) >= contrast(theme.fillColor, wash)
        ? theme.textColor
        : theme.fillColor;
    return Stack(
      children: [
        Positioned.fill(
          child: WiredCanvas(
            painter: WiredRectangleBase(
              strokeWidth: theme.strokeWidth,
              fillColor: wash,
              borderColor: theme.borderColor,
            ),
            fillerType: RoughFilter.hachureFiller,
            fillerConfig: FillerConfig.build(hachureGap: 3.0),
          ),
        ),
        Container(
          color: wash.withValues(alpha: 0.9),
          alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: WiredIcon(
            icon: deleteIcon,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}
