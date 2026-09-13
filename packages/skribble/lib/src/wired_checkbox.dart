import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn checkbox, corresponding to Flutter's `Checkbox`.
///
/// Draws a sketchy square border with a checkmark when [value] is `true`.
/// A `null` value is treated as unchecked; tapping toggles between false and true.
///
/// Passing `null` for [onChanged] disables the checkbox, matching Material's
/// `Checkbox.onChanged == null` convention: the box renders disabled and no tap
/// action is advertised to assistive technology.
///
/// The checkbox is wrapped in [Semantics] for accessibility, providing
/// screen readers with the current checked state.
///
/// See also:
///  * `WiredCheckboxListTile`, which combines this with a label.
class WiredCheckbox extends HookWidget {
  /// Whether the box is checked. A `null` value is treated as unchecked.
  final bool? value;

  /// Called with the new value when the box is toggled.
  ///
  /// Null disables the checkbox: taps are ignored and the box renders in the
  /// Material disabled state.
  final ValueChanged<bool?>? onChanged;

  /// Soft corners for the box. Use [BorderRadius.zero] for square ink.
  final BorderRadius borderRadius;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  const WiredCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isChecked = useState(value ?? false);
    final enabled = onChanged != null;
    useEffect(() {
      isChecked.value = value ?? false;
      return null;
    }, [value]);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticLabel,
      checked: isChecked.value,
      enabled: enabled,
      onTap: !enabled
          ? null
          : () {
              final newValue = !isChecked.value;
              isChecked.value = newValue;
              onChanged!(newValue);
            },
      child: buildWiredElement(
        child: Container(
          padding: EdgeInsets.zero,
          height: 27.0,
          width: 27.0,
          decoration: RoughBoxDecoration(
            progress: WiredDrawTransition.progressOf(context),
            pressure: WiredInkResponse.pressureOf(context),
            drawConfig: theme.drawConfig,
            shape: RoughBoxShape.roundedRectangle,
            borderRadius: borderRadius,
            borderStyle: RoughDrawingStyle(
              width: theme.strokeWidth,
              color: theme.borderColor,
            ),
          ),
          child: SizedBox(
            height: double.infinity,
            child: Transform.scale(
              scale: 1.5,
              child: Checkbox(
                side: BorderSide.none,
                fillColor: WidgetStateProperty.all(Colors.transparent),
                checkColor: theme.borderColor,
                onChanged: !enabled
                    ? null
                    : (newValue) {
                        isChecked.value = newValue ?? false;
                        onChanged!(newValue);
                      },
                value: isChecked.value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
