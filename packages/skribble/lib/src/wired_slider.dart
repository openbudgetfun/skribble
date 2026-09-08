import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn slider, corresponding to Flutter's `Slider`.
///
/// Renders a sketchy track line with a hand-drawn circle thumb.
/// Supports [divisions], [label], and custom [min]/[max] range.
///
/// The slider is wrapped in [Semantics] for accessibility, providing
/// screen readers with the current value and range information.
///
/// See also:
///  * `WiredRangeSlider`, for a dual-handle variant.
///  * `WiredCupertinoSlider`, for Cupertino styling.
class WiredSlider extends HookWidget {
  final double value;
  final int? divisions;
  final String? label;
  final double min;
  final double max;
  final bool Function(double)? onChanged;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredSlider({
    super.key,
    required this.value,
    this.divisions,
    this.label,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final currentSliderValue = useState(value);
    useEffect(() {
      currentSliderValue.value = value;
      return null;
    }, [value]);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticLabel,
      slider: true,
      enabled: onChanged != null,
      value: currentSliderValue.value.toStringAsFixed(1),
      increasedValue:
          (currentSliderValue.value + (max - min) / (divisions ?? 10))
              .clamp(min, max)
              .toStringAsFixed(1),
      decreasedValue:
          (currentSliderValue.value - (max - min) / (divisions ?? 10))
              .clamp(min, max)
              .toStringAsFixed(1),
      onIncrease: onChanged == null
          ? null
          : () {
              final step = (max - min) / (divisions ?? 10);
              final newValue = (currentSliderValue.value + step).clamp(
                min,
                max,
              );
              if (onChanged?.call(newValue) ?? false) {
                currentSliderValue.value = newValue;
              }
            },
      onDecrease: onChanged == null
          ? null
          : () {
              final step = (max - min) / (divisions ?? 10);
              final newValue = (currentSliderValue.value - step).clamp(
                min,
                max,
              );
              if (onChanged?.call(newValue) ?? false) {
                currentSliderValue.value = newValue;
              }
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fraction = max == min
                ? 0.0
                : (currentSliderValue.value - min) / (max - min);
            final visualFraction =
                Directionality.of(context) == TextDirection.rtl
                ? 1 - fraction
                : fraction;
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: theme.inkExtent,
                  width: double.infinity,
                  child: WiredCanvas(
                    painter: WiredLineBase(
                      x1: 0,
                      y1: theme.inkExtent / 2,
                      x2: double.infinity,
                      y2: theme.inkExtent / 2,
                      strokeWidth: theme.strokeWidth,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.hatchFiller,
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * visualFraction - 12,
                  child: SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: WiredCanvas(
                      painter: WiredCircleBase(
                        strokeWidth: theme.strokeWidth,
                        diameterRatio: .7,
                        fillColor: theme.textColor,
                        borderColor: theme.borderColor,
                      ),
                      fillerType: RoughFilter.hachureFiller,
                      fillerConfig: FillerConfig.build(hachureGap: 1.0),
                    ),
                  ),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    trackShape: CustomTrackShape(),
                    thumbShape: SliderComponentShape.noThumb,
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: currentSliderValue.value,
                    min: min,
                    max: max,
                    activeColor: Colors.transparent,
                    inactiveColor: Colors.transparent,
                    divisions: divisions,
                    label: label,
                    onChanged: onChanged == null
                        ? null
                        : (value) {
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
          },
        ),
      ),
    );
  }
}

/// A slider track shape that removes the default horizontal padding,
/// letting the track span the full width of the slider.
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
