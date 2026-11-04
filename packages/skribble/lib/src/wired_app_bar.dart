import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// An app bar with a hand-drawn bottom border.
///
/// The [title] stays on one line and ends with an ellipsis when it does not
/// fit. Like Material's app bar, its title grows with the platform's text
/// scaling up to 1.34 times, so a large setting cannot push it out of the
/// bar's fixed [height]. The same limit applies to [leading] and [actions],
/// so a text button there keeps its ink padding instead of being squeezed
/// against the bar's line. Screen readers hear the title as a header.
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
            // Text in the fixed-height toolbar stops growing at the same
            // scale as Material's app bar title.
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: _kMaxTitleTextScaleFactor,
              child: Row(
                children: [
                  ?leading,
                  if (title != null)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    )
                  else
                    const Spacer(),
                  ...?actions,
                ],
              ),
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

/// The largest text scale an app bar's contents follow, as in Material's
/// `AppBar` title: past it, they would not fit the bar's fixed height.
const double _kMaxTitleTextScaleFactor = 1.34;
