import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn form section wrapper corresponding to Flutter's
/// `CupertinoFormSection.insetGrouped`.
///
/// Groups form rows ([children]) in a single hand-drawn rounded
/// rectangle with sketchy dividers between rows. Optional [header] and
/// [footer] text are rendered above and below the group in a smaller
/// footnote style.
///
/// Unlike `WiredCupertinoListSection`, the group is deliberately left
/// unfilled so nested input widgets keep a clean paper background.
///
/// ## Example
///
/// ```dart
/// WiredCupertinoFormSection(
///   header: Text('Account'),
///   children: [
///     WiredInput(labelText: 'Name'),
///     WiredInput(labelText: 'Email'),
///   ],
/// )
/// ```
class WiredCupertinoFormSection extends HookWidget {
  /// Widget rendered above the group, typically small helper text.
  final Widget? header;

  /// Widget rendered below the group, typically small footnote text.
  final Widget? footer;

  /// The rows of the form section, e.g. inputs and tiles.
  final List<Widget> children;

  /// Outer margin around the whole section. Defaults to
  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`.
  final EdgeInsetsGeometry margin;

  /// Horizontal inset used by the hand-drawn dividers, so they line up
  /// with the row content while staying inset from the edges.
  final double dividerIndent;

  /// Creates a hand-drawn Cupertino-style form section.
  const WiredCupertinoFormSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.dividerIndent = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: DefaultTextStyle(
                style: TextStyle(color: theme.disabledTextColor, fontSize: 13),
                child: header!,
              ),
            ),
          Stack(
            children: [
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    borderRadius: BorderRadius.circular(10),
                    fillColor: theme.fillColor,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i < children.length - 1) _buildDivider(theme),
                  ],
                ],
              ),
            ],
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 6),
              child: DefaultTextStyle(
                style: TextStyle(color: theme.disabledTextColor, fontSize: 13),
                child: footer!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(WiredThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: WiredCanvas(
        painter: WiredLineBase(
          x1: dividerIndent,
          y1: 0,
          x2: double.infinity,
          y2: 0,
          borderColor: theme.borderColor,
          strokeWidth: 1,
        ),
        fillerType: RoughFilter.noFiller,
      ),
    );
  }
}
