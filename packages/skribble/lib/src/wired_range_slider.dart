import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'wired_base.dart';

/// A dual-handle range slider with hand-drawn track and thumbs.
class WiredRangeSlider extends HookWidget {
  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final RangeLabels? labels;
  final bool Function(RangeValues)? onChanged;

  const WiredRangeSlider({
    super.key,
    required this.values,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentValues = useRef(values);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 1,
          width: double.infinity,
          child: WiredCanvas(
            painter: WiredLineBase(
              x1: 0,
              y1: 0,
              x2: double.infinity,
              y2: 0,
              strokeWidth: 2,
            ),
            fillerType: RoughFilter.noFiller,
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            rangeTrackShape: RoundedRectRangeSliderTrackShape(),
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbColor: Colors.transparent,
            overlayColor: Colors.transparent,
            rangeThumbShape: _WiredRangeThumbShape(),
          ),
          child: RangeSlider(
            values: currentValues.value,
            min: min,
            max: max,
            divisions: divisions,
            labels: labels,
            onChanged: (newValues) {
              final result = onChanged?.call(newValues) ?? false;
              if (result) {
                currentValues.value = newValues;
              }
            },
          ),
        ),
      ],
    );
  }
}

class _WiredRangeThumbShape extends RangeSliderThumbShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool? isOnTop,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..color = textColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, paint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 8, borderPaint);
  }
}
