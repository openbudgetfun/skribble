import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A multi-line text input with a hand-drawn border.
///
/// The text area is wrapped in [Semantics] for accessibility, providing
/// screen readers with the field label and current value.
class WiredTextArea extends HookWidget {
  /// Controller for the editable value. An internal controller is used if
  /// absent.
  final TextEditingController? controller;

  /// Text style for the value, merged over the theme's text colour.
  final TextStyle? style;

  /// Hint displayed while the area is empty.
  final String? hintText;

  /// Style for the hint, merged over the theme's disabled text colour.
  final TextStyle? hintStyle;

  /// Called when the user edits the value.
  final void Function(String)? onChanged;

  /// The most lines shown before the area scrolls.
  final int maxLines;

  /// The fewest lines the area is tall.
  final int minLines;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates a multi-line text area with a hand-drawn border.
  const WiredTextArea({
    super.key,
    this.controller,
    this.style,
    this.hintText,
    this.hintStyle,
    this.onChanged,
    this.maxLines = 5,
    this.minLines = 3,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel,
      textField: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                // The same soft corners as a single-line WiredInput.
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                strokeWidth: theme.strokeWidth,
                fillColor: theme.fillColor,
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          TextField(
            controller: controller,
            // The theme's ink, so the value stays readable on dark paper.
            style: TextStyle(color: theme.textColor).merge(style),
            cursorColor: theme.borderColor,
            maxLines: maxLines,
            minLines: minLines,
            decoration: InputDecoration(
              // Desktop's compact density would take 4 pixels off each side of
              // the padding, bringing text within the ink's breathing room.
              visualDensity: VisualDensity.standard,
              filled: false,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                color: theme.disabledTextColor,
              ).merge(hintStyle),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
