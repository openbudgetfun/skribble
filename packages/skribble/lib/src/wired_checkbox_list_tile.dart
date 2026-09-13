import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_checkbox.dart';
import 'wired_control_list_tile.dart';

/// A list tile with a hand-drawn checkbox.
///
/// Combines `WiredListTile` with [WiredCheckbox] for a labeled checkbox.
/// The combined widget is wrapped in [Semantics] for accessibility.
///
/// Passing `null` for [onChanged] disables both the checkbox and the tile's tap
/// action, matching Material's `CheckboxListTile.onChanged == null` convention.
class WiredCheckboxListTile extends HookWidget {
  /// Whether the checkbox is checked. A `null` value is treated as unchecked.
  final bool? value;

  /// Called with the new value when the checkbox or the tile is tapped.
  ///
  /// Null disables the checkbox and the tile.
  final ValueChanged<bool?>? onChanged;

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

  const WiredCheckboxListTile({
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
      trailing: WiredCheckbox(value: value, onChanged: onChanged),
      onTap: onChanged == null ? null : () => onChanged!(!(value ?? false)),
    );
  }
}
