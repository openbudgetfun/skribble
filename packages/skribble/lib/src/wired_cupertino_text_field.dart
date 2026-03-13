import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_theme.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A hand-drawn text field corresponding to Flutter's [CupertinoTextField].
///
/// Wraps a standard [TextField] with a sketchy rounded rectangle border
/// in a Cupertino-style layout with prefix/suffix support.
class WiredCupertinoTextField extends HookWidget {
  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Placeholder text shown when the field is empty.
  final String? placeholder;

  /// Style for the placeholder text.
  final TextStyle? placeholderStyle;

  /// A widget to display before the text field.
  final Widget? prefix;

  /// A widget to display after the text field.
  final Widget? suffix;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (e.g. presses done).
  final ValueChanged<String>? onSubmitted;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to obscure text (for passwords).
  final bool obscureText;

  /// Whether the field is enabled.
  final bool enabled;

  /// Maximum number of lines.
  final int? maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum text length.
  final int? maxLength;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Text input action.
  final TextInputAction? textInputAction;

  /// Style for the input text.
  final TextStyle? style;

  /// Padding inside the text field.
  final EdgeInsetsGeometry padding;

  /// Border radius of the field.
  final BorderRadius borderRadius;

  /// Focus node.
  final FocusNode? focusNode;

  /// Whether to autofocus.
  final bool autofocus;

  const WiredCupertinoTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.placeholderStyle,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.style,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 150),
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(borderRadius: borderRadius),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            Row(
              children: [
                if (prefix != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: prefix!,
                  ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: autofocus,
                    readOnly: readOnly,
                    obscureText: obscureText,
                    enabled: enabled,
                    maxLines: maxLines,
                    minLines: minLines,
                    maxLength: maxLength,
                    keyboardType: keyboardType,
                    textInputAction: textInputAction,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    style:
                        style ??
                        TextStyle(color: theme.textColor, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle:
                          placeholderStyle ??
                          TextStyle(
                            color: theme.textColor.withValues(alpha: 0.4),
                            fontSize: 16,
                          ),
                      border: InputBorder.none,
                      contentPadding: padding,
                      isDense: true,
                      counterText: '',
                    ),
                  ),
                ),
                if (suffix != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: suffix!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
