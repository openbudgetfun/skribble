import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_control_list_tile.dart';
import 'wired_switch.dart';

/// A list tile with a hand-drawn switch.
///
/// Combines `WiredListTile` with [WiredSwitch] for a labeled switch.
/// The combined widget is wrapped in [Semantics] for accessibility.
class WiredSwitchListTile extends HookWidget {
  /// Whether the switch is on.
  final bool value;

  /// Called with the new value when the switch or the tile is tapped.
  ///
  /// Null disables both the switch and the tile.
  final ValueChanged<bool>? onChanged;

  /// The primary content of the tile.
  final Widget? title;

  /// Additional content displayed below [title].
  final Widget? subtitle;

  /// Whether to draw the hand-drawn divider below the tile.
  final bool showDivider;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
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
    return WiredControlListTile(
      semanticLabel: semanticLabel,
      title: title,
      subtitle: subtitle,
      showDivider: showDivider,
      trailing: WiredSwitch(value: value, onChanged: onChanged),
      onTap: onChanged == null ? null : () => onChanged!(!value),
    );
  }
}
