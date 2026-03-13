import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_theme.dart';
import 'wired_base.dart';

/// A hand-drawn selectable text corresponding to Flutter's [SelectableText].
///
/// Provides selectable text with the Skribble hand-drawn text styling.
class WiredSelectableText extends HookWidget {
  /// The text to display.
  final String data;

  /// Style for the text.
  final TextStyle? style;

  /// Text alignment.
  final TextAlign? textAlign;

  /// Text direction.
  final TextDirection? textDirection;

  /// Maximum number of lines.
  final int? maxLines;

  /// Whether to show the cursor.
  final bool showCursor;

  /// The cursor color.
  final Color? cursorColor;

  /// The cursor width.
  final double cursorWidth;

  /// The cursor radius.
  final Radius? cursorRadius;

  /// Called when the selection changes.
  final SelectionChangedCallback? onSelectionChanged;

  /// Focus node.
  final FocusNode? focusNode;

  /// Whether to autofocus.
  final bool autofocus;

  /// Semantic label.
  final String? semanticsLabel;

  const WiredSelectableText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.showCursor = false,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.onSelectionChanged,
    this.focusNode,
    this.autofocus = false,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: SelectableText(
        data,
        style: style ?? TextStyle(color: theme.textColor, fontSize: 16),
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        showCursor: showCursor,
        cursorColor: cursorColor ?? theme.borderColor,
        cursorWidth: cursorWidth,
        cursorRadius: cursorRadius,
        onSelectionChanged: onSelectionChanged,
        focusNode: focusNode,
        autofocus: autofocus,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
