import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn wrapper around Flutter's [Form].
class WiredForm extends HookWidget {
  /// The form's fields. See [Form.child].
  final Widget child;

  /// The key given to the inner [Form], used to validate, save, or reset it
  /// through [FormState].
  final GlobalKey<FormState>? formKey;

  /// See [Form.autovalidateMode]. Defaults to [AutovalidateMode.disabled].
  final AutovalidateMode autovalidateMode;

  /// See [Form.onChanged].
  final VoidCallback? onChanged;

  /// The space between the hand-drawn border and [child]. Defaults to 16
  /// logical pixels on every side.
  final EdgeInsetsGeometry padding;

  /// The corner radius of the hand-drawn border. Defaults to 16 logical
  /// pixels.
  final BorderRadius borderRadius;

  /// Creates a form with a hand-drawn rounded border.
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
                strokeWidth: theme.strokeWidth,
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
