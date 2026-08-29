import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn list tile corresponding to Flutter's `CupertinoListTile`.
///
/// Provides the same leading / title / subtitle / trailing API as
/// `CupertinoListTile` with an optional hand-drawn background fill.
/// Designed to be used as a child of `WiredCupertinoListSection`, which
/// draws the group border and hand-drawn separators between tiles.
///
/// Text styles default from the nearest `WiredTheme`: the title uses the
/// theme text color at 17px, the subtitle and additional trailing text
/// use the disabled text color at 14px.
///
/// ## Example
///
/// ```dart
/// WiredCupertinoListTile(
///   leading: Text('📄'),
///   title: Text('Page 1'),
///   subtitle: Text('First page of the document'),
///   additionalTrailingText: '12 KB',
///   trailing: Text('›'),
///   onTap: () {},
/// )
/// ```
class WiredCupertinoListTile extends HookWidget {
  /// A widget displayed at the start of the tile.
  final Widget? leading;

  /// The primary content of the tile.
  final Widget? title;

  /// Secondary content displayed below the title.
  final Widget? subtitle;

  /// A widget displayed at the end of the tile, typically a chevron.
  final Widget? trailing;

  /// Small text displayed just before [trailing], like a detail label.
  final String? additionalTrailingText;

  /// Called when the tile is tapped.
  final VoidCallback? onTap;

  /// Background fill color of the tile. When set, the tile paints a
  /// hand-drawn rounded rectangle behind the content.
  final Color? backgroundColor;

  /// Padding around the tile content. Defaults to
  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 10)`.
  final EdgeInsetsGeometry? padding;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  /// Creates a hand-drawn Cupertino-style list tile.
  const WiredCupertinoListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.additionalTrailingText,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.semanticLabel,
  }) : assert(
         title != null || subtitle != null,
         'Either title or subtitle must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    final content = Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style: TextStyle(color: theme.textColor, fontSize: 17),
                    child: title!,
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle(
                    style: TextStyle(
                      color: theme.disabledTextColor,
                      fontSize: 14,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (additionalTrailingText != null) ...[
            const SizedBox(width: 8),
            DefaultTextStyle(
              style: TextStyle(color: theme.disabledTextColor, fontSize: 14),
              child: Text(additionalTrailingText!),
            ),
          ],
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      onTap: onTap,
      child: GestureDetector(
        // Opaque so the whole row is tappable, not just the text.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          children: [
            if (backgroundColor != null)
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    borderRadius: BorderRadius.circular(8),
                    fillColor: backgroundColor!,
                    borderColor: backgroundColor!,
                  ),
                  fillerType: RoughFilter.solidFiller,
                ),
              ),
            content,
          ],
        ),
      ),
    );
  }
}
