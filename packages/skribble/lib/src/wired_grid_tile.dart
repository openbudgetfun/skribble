import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'canvas/wired_ink_splash.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A grid tile with hand-drawn borders and optional header/footer bars.
///
/// Mirrors Material's [GridTile]: the [child] fills the tile, while [header]
/// and [footer] are stacked on top of it (top and bottom respectively).
/// Tapping the tile triggers a hand-drawn ink splash
/// (see [WiredInkSplashFactory]).
///
/// Typical usage inside a [GridView]:
///
/// ```dart
/// WiredGridTile(
///   onTap: () => print('tapped'),
///   footer: const WiredGridTileBar(title: Text('Gallery item')),
///   child: const ColoredBox(color: Color(0xFFDDDDDD)),
/// )
/// ```
class WiredGridTile extends HookWidget {
  /// The tile content, painted edge-to-edge beneath the bars.
  final Widget child;

  /// Optional widget shown above the child, anchored to the top edge.
  final Widget? header;

  /// Optional widget shown above the child, anchored to the bottom edge.
  final Widget? footer;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredGridTile({
    super.key,
    required this.child,
    this.header,
    this.footer,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      onTap: onTap,
      child: buildWiredElement(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: InkWell(
                splashFactory: WiredInkSplashFactory(),
                onTap: onTap,
                child: child,
              ),
            ),
            if (header != null)
              Positioned(top: 0, left: 0, right: 0, child: header!),
            if (footer != null)
              Positioned(bottom: 0, left: 0, right: 0, child: footer!),
          ],
        ),
      ),
    );
  }
}

/// A bar for use as [WiredGridTile.header] or [WiredGridTile.footer].
///
/// Mirrors Material's [GridTileBar]: a translucent horizontal strip
/// containing a [leading] widget, the [title] (with optional [subtitle])
/// and a [trailing] widget. The bar is closed off with a hand-drawn
/// line so it stays consistent with the sketchy aesthetic.
class WiredGridTileBar extends HookWidget {
  /// Foreground color for text and icons.
  final Color? color;

  /// Background color of the bar. Defaults to a translucent paper tone.
  final Color? backgroundColor;

  /// Bar height.
  final double height;

  /// Spacing between the [leading], [title] and [trailing] widgets.
  final double titleSpacing;

  /// Widget shown at the start of the bar.
  final Widget? leading;

  /// Primary text of the bar.
  final Widget? title;

  /// Secondary text shown below [title].
  final Widget? subtitle;

  /// Widget shown at the end of the bar.
  final Widget? trailing;

  const WiredGridTileBar({
    super.key,
    this.color,
    this.backgroundColor,
    this.height = 56,
    this.titleSpacing = 16,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final barColor = backgroundColor ?? theme.fillColor.withValues(alpha: 0.85);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: barColor)),
          // Hand-drawn edge so the bar reads as sketched, not machine-cut.
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: SizedBox(
              height: 2,
              child: WiredCanvas(
                painter: WiredLineBase(
                  x1: 0,
                  y1: 1,
                  x2: double.infinity,
                  y2: 1,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: titleSpacing),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          DefaultTextStyle(
                            style: TextStyle(
                              color: color ?? theme.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            child: title!,
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          DefaultTextStyle(
                            style: TextStyle(
                              color:
                                  color ??
                                  theme.textColor.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                            child: subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    SizedBox(width: titleSpacing),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
