import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A hand-drawn multi-toggle button group, corresponding to Flutter's
/// [ToggleButtons].
///
/// Each button in the group gets a sketchy border. Selected buttons receive
/// a hachure fill.
class WiredToggleButtons extends HookWidget {
  /// The widgets to use as button labels.
  final List<Widget> children;

  /// Selection state for each button. Must match [children] length.
  final List<bool> isSelected;

  /// Called when a button is tapped. Receives the tapped index.
  final ValueChanged<int>? onPressed;

  /// Height of each toggle button.
  final double height;

  /// Horizontal padding inside each button.
  final double horizontalPadding;

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRectangleBase(),
                fillerType: selected
                    ? RoughFilter.hachureFiller
                    : RoughFilter.noFiller,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Center(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: selected ? Colors.white : textColor,
                    fontSize: 14,
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                      color: selected ? Colors.white : textColor,
                      size: 20,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
