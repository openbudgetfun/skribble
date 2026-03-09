import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

class WiredSlider extends HookWidget {
  final double value;
  final int? divisions;
  final String? label;
  final double min;
  final double max;
  final bool Function(double)? onChanged;

  const WiredSlider({
    super.key,
    required this.value,
    this.divisions,
    this.label,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentSliderValue = useRef(value);
    useFuture(Future<void>.delayed(Duration.zero));

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
            fillerType: RoughFilter.hatchFiller,
          ),
        ),
        Positioned(
          left: _getWidth(context) * currentSliderValue.value / max - 12,
          child: SizedBox(
            height: 24.0,
            width: 24.0,
            child: WiredCanvas(
              painter: WiredCircleBase(diameterRatio: .7, fillColor: textColor),
              fillerType: RoughFilter.hachureFiller,
              fillerConfig: FillerConfig.build(hachureGap: 1.0),
            ),
          ),
        ),
        SliderTheme(
          data: SliderThemeData(trackShape: CustomTrackShape()),
          child: Slider(
            value: currentSliderValue.value,
            min: min,
            max: max,
            activeColor: Colors.transparent,
            inactiveColor: Colors.transparent,
            divisions: divisions,
            label: label,
            onChanged: (value) {
              bool result = false;
              if (onChanged != null) {
                result = onChanged!(value);
              }

              if (result) {
                currentSliderValue.value = value;
              }
            },
          ),
        ),
      ],
    );
  }

  double _getWidth(BuildContext context) {
    double width = 0;
    try {
      final box = context.findRenderObject()! as RenderBox;
      width = box.size.width;
    } catch (_) {
      width = 0;
    }

    return width;
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
