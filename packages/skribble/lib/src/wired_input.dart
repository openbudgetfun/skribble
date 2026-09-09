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

  /// Whether to conceal the entered text.
  final bool obscureText;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates an input with a single sketch border and an optional label.
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
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final focus = useFocusNode();
    useListenable(focus);

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
                painter: WiredRectangleBase(
                  fillColor: theme.fillColor,
                  borderColor: theme.borderColor,
                  strokeWidth: theme.strokeWidth + (focus.hasFocus ? 0.6 : 0),
                ),
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
                obscureText: obscureText,
                decoration: InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(color: theme.disabledTextColor)
                      .merge(hintStyle),
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
