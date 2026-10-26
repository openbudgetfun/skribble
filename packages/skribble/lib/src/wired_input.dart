import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn text field, corresponding to Flutter's `TextField`.
///
/// Wraps a `TextField` with a sketchy rounded-rectangle border drawn using
/// `WiredRoundedRectangleBase`. Supports a wrapping label, a hint,
/// prefix and suffix widgets and icons, error text, input formatters,
/// keyboard configuration, and the common text input callbacks.
///
/// The text field is wrapped in [Semantics] for accessibility, providing
/// screen readers with the field label and current value.
///
/// See also:
///  * `WiredTextArea`, for multiline text input.
///  * `WiredSearchBar`, for a search-specific input.
///  * `WiredCupertinoTextField`, for Cupertino styling.
class WiredInput extends HookWidget {
  /// Controller for the editable value. An internal controller is used if absent.
  final TextEditingController? controller;

  /// Text style merged with the app typography.
  final TextStyle? style;

  /// Wrapping label placed above the field.
  final String? labelText;

  /// Optional style for the label.
  final TextStyle? labelStyle;

  /// Hint displayed while the field is empty.
  final String? hintText;

  /// Optional style for the hint.
  final TextStyle? hintStyle;

  /// Called when the user edits the value.
  final void Function(String)? onChanged;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Input formatters applied to every edit, such as deny-listing characters.
  final List<TextInputFormatter>? inputFormatters;

  /// The keyboard's input type, such as `TextInputType.emailAddress`.
  final TextInputType? keyboardType;

  /// The keyboard's action button, such as `TextInputAction.search`.
  final TextInputAction? textInputAction;

  /// Limits the value's length when set.
  final int? maxLength;

  /// Whether the field accepts input; disabled fields draw dimmed ink.
  final bool enabled;

  /// Grabs focus as soon as the field appears.
  final bool autofocus;

  /// Widget placed before the editable value, inside the ink.
  final Widget? prefix;

  /// Widget placed after the editable value, inside the ink.
  final Widget? suffix;

  /// Icon placed before the editable value, inside the ink.
  final Widget? prefixIcon;

  /// Icon placed after the editable value, inside the ink.
  final Widget? suffixIcon;

  /// Error text placed under the ink; the border is drawn from the error
  /// color while it is set.
  final String? errorText;

  /// Whether to conceal the entered text.
  final bool obscureText;

  /// Soft corners for the ink outline. Use [BorderRadius.zero] for square ink.
  final BorderRadius borderRadius;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates an input with a single sketch border, an optional label, and the
  /// common `TextField` parameters.
  const WiredInput({
    super.key,
    this.controller,
    this.style,
    this.labelText,
    this.labelStyle,
    this.hintText,
    this.hintStyle,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.obscureText = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.semanticLabel,
    this.seed,
  });

  /// Varies the hand behind this widget's ink. The same seed always draws
  /// the same wobble, so neighbouring shapes of the same size need different
  /// seeds to stop them reading as copies of each other. Null keeps the
  /// theme's seed.
  final int? seed;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final focus = useFocusNode();
    useListenable(focus);
    final hasError = errorText != null;
    final inkColor = !enabled
        ? theme.disabledTextColor
        : hasError
        ? theme.errorColor
        : theme.borderColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          ExcludeSemantics(child: Text(labelText!, style: labelStyle)),
          const SizedBox(height: 8),
        ],
        Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(
                  borderRadius: borderRadius,
                  fillColor: theme.fillColor,
                  borderColor: inkColor,
                  strokeWidth: theme.strokeWidth + (focus.hasFocus ? 0.6 : 0),
                ),
                seed: seed,
                fillerType: RoughFilter.noFiller,
              ),
            ),
            Semantics(
              container: true,
              label: semanticLabel ?? labelText,
              child: TextField(
                controller: controller,
                focusNode: focus,
                style: style,
                enabled: enabled,
                autofocus: autofocus,
                obscureText: obscureText,
                keyboardType: keyboardType,
                textInputAction: textInputAction,
                maxLength: maxLength,
                inputFormatters: inputFormatters,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: theme.disabledTextColor,
                  ).merge(hintStyle),
                  prefix: prefix,
                  suffix: suffix,
                  prefixIcon: prefixIcon,
                  suffixIcon: suffixIcon,
                  errorText: errorText,
                  errorStyle: TextStyle(color: theme.errorColor),
                  counterText: maxLength == null ? '' : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
