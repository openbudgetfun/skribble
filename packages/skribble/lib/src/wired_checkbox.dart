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
    useEffect(() {
      isChecked.value = value ?? false;
      return null;
    }, [value]);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: semanticLabel,
      checked: isChecked.value,
      onTap: () {
        final newValue = !isChecked.value;
        isChecked.value = newValue;
        onChanged(newValue);
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
            shape: RoughBoxShape.rectangle,
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
