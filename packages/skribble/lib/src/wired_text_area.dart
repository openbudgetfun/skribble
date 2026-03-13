import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A multi-line text input with a hand-drawn border.
class WiredTextArea extends HookWidget {
  final TextEditingController? controller;
  final TextStyle? style;
  final String? hintText;
  final TextStyle? hintStyle;
  final void Function(String)? onChanged;
  final int maxLines;
  final int minLines;

  const WiredTextArea({
    super.key,
    this.controller,
    this.style,
    this.hintText,
    this.hintStyle,
    this.onChanged,
    this.maxLines = 5,
    this.minLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: WiredCanvas(
            painter: WiredRectangleBase(fillColor: theme.fillColor),
            fillerType: RoughFilter.noFiller,
          ),
        ),
        TextField(
          controller: controller,
          style: style,
          maxLines: maxLines,
          minLines: minLines,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: hintStyle,
            contentPadding: const EdgeInsets.all(8.0),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
