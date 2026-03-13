import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn menu bar with sketchy borders.
///
/// Wraps Flutter's [MenuBar] to provide a hand-drawn aesthetic.
class WiredMenuBar extends HookWidget {
  /// The menu items to display (typically [WiredSubmenuButton] or
  /// [WiredMenuItemButton]).
  final List<Widget> children;

  /// Padding around the menu bar content.
  final EdgeInsets padding;

  const WiredMenuBar({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: SizedBox(
        height: 48,
        child: Stack(
          children: [
            Positioned.fill(
              child: WiredCanvas(
                painter: WiredRectangleBase(fillColor: theme.fillColor),
                fillerType: RoughFilter.noFiller,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: MenuBar(
                    style: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      elevation: WidgetStateProperty.all(0),
                      padding: WidgetStateProperty.all(padding),
                    ),
                    children: children,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A hand-drawn submenu button for use in [WiredMenuBar].
class WiredSubmenuButton extends HookWidget {
  final Widget child;
  final List<Widget> menuChildren;

  const WiredSubmenuButton({
    super.key,
    required this.child,
    required this.menuChildren,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return SubmenuButton(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(theme.textColor),
      ),
      menuChildren: menuChildren,
      child: child,
    );
  }
}

/// A hand-drawn menu item button for use inside [WiredSubmenuButton].
class WiredMenuItemButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Widget? leadingIcon;

  const WiredMenuItemButton({
    super.key,
    required this.child,
    this.onPressed,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return MenuItemButton(
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(theme.textColor),
      ),
      child: child,
    );
  }
}

/// A hand-drawn dropdown menu with sketchy borders.
///
/// Wraps Flutter's [DropdownMenu] with hand-drawn borders.
class WiredDropdownMenu<T> extends HookWidget {
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final T? initialSelection;
  final ValueChanged<T?>? onSelected;
  final String? hintText;
  final String? label;
  final double? width;

  const WiredDropdownMenu({
    super.key,
    required this.dropdownMenuEntries,
    this.initialSelection,
    this.onSelected,
    this.hintText,
    this.label,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: Stack(
        children: [
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRectangleBase(fillColor: theme.fillColor),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          DropdownMenu<T>(
            dropdownMenuEntries: dropdownMenuEntries,
            initialSelection: initialSelection,
            onSelected: onSelected,
            hintText: hintText,
            label: label != null ? Text(label!) : null,
            width: width,
            inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }
}
