import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_checkbox.dart';
import 'wired_list_tile.dart';

/// A list tile with a hand-drawn checkbox.
///
/// Combines [WiredListTile] with [WiredCheckbox] for a labeled checkbox.
/// The combined widget is wrapped in [Semantics] for accessibility.
class WiredCheckboxListTile extends HookWidget {
  final bool? value;
  final void Function(bool?) onChanged;
  final Widget? title;
  final Widget? subtitle;
  final bool showDivider;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredCheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.showDivider = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return WiredListTile(
      semanticLabel: semanticLabel,
      title: title,
      subtitle: subtitle,
      showDivider: showDivider,
      trailing: WiredCheckbox(value: value, onChanged: onChanged),
      onTap: () => onChanged(!(value ?? false)),
    );
  }
}
