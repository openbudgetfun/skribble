import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// An app bar with a hand-drawn bottom border.
///
/// The [title] stays on one line and ends with an ellipsis when it does not
/// fit. Like Material's app bar, its text grows with the platform's text
/// scaling up to 1.34 times, so a large setting cannot push the title out
/// of the bar's fixed [height]. Screen readers hear the title as a header.
class WiredAppBar extends HookWidget implements PreferredSizeWidget {
  /// The primary content, usually a [Text].
  final Widget? title;

  /// A widget before the title, such as a menu or back button.
  final Widget? leading;

  /// Widgets after the title, such as icon buttons.
  final List<Widget>? actions;

  /// The bar's height below the status bar, including its ink line.
  final double height;

  /// The bar's background. Defaults to transparent.
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
                      child: MediaQuery.withClampedTextScaling(
                        maxScaleFactor: _kMaxTitleTextScaleFactor,
                        child: Semantics(
                          header: true,
                          child: DefaultTextStyle.merge(
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            child: title!,
                          ),
                        ),
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

/// The largest text scale an app bar title follows, as in Material's
/// `AppBar`: past it, the title would not fit the bar's fixed height.
const double _kMaxTitleTextScaleFactor = 1.34;
