import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn segmented control corresponding to
/// [CupertinoSegmentedControl].
///
/// Provides the same generic key-based API as [CupertinoSegmentedControl]
/// with sketchy hand-drawn rounded rectangle segments.
class WiredCupertinoSegmentedControl<T extends Object> extends HookWidget {
  /// Map of segment keys to their child widgets.
  final Map<T, Widget> children;

  /// The currently selected segment key.
  final T? groupValue;

  /// Called when a segment is tapped.
  final ValueChanged<T>? onValueChanged;

  /// The color of the selected segment.
  final Color? selectedColor;

  /// The color of unselected segments.
  final Color? unselectedColor;

  /// The border color.
  final Color? borderColor;

  /// Padding inside each segment.
  final EdgeInsetsGeometry padding;

  const WiredCupertinoSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    this.selectedColor,
    this.unselectedColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final keys = children.keys.toList();
    final effectiveSelectedColor = selectedColor ?? CupertinoColors.activeBlue;
    final theme = WiredTheme.of(context);
    final effectiveBorderColor = borderColor ?? theme.borderColor;

    return buildWiredElement(
      child: Stack(
        children: [
          // Outer border
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                borderRadius: BorderRadius.circular(8),
                fillColor: unselectedColor ?? theme.fillColor,
                strokeWidth: 2,
                borderColor: effectiveBorderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          // Segments
          IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < keys.length; i++) ...[
                  if (i > 0)
                    SizedBox(
                      width: 2,
                      child: WiredCanvas(
                        painter: WiredLineBase(
                          x1: 1,
                          y1: 0,
                          x2: 1,
                          y2: double.maxFinite,
                          strokeWidth: 2,
                          borderColor: effectiveBorderColor,
                        ),
                        fillerType: RoughFilter.noFiller,
                      ),
                    ),
                  Expanded(
                    child: _SegmentTile<T>(
                      segmentKey: keys[i],
                      isSelected: groupValue == keys[i],
                      selectedColor: effectiveSelectedColor,
                      borderColor: effectiveBorderColor,
                      onTap: onValueChanged != null
                          ? () => onValueChanged!(keys[i])
                          : null,
                      padding: padding,
                      child: children[keys[i]]!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTile<T> extends HookWidget {
  final T segmentKey;
  final bool isSelected;
  final Color selectedColor;
  final Color borderColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _SegmentTile({
    required this.segmentKey,
    required this.isSelected,
    required this.selectedColor,
    required this.borderColor,
    required this.onTap,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          if (isSelected)
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRectangleBase(
                  fillColor: selectedColor,
                  borderColor: borderColor,
                ),
                fillerType: RoughFilter.hachureFiller,
                fillerConfig: FillerConfig.build(hachureGap: 2.5),
              ),
            ),
          Padding(
            padding: padding,
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: isSelected ? Colors.white : borderColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A hand-drawn sliding segmented control corresponding to
/// [CupertinoSlidingSegmentedControl].
///
/// Same API as [WiredCupertinoSegmentedControl] but with an
/// animated sliding selection indicator.
class WiredSlidingSegmentedControl<T extends Object> extends HookWidget {
  /// Map of segment keys to their child widgets.
  final Map<T, Widget> children;

  /// The currently selected segment key.
  final T? groupValue;

  /// Called when a segment is tapped.
  final ValueChanged<T>? onValueChanged;

  /// Background color.
  final Color? backgroundColor;

  /// The color of the sliding thumb.
  final Color? thumbColor;

  /// Padding inside each segment.
  final EdgeInsetsGeometry padding;

  const WiredSlidingSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
    this.backgroundColor,
    this.thumbColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final keys = children.keys.toList();
    final selectedIndex = groupValue != null ? keys.indexOf(groupValue!) : -1;

    final effectiveThumbColor = thumbColor ?? Colors.white;
    final effectiveBgColor = backgroundColor ?? CupertinoColors.systemGrey5;

    return buildWiredElement(
      child: Stack(
        children: [
          // Background
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                borderRadius: BorderRadius.circular(8),
                fillColor: effectiveBgColor,
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          // Segments
          IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < keys.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: onValueChanged != null
                          ? () => onValueChanged!(keys[i])
                          : null,
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        children: [
                          if (i == selectedIndex)
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: WiredCanvas(
                                  painter: WiredRoundedRectangleBase(
                                    borderRadius: BorderRadius.circular(6),
                                    fillColor: effectiveThumbColor,
                                    borderColor: theme.borderColor,
                                  ),
                                  fillerType: RoughFilter.hachureFiller,
                                  fillerConfig: FillerConfig.build(
                                    hachureGap: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: padding,
                            child: Center(
                              child: DefaultTextStyle(
                                style: TextStyle(
                                  color: theme.textColor,
                                  fontSize: 14,
                                  fontWeight: i == selectedIndex
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                child: children[keys[i]]!,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
