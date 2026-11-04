import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'generated/skribble_glyphs.g.dart';
import 'motion/wired_draw.dart';
import 'motion/wired_ink_response.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A popup menu item for [WiredPopupMenuButton].
class WiredPopupMenuItem<T> {
  /// The value passed to [WiredPopupMenuButton.onSelected] when this item is
  /// chosen.
  final T value;

  /// The item's content, usually a [Text].
  final Widget child;

  /// Creates a popup menu item.
  const WiredPopupMenuItem({required this.value, required this.child});
}

/// A popup menu button with hand-drawn menu items.
class WiredPopupMenuButton<T> extends HookWidget {
  /// The items shown in the menu, in order.
  final List<WiredPopupMenuItem<T>> items;

  /// Called with the chosen item's [WiredPopupMenuItem.value].
  final void Function(T)? onSelected;

  /// The button's icon. Defaults to a hand-drawn vertical ellipsis.
  final Widget? icon;

  /// Creates a popup menu button for [items].
  const WiredPopupMenuButton({
    super.key,
    required this.items,
    this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: PopupMenuButton<T>(
        icon:
            icon ??
            WiredSvgIcon(
              data: SkribbleGlyphs.moreVertical,
              color: theme.textColor,
            ),
        onSelected: onSelected,
        color: theme.fillColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.borderColor, width: theme.strokeWidth),
        ),
        itemBuilder: (context) => items.map((item) {
          return PopupMenuItem<T>(
            value: item.value,
            child: Container(
              decoration: RoughBoxDecoration(
                progress: WiredDrawTransition.progressOf(context),
                pressure: WiredInkResponse.pressureOf(context),
                drawConfig: theme.drawConfig,
                shape: RoughBoxShape.rectangle,
                borderStyle: RoughDrawingStyle(
                  width: theme.strokeWidth,
                  color: theme.borderColor,
                ),
              ),
              // The ink padding inside each item's hand-drawn box.
              padding: kWiredInkPadding,
              child: item.child,
            ),
          );
        }).toList(),
      ),
    );
  }
}
