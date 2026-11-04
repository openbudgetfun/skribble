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

  /// Called with the new value when the tile or its switch is tapped. Null
  /// disables the switch.
  final ValueChanged<bool>? onChanged;

  /// Primary content of the tile.
  final Widget? title;

  /// Secondary content below [title].
  final Widget? subtitle;

  /// <!-- {=dartTileShowDivider|trim|linePrefix:"  /// "} -->
  /// Whether a hand-drawn line is drawn below the tile. Defaults to true.
  /// <!-- {/dartTileShowDivider} -->
  final bool showDivider;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  /// Creates a list tile with a trailing hand-drawn switch.
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
      onTap: () => onChanged?.call(!value),
    );
  }
}
