import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A horizontally scrolling hand-drawn carousel of rough-bordered cards,
/// analogous to Material 3's `CarouselView`.
///
/// Each item is drawn with a sketchy [WiredRoundedRectangleBase] border (and
/// an optional hachure fill when [fill] is true) that reads its colors from
/// the nearest [WiredTheme] ancestor.
///
/// Example:
///
/// ```dart
/// WiredCarouselView(
///   itemExtent: 200,
///   height: 180,
///   onTap: (index) => print('Tapped item $index'),
///   children: [
///     Center(child: Text('Item 1')),
///     Center(child: Text('Item 2')),
///   ],
/// )
/// ```
///
/// See also:
///  * `WiredCard`, the single hand-drawn card this widget draws per item.
class WiredCarouselView extends HookWidget {
  /// The widgets displayed as carousel items.
  final List<Widget> children;

  /// The width of each carousel item. Defaults to `220.0`, matching the
  /// Material 3 carousel's typical item width. Set to `null` to size each
  /// item to its intrinsic width.
  final double? itemExtent;

  /// The height of the carousel. Defaults to `200.0`, matching the Material 3
  /// carousel's default cross-axis extent.
  final double height;

  /// Whether the carousel should size itself to its content instead of
  /// filling the available space. Defaults to `true`, matching the Material 3
  /// `CarouselView.shrinkWrap` constructor.
  final bool shrinkWrap;

  /// Whether item cards get a hachure (sketchy) background fill.
  final bool fill;

  /// Corner rounding of each item card's rough border.
  final BorderRadius borderRadius;

  /// Padding around the scrollable carousel content.
  final EdgeInsetsGeometry padding;

  /// Whether the carousel scrolls in the reading direction's reverse.
  final bool reverse;

  /// Called with the tapped item's index, or `null` for a static carousel.
  final ValueChanged<int>? onTap;

  /// Optional semantic label describing the carousel for accessibility.
  final String? semanticLabel;

  const WiredCarouselView({
    super.key,
    required this.children,
    this.itemExtent = 220.0,
    this.height = 200.0,
    this.shrinkWrap = true,
    this.fill = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = EdgeInsets.zero,
    this.reverse = false,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);

    final Widget list;
    if (shrinkWrap || itemExtent == null) {
      list = ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: shrinkWrap,
        reverse: reverse,
        padding: padding,
        children: [
          for (var i = 0; i < children.length; i++)
            _buildItem(index: i, theme: theme),
        ],
      );
    } else {
      list = ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: reverse,
        padding: padding,
        itemCount: children.length,
        itemExtent: itemExtent,
        // ListView.builder handles [reverse] ordering itself.
        itemBuilder: (context, index) => _buildItem(index: index, theme: theme),
      );
    }

    return Semantics(
      label: semanticLabel,
      container: true,
      child: buildWiredElement(
        child: SizedBox(
          height: height,
          child: list,
        ),
      ),
    );
  }

  Widget _buildItem({
    required int index,
    required WiredThemeData theme,
  }) {
    // The child is the non-positioned (sizing) element of the card so that
    // items without a fixed [itemExtent]/[height] still size to their
    // content. When the carousel fixes a dimension, the corresponding tight
    // constraint makes the child fill the card instead.
    final card = Stack(
      children: [
        Positioned.fill(
          child: WiredCanvas(
            painter: WiredRoundedRectangleBase(
              borderRadius: borderRadius,
              fillColor: theme.fillColor,
              borderColor: theme.borderColor,
            ),
            fillerType: fill ? RoughFilter.hachureFiller : RoughFilter.noFiller,
          ),
        ),
        children[index],
      ],
    );

    final sized = itemExtent != null
        ? SizedBox(width: itemExtent, child: card)
        : IntrinsicWidth(child: card);

    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null ? null : () => onTap!(index),
        child: sized,
      ),
    );
  }
}
