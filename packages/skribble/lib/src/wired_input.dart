import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';

class WiredInput extends HookWidget {
  final TextEditingController? controller;
  final TextStyle? style;
  final String? labelText;
  final TextStyle? labelStyle;
  final String? hintText;
  final TextStyle? hintStyle;
  final void Function(String)? onChanged;
  final bool obscureText;

  const WiredInput({
    super.key,
    this.controller,
    this.style,
    this.labelText,
    this.labelStyle,
    this.hintText,
    this.hintStyle,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (labelText != null) Text('$labelText', style: labelStyle),
        if (labelText != null) SizedBox(width: 10.0),
        Expanded(
          child: Stack(
            children: [
              SizedBox(
                height: 48.0,
                child: WiredCanvas(
                  painter: WiredRectangleBase(),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              TextField(
                controller: controller,
                style: style,
                obscureText: obscureText,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: hintStyle,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                ),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
