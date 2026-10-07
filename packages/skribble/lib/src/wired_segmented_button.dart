import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
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
                filler: HachureFiller(FillerConfig.build(hachureGap: 3)),
              )
            : null,
        alignment: Alignment.center,
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
    );
  }
}
