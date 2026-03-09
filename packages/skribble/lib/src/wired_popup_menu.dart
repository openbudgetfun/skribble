import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A popup menu item for [WiredPopupMenuButton].
class WiredPopupMenuItem<T> {
  final T value;
  final Widget child;

  const WiredPopupMenuItem({required this.value, required this.child});
}

/// A popup menu button with hand-drawn menu items.
class WiredPopupMenuButton<T> extends HookWidget {
  final List<WiredPopupMenuItem<T>> items;
  final void Function(T)? onSelected;
  final Widget? icon;

  const WiredPopupMenuButton({
    super.key,
    required this.items,
    this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: PopupMenuButton<T>(
        icon: icon ?? Icon(Icons.more_vert, color: textColor),
        onSelected: onSelected,
        color: filledColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        itemBuilder: (context) => items.map((item) {
          return PopupMenuItem<T>(
            value: item.value,
            child: Container(
              decoration: RoughBoxDecoration(
                shape: RoughBoxShape.rectangle,
                borderStyle: RoughDrawingStyle(width: 0.5, color: borderColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: item.child,
            ),
          );
        }).toList(),
      ),
    );
  }
}
