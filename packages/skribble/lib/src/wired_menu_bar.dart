import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
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
                painter: WiredRectangleBase(
                  fillColor: theme.fillColor,
                  borderColor: theme.borderColor,
                ),
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

/// A menu item showing a hand-drawn checkbox as its leading icon.
///
/// Mirrors Material's `CheckboxMenuButton`: the item toggles [value] when
/// activated. By default the menu stays open after activation
/// ([closeOnActivate] defaults to `false`) so users can flip several
/// options in a row.
///
/// ```dart
/// WiredCheckboxMenuButton(
///   value: starred,
///   onChanged: (v) => setState(() => starred = v ?? false),
///   child: const Text('Starred'),
/// )
/// ```
class WiredCheckboxMenuButton extends HookWidget {
  /// Current checked state. `null` is the indeterminate (tristate) state.
  final bool? value;

  /// Whether `null` values are allowed. Defaults to `false`.
  final bool tristate;

  /// Called when the item is activated with the next checked state.
  final ValueChanged<bool?>? onChanged;

  /// Whether tapping the item closes the containing menu.
  final bool closeOnActivate;

  /// The item label.
  final Widget child;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredCheckboxMenuButton({
    super.key,
    required this.value,
    required this.child,
    this.tristate = false,
    this.onChanged,
    this.closeOnActivate = false,
    this.semanticLabel,
  });

  /// Computes the next checked state following Material's tristate cycle.
  bool? get _nextValue {
    switch (value) {
      case null:
        return true;
      case true:
        return tristate ? null : false;
      case false:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return MenuItemButton(
      onPressed: onChanged == null ? null : () => onChanged!(_nextValue),
      leadingIcon: _WiredMenuCheckboxIcon(
        tristate: tristate,
        value: value,
        semanticLabel: semanticLabel,
      ),
      closeOnActivate: closeOnActivate,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(theme.textColor),
      ),
      child: child,
    );
  }
}

/// A menu item showing a hand-drawn radio button as its leading icon.
///
/// Mirrors Material's `RadioMenuButton`: the item selects [value] within
/// [groupValue] when activated, and the menu closes after activation so
/// selection feels immediate (set [closeOnActivate] to `false` to keep
/// the menu open for reviewing a set of options).
///
/// ```dart
/// WiredRadioMenuButton<String>(
///   value: 'light',
///   groupValue: theme,
///   onChanged: (v) => setState(() => theme = v),
///   closeOnActivate: true,
///   child: const Text('Light'),
/// )
/// ```
class WiredRadioMenuButton<T> extends HookWidget {
  /// Value this item represents.
  final T value;

  /// Currently selected value of the radio group.
  final T? groupValue;

  /// Called with [value] when the item is activated, or with `null` when
  /// [toggleable] is set and the item was already selected.
  final ValueChanged<T?>? onChanged;

  /// Whether an already-selected item can be deselected (activated with
  /// `null`). Defaults to `false`.
  final bool toggleable;

  /// Whether tapping the item closes the containing menu.
  final bool closeOnActivate;

  /// The item label.
  final Widget child;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredRadioMenuButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.child,
    this.onChanged,
    this.toggleable = false,
    this.closeOnActivate = true,
    this.semanticLabel,
  });

  /// Whether the radio in this item is currently selected.
  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return MenuItemButton(
      onPressed: onChanged == null
          ? null
          : () {
              final wasSelected = toggleable && _selected;
              onChanged!(wasSelected ? null : value);
            },
      leadingIcon: _WiredMenuRadioIcon<T>(
        value: value,
        groupValue: groupValue,
        semanticLabel: semanticLabel,
      ),
      closeOnActivate: closeOnActivate,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(theme.textColor),
      ),
      child: child,
    );
  }
}

/// Controlled hand-drawn checkbox icon for [WiredCheckboxMenuButton].
///
/// Reuses the visual language of `WiredCheckbox` — a rough rectangle
/// with a transparent scaled Material checkbox inside — but is fully
/// controlled by [value] (no internal state) so the menu item can drive it.
class _WiredMenuCheckboxIcon extends HookWidget {
  const _WiredMenuCheckboxIcon({
    required this.value,
    required this.tristate,
    this.semanticLabel,
  });

  final bool? value;
  final bool tristate;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel,
      checked: value ?? false,
      child: buildWiredElement(
        child: Container(
          padding: EdgeInsets.zero,
          height: 20.0,
          width: 27.0,
          decoration: RoughBoxDecoration(
            shape: RoughBoxShape.rectangle,
            borderStyle: RoughDrawingStyle(
              width: 1,
              color: theme.borderColor,
            ),
          ),
          child: SizedBox(
            height: double.infinity,
            child: Transform.scale(
              scale: 1.1,
              child: Checkbox(
                fillColor: WidgetStateProperty.all(Colors.transparent),
                checkColor: theme.borderColor,
                tristate: tristate,
                value: value,
                onChanged: null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Controlled hand-drawn radio icon for [WiredRadioMenuButton].
///
/// Reuses the visual language of `WiredRadio` — a rough circle with a
/// hachure-filled selected state — but is fully controlled by
/// [groupValue]/[value] (no internal state or gestures).
class _WiredMenuRadioIcon<T> extends HookWidget {
  const _WiredMenuRadioIcon({
    required this.value,
    required this.groupValue,
    this.semanticLabel,
  });

  final T value;
  final T? groupValue;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isSelected = value == groupValue;
    return Semantics(
      label: semanticLabel,
      checked: isSelected,
      child: buildWiredElement(
        child: SizedBox(
          height: 24,
          width: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              WiredCanvas(
                painter: WiredCircleBase(
                  diameterRatio: 0.9,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
              if (isSelected)
                SizedBox(
                  height: 12,
                  width: 12,
                  child: WiredCanvas(
                    painter: WiredCircleBase(
                      diameterRatio: 0.85,
                      fillColor: theme.textColor,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.hachureFiller,
                    fillerConfig: FillerConfig.build(hachureGap: 1.0),
                  ),
                ),
            ],
          ),
        ),
      ),
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
              painter: WiredRectangleBase(
                fillColor: theme.fillColor,
                borderColor: theme.borderColor,
              ),
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
