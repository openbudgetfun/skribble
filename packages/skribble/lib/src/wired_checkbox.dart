import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

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
    final isChecked = useState(value ?? false);

    return buildWiredElement(
      key: key,
      child: Container(
        padding: EdgeInsets.zero,
        height: 27.0,
        width: 27.0,
        decoration: RoughBoxDecoration(
          shape: RoughBoxShape.rectangle,
          borderStyle: RoughDrawingStyle(width: 1, color: borderColor),
        ),
        child: SizedBox(
          height: double.infinity,
          child: Transform.scale(
            scale: 1.5,
            child: Checkbox(
              fillColor: WidgetStateProperty.all(Colors.transparent),
              checkColor: borderColor,
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
