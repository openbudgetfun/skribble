import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A dual-handle range slider with hand-drawn track and thumbs.
///
/// The range slider is wrapped in [Semantics] for accessibility, providing
/// screen readers with the current range values.
class WiredRangeSlider extends HookWidget {
  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final RangeLabels? labels;
  final bool Function(RangeValues)? onChanged;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  const WiredRangeSlider({
    super.key,
    required this.values,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labels,
    required this.onChanged,
    this.semanticLabel,
  });

  /// Creates a range from numeric endpoints without importing Material values.
  /// [start] and [end] are the selected endpoints between [min] and [max].
  /// [onChanged] returns true to accept the new endpoints. Other options match
  /// the unnamed constructor.
  factory WiredRangeSlider.between({
    Key? key,
    required double start,
    required double end,
    double min = 0,
    double max = 1,
    int? divisions,
    bool Function(double start, double end)? onChanged,
    String? semanticLabel,
  }) => WiredRangeSlider(
    key: key,
    values: RangeValues(start, end),
    min: min,
    max: max,
    divisions: divisions,
    onChanged: onChanged == null
        ? null
        : (values) => onChanged(values.start, values.end),
    semanticLabel: semanticLabel,
  );

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final currentValues = useState(values);
    useEffect(() {
      currentValues.value = values;
      return null;
    }, [values]);

    return Semantics(
      label: semanticLabel,
      slider: true,
      value:
          '${currentValues.value.start.toStringAsFixed(1)} to ${currentValues.value.end.toStringAsFixed(1)}',
      child: Stack(
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
                strokeWidth: theme.strokeWidth,
                borderColor: theme.borderColor,
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
              rangeThumbShape: _WiredRangeThumbShape(theme),
            ),
            child: RangeSlider(
              values: currentValues.value,
              min: min,
              max: max,
              divisions: divisions,
              labels: labels,
              onChanged: onChanged == null
                  ? null
                  : (newValues) {
                      final result = onChanged?.call(newValues) ?? false;
                      if (result) {
                        currentValues.value = newValues;
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _WiredRangeThumbShape extends RangeSliderThumbShape {
  final WiredThemeData theme;

  _WiredRangeThumbShape(this.theme);

  late final RoughDrawing _drawing =
      WiredCircleBase(
        borderColor: theme.borderColor,
        fillColor: theme.fillColor,
        strokeWidth: theme.strokeWidth,
      ).prepare(
        const Size(28, 28),
        theme.drawConfig,
        SolidFiller(FillerConfig.build(drawConfig: theme.drawConfig)),
      );

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(28, 28);

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
    canvas.save();
    canvas.translate(center.dx - 14, center.dy - 14);
    _drawing.paint(canvas);
    canvas.restore();
  }
}
