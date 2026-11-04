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
/// The checkbox is controlled: it shows [value] and reports taps through
/// [onChanged], and only checks once its parent rebuilds it with the new
/// value, as Material's `Checkbox` does.
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
  /// Null disables the checkbox: taps are ignored and the box and its check
  /// are drawn in the theme's disabled color.
  final ValueChanged<bool?>? onChanged;

  /// Soft corners for the box. Use [BorderRadius.zero] for square ink.
  final BorderRadius borderRadius;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates a hand-drawn checkbox.
  const WiredCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final checked = value ?? false;
    final enabled = onChanged != null;
    final ink = enabled ? theme.borderColor : theme.disabledTextColor;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticLabel,
      checked: checked,
      enabled: enabled,
      onTap: !enabled ? null : () => onChanged!(!checked),
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
              color: ink,
            ),
          ),
          child: SizedBox(
            height: double.infinity,
            child: Transform.scale(
              scale: 1.5,
              child: Checkbox(
                side: BorderSide.none,
                fillColor: WidgetStateProperty.all(Colors.transparent),
                checkColor: ink,
                onChanged: !enabled ? null : onChanged,
                value: checked,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
