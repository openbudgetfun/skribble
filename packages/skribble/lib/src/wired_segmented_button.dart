import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A segment in a segmented button.
class WiredButtonSegment<T> {
  final T value;
  final Widget label;
  final IconData? icon;

  const WiredButtonSegment({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// A segmented button with hand-drawn connected rounded rectangles.
class WiredSegmentedButton<T> extends HookWidget {
  final List<WiredButtonSegment<T>> segments;
  final Set<T> selected;
  final void Function(Set<T>)? onSelectionChanged;
  final bool multiSelectionEnabled;

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
      child: SizedBox(
        height: 42.0,
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(
                  borderRadius: BorderRadius.circular(8),
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < segments.length; i++) ...[
                  if (i > 0)
                    SizedBox(
                      width: 2,
                      height: 42.0,
                      child: WiredCanvas(
                        painter: WiredLineBase(x1: 0, y1: 0, x2: 0, y2: 42.0),
                        fillerType: RoughFilter.noFiller,
                      ),
                    ),
                  _buildSegment(segments[i], theme),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(WiredButtonSegment<T> segment, WiredThemeData theme) {
    final isSelected = selected.contains(segment.value);
    return GestureDetector(
      onTap: () {
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
        onSelectionChanged?.call(newSelection);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: isSelected
            ? RoughBoxDecoration(
                shape: RoughBoxShape.rectangle,
                borderStyle: RoughDrawingStyle(
                  width: 0.5,
                  color: theme.borderColor,
                ),
                filler: HachureFiller(FillerConfig.build(hachureGap: 3)),
              )
            : null,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (segment.icon != null) ...[
              Icon(segment.icon, size: 18, color: theme.textColor),
              const SizedBox(width: 8),
            ],
            segment.label,
          ],
        ),
      ),
    );
  }
}
