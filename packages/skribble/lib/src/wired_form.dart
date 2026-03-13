import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn wrapper around Flutter's [Form].
class WiredForm extends HookWidget {
  final Widget child;
  final GlobalKey<FormState>? formKey;
  final AutovalidateMode autovalidateMode;
  final VoidCallback? onChanged;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const WiredForm({
    super.key,
    required this.child,
    this.formKey,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onChanged,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Stack(
        children: [
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                borderRadius: borderRadius,
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Padding(
            padding: padding,
            child: Form(
              key: formKey,
              autovalidateMode: autovalidateMode,
              onChanged: onChanged,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
