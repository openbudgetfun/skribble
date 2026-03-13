import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

class WiredCheckbox extends HookWidget {
  final bool? value;
  final void Function(bool?) onChanged;

  const WiredCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isChecked = useState(value ?? false);

    return buildWiredElement(
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
    );
  }
}
