import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn button corresponding to Flutter's [CupertinoButton].
///
/// Provides the same API as [CupertinoButton] with a sketchy hand-drawn
/// rounded rectangle border and optional hachure fill.
class WiredCupertinoButton extends HookWidget {
  /// The widget below this in the tree.
  final Widget child;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// The amount of padding around the [child].
  final EdgeInsetsGeometry? padding;

  /// The background color of the button. Defaults to transparent.
  final Color? color;

  /// The color to use when the button is disabled.
  final Color disabledColor;

  /// Minimum size of the button.
  final double minSize;

  /// Opacity when pressed.
  final double pressedOpacity;

  /// Border radius of the button.
  final BorderRadius? borderRadius;

  /// Alignment of the child within the button.
  final AlignmentGeometry alignment;

  const WiredCupertinoButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding,
    this.color,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = kMinInteractiveDimensionCupertino,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.alignment = Alignment.center,
  });

  /// Creates a filled variant, analogous to [CupertinoButton.filled].
  const WiredCupertinoButton.filled({
    super.key,
    required this.child,
    required this.onPressed,
    this.padding,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = kMinInteractiveDimensionCupertino,
    this.pressedOpacity = 0.4,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.alignment = Alignment.center,
  }) : color = CupertinoColors.activeBlue;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isPressed = useState(false);
    final enabled = onPressed != null;
    final effectiveFill = enabled ? color : disabledColor;
    final hasFill = effectiveFill != null;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(8);

    return buildWiredElement(
      child: GestureDetector(
        onTapDown: enabled ? (_) => isPressed.value = true : null,
        onTapUp: enabled ? (_) => isPressed.value = false : null,
        onTapCancel: enabled ? () => isPressed.value = false : null,
        onTap: onPressed,
        child: AnimatedOpacity(
          opacity: !enabled
              ? 0.4
              : isPressed.value
              ? pressedOpacity
              : 1.0,
          duration: const Duration(milliseconds: 100),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minSize, minWidth: minSize),
            child: Stack(
              alignment: alignment,
              children: [
                Positioned.fill(
                  child: WiredCanvas(
                    painter: WiredRoundedRectangleBase(
                      borderRadius: effectiveRadius,
                      fillColor: hasFill ? effectiveFill : theme.fillColor,
                    ),
                    fillerType: hasFill
                        ? RoughFilter.hachureFiller
                        : RoughFilter.noFiller,
                    fillerConfig: FillerConfig.build(hachureGap: 2.5),
                  ),
                ),
                Padding(
                  padding:
                      padding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: hasFill ? Colors.white : theme.borderColor,
                      fontSize: 16,
                    ),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
