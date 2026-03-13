import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn text field, corresponding to Flutter's `TextField`.
///
/// Wraps a `TextField` with a sketchy rectangle border drawn using
/// `WiredRectangleBase`. Supports label, hint, prefix/suffix icons,
/// and all standard text input callbacks.
///
/// See also:
///  * `WiredTextArea`, for multiline text input.
///  * `WiredSearchBar`, for a search-specific input.
///  * `WiredCupertinoTextField`, for Cupertino styling.
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
    final theme = WiredTheme.of(context);
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
                  painter: WiredRectangleBase(
                    fillColor: theme.fillColor,
                    borderColor: theme.borderColor,
                  ),
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
