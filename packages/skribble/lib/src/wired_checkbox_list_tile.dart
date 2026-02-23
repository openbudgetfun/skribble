import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_checkbox.dart';
import 'wired_list_tile.dart';

/// A list tile with a hand-drawn checkbox.
class WiredCheckboxListTile extends HookWidget {
  final bool? value;
  final void Function(bool?) onChanged;
  final Widget? title;
  final Widget? subtitle;
  final bool showDivider;

  const WiredCheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return WiredListTile(
      title: title,
      subtitle: subtitle,
      showDivider: showDivider,
      trailing: WiredCheckbox(value: value, onChanged: onChanged),
      onTap: () => onChanged(!(value ?? false)),
    );
  }
}
