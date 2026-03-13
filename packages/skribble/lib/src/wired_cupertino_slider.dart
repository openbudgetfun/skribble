import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A hand-drawn slider corresponding to Flutter's [CupertinoSlider].
///
/// Provides the same API as [CupertinoSlider] with a sketchy hand-drawn
/// track and rounded thumb.
class WiredCupertinoSlider extends HookWidget {
  /// The currently selected value.
  final double value;

  /// Called during a drag when the value changes.
  final ValueChanged<double>? onChanged;

  /// Called when the user starts dragging.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user stops dragging.
  final ValueChanged<double>? onChangeEnd;

  /// Minimum selectable value.
  final double min;

  /// Maximum selectable value.
  final double max;

  /// Number of discrete divisions. Null for continuous.
  final int? divisions;

  /// The active color of the track and thumb.
  final Color? activeColor;

  /// The inactive color of the track.
  final Color? inactiveColor;

  /// The color of the thumb.
  final Color thumbColor;

  static const double _trackHeight = 4.0;
  static const double _thumbSize = 28.0;
  static const double _sliderHeight = 36.0;

  const WiredCupertinoSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor = CupertinoColors.white,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final effectiveActiveColor = activeColor ?? CupertinoColors.activeBlue;
    final effectiveInactiveColor = inactiveColor ?? CupertinoColors.systemGrey4;

    return buildWiredElement(
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 150),
        child: SizedBox(
          height: _sliderHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final fraction = (value - min) / (max - min);
              final thumbLeft = fraction * (trackWidth - _thumbSize);

              return GestureDetector(
                onHorizontalDragStart: enabled
                    ? (details) {
                        final newValue = _valueFromPosition(
                          details.localPosition.dx,
                          trackWidth,
                        );
                        onChangeStart?.call(newValue);
                        onChanged!(newValue);
                      }
                    : null,
                onHorizontalDragUpdate: enabled
                    ? (details) {
                        final newValue = _valueFromPosition(
                          details.localPosition.dx,
                          trackWidth,
                        );
                        onChanged!(newValue);
                      }
                    : null,
                onHorizontalDragEnd: enabled
                    ? (_) => onChangeEnd?.call(value)
                    : null,
                onTapDown: enabled
                    ? (details) {
                        final newValue = _valueFromPosition(
                          details.localPosition.dx,
                          trackWidth,
                        );
                        onChanged!(newValue);
                      }
                    : null,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Inactive track
                    Positioned(
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: _trackHeight,
                        child: WiredCanvas(
                          painter: WiredRoundedRectangleBase(
                            borderRadius: BorderRadius.circular(2),
                            fillColor: effectiveInactiveColor,
                          ),
                          fillerType: RoughFilter.noFiller,
                        ),
                      ),
                    ),
                    // Active track
                    Positioned(
                      left: 0,
                      width: thumbLeft + _thumbSize / 2,
                      child: SizedBox(
                        height: _trackHeight,
                        child: WiredCanvas(
                          painter: WiredRoundedRectangleBase(
                            borderRadius: BorderRadius.circular(2),
                            fillColor: effectiveActiveColor,
                          ),
                          fillerType: RoughFilter.hachureFiller,
                          fillerConfig: FillerConfig.build(hachureGap: 1.5),
                        ),
                      ),
                    ),
                    // Thumb
                    Positioned(
                      left: thumbLeft,
                      child: SizedBox(
                        width: _thumbSize,
                        height: _thumbSize,
                        child: WiredCanvas(
                          painter: WiredCircleBase(fillColor: thumbColor),
                          fillerType: RoughFilter.hachureFiller,
                          fillerConfig: FillerConfig.build(hachureGap: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double _valueFromPosition(double dx, double trackWidth) {
    final fraction = ((dx - _thumbSize / 2) / (trackWidth - _thumbSize)).clamp(
      0.0,
      1.0,
    );
    var newValue = min + fraction * (max - min);
    if (divisions != null) {
      final step = (max - min) / divisions!;
      newValue = (newValue / step).round() * step;
    }
    return newValue.clamp(min, max);
  }
}
