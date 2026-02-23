import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_list_tile.dart';
import 'wired_switch.dart';

/// A list tile with a hand-drawn switch.
class WiredSwitchListTile extends HookWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final bool showDivider;

  const WiredSwitchListTile({
    super.key,
    required this.value,
    this.onChanged,
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
      trailing: WiredSwitch(value: value, onChanged: onChanged),
      onTap: () => onChanged?.call(!value),
    );
  }
}
