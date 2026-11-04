import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A segment in a segmented button.
class WiredButtonSegment<T> {
  /// The value this segment selects.
  final T value;

  /// The segment's label, written in the theme's text colour.
  final Widget label;

  /// An optional icon drawn before [label].
  final IconData? icon;

  /// Creates a segment for a [WiredSegmentedButton].
  const WiredButtonSegment({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// A segmented button with hand-drawn connected rounded rectangles.
///
/// Each segment is its own focusable button that reports whether it is
/// selected and activates with a tap, Enter, or Space.
class WiredSegmentedButton<T> extends HookWidget {
  /// The segments, in reading order.
  final List<WiredButtonSegment<T>> segments;

  /// The values of the selected segments.
  final Set<T> selected;

  /// Called with the new selection when a segment is activated. Null
  /// disables every segment and removes them from focus traversal.
  final void Function(Set<T>)? onSelectionChanged;

  /// Whether more than one segment can be selected at once. When false,
  /// activating a segment selects only that segment.
  final bool multiSelectionEnabled;

  /// Creates a segmented button.
  const WiredSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    this.onSelectionChanged,
    this.multiSelectionEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      // At least a button's height, and taller when the labels are.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kWiredButtonHeight),
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    strokeWidth: theme.strokeWidth,
                    borderRadius: BorderRadius.circular(8),
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < segments.length; i++) ...[
                    if (i > 0)
                      SizedBox(
                        width: 2,
                        // The line clamps to its box, so it spans whatever
                        // height the labels give the button.
                        child: WiredCanvas(
                          painter: WiredLineBase(
                            strokeWidth: theme.strokeWidth,
                            x1: 0,
                            y1: 0,
                            x2: 0,
                            y2: double.infinity,
                            borderColor: theme.borderColor,
                          ),
                          fillerType: RoughFilter.noFiller,
                        ),
                      ),
                    _buildSegment(context, segments[i], theme),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context,
    WiredButtonSegment<T> segment,
    WiredThemeData theme,
  ) {
    final isSelected = selected.contains(segment.value);
    final onChanged = onSelectionChanged;
    final VoidCallback? onActivate = onChanged == null
        ? null
        : () {
            final newSelection = Set<T>.from(selected);
            if (multiSelectionEnabled) {
              if (isSelected) {
                newSelection.remove(segment.value);
              } else {
                newSelection.add(segment.value);
              }
            } else {
              newSelection
                ..clear()
                ..add(segment.value);
            }

            onChanged(newSelection);
          };
    return Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: !multiSelectionEnabled,
      enabled: onActivate != null,
      child: WiredActivatable(
        onActivate: onActivate,
        child: Container(
          padding: kWiredButtonPadding,
          decoration: isSelected
              ? RoughBoxDecoration(
                  progress: WiredDrawTransition.progressOf(context),
                  pressure: WiredInkResponse.pressureOf(context),
                  drawConfig: theme.drawConfig,
                  shape: RoughBoxShape.rectangle,
                  borderStyle: RoughDrawingStyle(
                    width: theme.strokeWidth,
                    color: theme.borderColor,
                  ),
                  // A marker wash, like a selected toggle button: hachure
                  // lines ran straight through the label and hid it.
                  fillStyle: RoughDrawingStyle(color: theme.markerColor),
                  filler: SolidFiller(
                    FillerConfig.build(drawConfig: theme.drawConfig),
                  ),
                )
              : null,
          alignment: Alignment.center,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: theme.textColor),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (segment.icon != null) ...[
                  WiredIcon(
                    icon: segment.icon!,
                    size: 18,
                    color: theme.textColor,
                  ),
                  const SizedBox(width: 8),
                ],
                segment.label,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
