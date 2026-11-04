import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// An app bar with a hand-drawn bottom border.
class WiredAppBar extends HookWidget implements PreferredSizeWidget {
  /// The primary content, usually a [Text], shown in bold 20 pixel text.
  final Widget? title;

  /// A widget shown before the [title], such as a menu or back button.
  final Widget? leading;

  /// Widgets shown in a row after the [title], such as icon buttons.
  final List<Widget>? actions;

  /// The total height in logical pixels, including the hand-drawn bottom
  /// line. Defaults to 56.
  final double height;

  /// The colour behind the bar's content. Null leaves it transparent.
  final Color? backgroundColor;

  /// Creates a hand-drawn app bar.
  const WiredAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.height = 56.0,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final inkHeight = theme.inkExtent.clamp(0.0, height);
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: height - inkHeight,
            color: backgroundColor ?? Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                ?leading,
                if (title != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        child: title!,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                ...?actions,
              ],
            ),
          ),
          SizedBox(
            height: inkHeight,
            child: WiredCanvas(
              painter: WiredLineBase(
                x1: 0,
                y1: 0,
                x2: double.infinity,
                y2: 0,
                strokeWidth: theme.strokeWidth,
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
        ],
      ),
    );
  }
}
