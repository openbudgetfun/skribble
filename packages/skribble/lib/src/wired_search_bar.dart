import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'generated/skribble_glyphs.g.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A search bar with a hand-drawn rounded rectangle border.
class WiredSearchBar extends HookWidget {
  /// Controls the text being edited. When null, the field manages its own.
  final TextEditingController? controller;

  /// Hint shown while the field is empty. Defaults to 'Search...'.
  final String? hintText;

  /// Called with the new text whenever it changes.
  final ValueChanged<String>? onChanged;

  /// Called with the text when the user submits the search.
  final ValueChanged<String>? onSubmitted;

  /// Widget shown before the field. Defaults to a hand-drawn search icon.
  final Widget? leading;

  /// Optional widget shown after the field.
  final Widget? trailing;

  /// Called when the search bar is tapped. Use with `WiredSearchAnchor` to
  /// open the suggestions view: `onTap: controller.openView`.
  final VoidCallback? onTap;

  /// Whether the internal text field should request focus on first build.
  final bool autoFocus;

  /// Creates a hand-drawn search bar.
  const WiredSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.leading,
    this.trailing,
    this.onTap,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    // A pill at least 48 pixels tall that grows with its text, with room
    // for the curve at each end.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                strokeWidth: theme.strokeWidth,
                borderRadius: BorderRadius.circular(24),
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                leading ??
                    WiredSvgIcon(
                      data: SkribbleGlyphs.search,
                      color: theme.disabledTextColor,
                      size: 20,
                    ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    // Every border and the fill are spelled out: the Material
                    // bridge theme supplies outlined, filled defaults that
                    // would otherwise draw a second box inside the ink.
                    decoration: InputDecoration(
                      // Desktop's compact density would take 4 pixels off each side of
                      // the padding, bringing text within the ink's breathing room.
                      visualDensity: VisualDensity.standard,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: hintText ?? 'Search...',
                      hintStyle: TextStyle(color: theme.disabledTextColor),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(color: theme.textColor),
                    autofocus: autoFocus,
                    onTap: onTap,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
