import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_list_tile.dart';
import 'wired_switch.dart';

/// A list tile with a hand-drawn switch.
///
/// Combines [WiredListTile] with [WiredSwitch] for a labeled switch.
/// The combined widget is wrapped in [Semantics] for accessibility.
class WiredSwitchListTile extends HookWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final bool showDivider;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  const WiredSwitchListTile({
    super.key,
    required this.value,
    this.onChanged,
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
      trailing: WiredSwitch(value: value, onChanged: onChanged),
      onTap: () => onChanged?.call(!value),
    );
  }
}
