import 'package:flutter/material.dart';

import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

class WiredButton extends WiredBaseWidget {
  final Widget child;
  final void Function() onPressed;

  const WiredButton({super.key, required this.child, required this.onPressed});

  @override
  Widget buildWiredElement() {
    return Container(
      padding: EdgeInsets.zero,
      height: 42.0,
      decoration: RoughBoxDecoration(
        shape: RoughBoxShape.rectangle,
        borderStyle: RoughDrawingStyle(width: 1, color: borderColor),
      ),
      child: SizedBox(
        height: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(foregroundColor: textColor),
          onPressed: onPressed,
          child: child,
        ),
      ),
    );
  }
}
