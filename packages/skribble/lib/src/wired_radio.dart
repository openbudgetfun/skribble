import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn radio button, corresponding to Flutter's `Radio`.
///
/// Draws a sketchy circle border. When [value] equals [groupValue],
/// a neat inked dot is drawn in the middle.
///
/// The radio button is wrapped in [Semantics] for accessibility, providing
/// screen readers with the selected state.
///
/// See also:
///  * `WiredRadioListTile`, which combines this with a label.
class WiredRadio<T> extends HookWidget {
  final T value;
  final T? groupValue;

  /// Called with the radio's value when it is tapped.
  ///
  /// Null disables the radio, matching the framework convention. The value is
  /// never null from this widget; the nullable parameter type keeps lambdas
  /// written for `Radio.onChanged` assignable.
  final void Function(T? value)? onChanged;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  const WiredRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.semanticLabel,
    this.seed,
  });

  /// Varies the hand behind this widget's ink. The same seed always draws
  /// the same wobble, so neighbouring shapes of the same size need different
  /// seeds to stop them reading as copies of each other. Null keeps the
  /// theme's seed.
  final int? seed;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isSelected = value == groupValue;

    return Semantics(
      label: semanticLabel,
      checked: isSelected,
      enabled: onChanged != null,
      onTap: onChanged == null ? null : () => onChanged?.call(value),
      child: buildWiredElement(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 48.0,
              width: 48.0,
              child: WiredCanvas(
                painter: WiredCircleBase(
                  strokeWidth: theme.strokeWidth,
                  diameterRatio: .7,
                  borderColor: theme.borderColor,
                ),
                seed: seed,
                fillerType: RoughFilter.noFiller,
              ),
            ),
            if (isSelected)
              SizedBox(
                height: 24.0,
                width: 24.0,
                child: WiredCanvas(
                  painter: WiredCircleBase(
                    strokeWidth: theme.strokeWidth,
                    diameterRatio: .6,
                    fillColor: theme.textColor,
                    borderColor: theme.borderColor,
                  ),
                  seed: seed,
                  fillerType: RoughFilter.solidFiller,
                ),
              ),
            SizedBox(
              height: 48.0,
              width: 48.0,
              child: Radio<T>(
                value: value,
                groupValue: groupValue,
                fillColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: (newValue) {
                  onChanged?.call(newValue);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
