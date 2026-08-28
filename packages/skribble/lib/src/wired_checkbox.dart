import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn checkbox, corresponding to Flutter's `Checkbox`.
///
/// Draws a sketchy circle border with a hachure-filled checkmark when
/// [value] is `true`. Supports tristate (`null`) values.
///
/// The checkbox is wrapped in [Semantics] for accessibility, providing
/// screen readers with the current checked state.
///
/// See also:
///  * `WiredCheckboxListTile`, which combines this with a label.
class WiredCheckbox extends HookWidget {
  final bool? value;
  final void Function(bool?) onChanged;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isChecked = useState(value ?? false);

    return Semantics(
      label: semanticLabel,
      checked: isChecked.value,
      onTap: () {
        final newValue = !isChecked.value;
        isChecked.value = newValue;
        onChanged(newValue);
      },
      child: buildWiredElement(
        key: key,
        child: Container(
          padding: EdgeInsets.zero,
          height: 27.0,
          width: 27.0,
          decoration: RoughBoxDecoration(
            shape: RoughBoxShape.rectangle,
            borderStyle: RoughDrawingStyle(width: 1, color: theme.borderColor),
          ),
          child: SizedBox(
            height: double.infinity,
            child: Transform.scale(
              scale: 1.5,
              child: Checkbox(
                fillColor: WidgetStateProperty.all(Colors.transparent),
                checkColor: theme.borderColor,
                onChanged: (newValue) {
                  isChecked.value = newValue ?? false;
                  onChanged(newValue);
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
