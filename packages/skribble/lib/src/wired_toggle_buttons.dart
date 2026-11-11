import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn multi-toggle button group, corresponding to Flutter's
/// [ToggleButtons].
///
/// Each button in the group gets a sketchy border. Selected buttons are
/// washed with the theme's `markerColor`.
///
/// Each button is its own focusable control that reports its toggled state
/// to assistive technology and activates with a tap, Enter, or Space.
class WiredToggleButtons extends HookWidget {
  /// The widgets to use as button labels.
  final List<Widget> children;

  /// Selection state for each button. Must match [children] length.
  final List<bool> isSelected;

  /// Called when a button is tapped. Receives the tapped index. Null
  /// disables every button and removes them from focus traversal.
  final ValueChanged<int>? onPressed;

  /// The least height of each toggle button. Buttons grow past it when a
  /// label needs more room, such as at a larger text scale.
  final double height;

  /// Horizontal padding inside each button.
  final double horizontalPadding;

  /// Creates a toggle button group. [children] and [isSelected] must have
  /// the same length. [height] defaults to 42 and [horizontalPadding] to 16
  /// logical pixels.
  const WiredToggleButtons({
    super.key,
    required this.children,
    required this.isSelected,
    this.onPressed,
    this.height = 42,
    this.horizontalPadding = 16,
  }) : assert(
         children.length == isSelected.length,
         'children and isSelected must have the same length',
       );

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      // Every button in the row matches the tallest label.
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++)
              _WiredToggleButton(
                selected: isSelected[i],
                height: height,
                horizontalPadding: horizontalPadding,
                onPressed: onPressed != null ? () => onPressed!(i) : null,
                child: children[i],
              ),
          ],
        ),
      ),
    );
  }
}

class _WiredToggleButton extends HookWidget {
  final Widget child;
  final bool selected;
  final double height;
  final double horizontalPadding;
  final VoidCallback? onPressed;

  const _WiredToggleButton({
    required this.child,
    required this.selected,
    required this.height,
    required this.horizontalPadding,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      container: true,
      button: true,
      toggled: selected,
      enabled: onPressed != null,
      child: WiredActivatable(
        onActivate: onPressed,
        // A minimum, so a larger font or text scale grows the button
        // instead of clipping its label.
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRectangleBase(
                    strokeWidth: theme.strokeWidth,
                    fillColor: theme.markerColor,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: selected
                      ? RoughFilter.solidFiller
                      : RoughFilter.noFiller,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: kWiredInkPadding.top,
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: selected ? theme.onMarkerColor : theme.textColor,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : null,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: selected ? theme.onMarkerColor : theme.textColor,
                      size: 20,
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
