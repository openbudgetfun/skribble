import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_theme.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

class WiredRadio<T> extends HookWidget {
  final T value;
  final T? groupValue;
  final bool Function(T? value)? onChanged;

  const WiredRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isSelected = value == groupValue;

    return buildWiredElement(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 48.0,
            width: 48.0,
            child: WiredCanvas(
              painter: WiredCircleBase(diameterRatio: .7),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          if (isSelected)
            SizedBox(
              height: 24.0,
              width: 24.0,
              child: WiredCanvas(
                painter: WiredCircleBase(
                  diameterRatio: .7,
                  fillColor: theme.textColor,
                ),
                fillerType: RoughFilter.hachureFiller,
                fillerConfig: FillerConfig.build(hachureGap: 1.0),
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
    );
  }
}
