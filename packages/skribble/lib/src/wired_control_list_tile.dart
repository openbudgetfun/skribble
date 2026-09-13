import 'package:flutter/widgets.dart';

import 'wired_list_tile.dart';

/// Shared composition for the checkbox, switch, and radio list tiles.
///
/// Internal to the library and deliberately not exported from the package
/// barrel. The three public tiles differ only in the control they place
/// (leading or trailing) and the value they report through [onTap].
class WiredControlListTile extends StatelessWidget {
  /// Creates a list tile around a single control.
  const WiredControlListTile({
    super.key,
    required this.onTap,
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.showDivider = true,
    this.semanticLabel,
  });

  /// Called when the row is tapped.
  final VoidCallback onTap;

  /// Control shown before the title.
  final Widget? leading;

  /// Control shown after the title.
  final Widget? trailing;

  /// Primary line of the tile.
  final Widget? title;

  /// Secondary line of the tile.
  final Widget? subtitle;

  /// Whether to draw the hand-drawn divider under the row.
  final bool showDivider;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return WiredListTile(
      semanticLabel: semanticLabel,
      title: title,
      subtitle: subtitle,
      showDivider: showDivider,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
