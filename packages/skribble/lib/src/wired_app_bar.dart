import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// An app bar with a hand-drawn bottom border.
class WiredAppBar extends HookWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final double height;
  final Color? backgroundColor;

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
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: height - 2,
            color: backgroundColor ?? Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                ?leading,
                if (title != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DefaultTextStyle(
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
                if (actions != null) ...actions!,
              ],
            ),
          ),
          SizedBox(
            height: 2,
            child: WiredCanvas(
              painter: WiredLineBase(
                x1: 0,
                y1: 0,
                x2: double.infinity,
                y2: 0,
                strokeWidth: 2,
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
