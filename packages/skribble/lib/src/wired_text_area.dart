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
  /// Controls the text being edited. When null, the field manages its own.
  final TextEditingController? controller;

  /// Style for the entered text.
  final TextStyle? style;

  /// Hint shown while the field is empty.
  final String? hintText;

  /// Style for [hintText].
  final TextStyle? hintStyle;

  /// Called with the new text whenever it changes.
  final void Function(String)? onChanged;

  /// The most lines shown before the field scrolls. Defaults to 5.
  final int maxLines;

  /// The fewest lines of height the field takes up. Defaults to 3.
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
            style: style,
            maxLines: maxLines,
            minLines: minLines,
            decoration: InputDecoration(
              filled: false,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: hintStyle,
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
