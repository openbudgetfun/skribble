import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_control_list_tile.dart';
import 'wired_radio.dart';

/// A list tile with a hand-drawn radio button.
///
/// Combines `WiredListTile` with [WiredRadio] for a labeled radio button.
/// The combined widget is wrapped in [Semantics] for accessibility.
class WiredRadioListTile<T> extends HookWidget {
  /// The value this tile's radio represents.
  final T value;

  /// The currently selected value of the group. The radio is selected when
  /// this equals [value].
  final T? groupValue;

  /// Called with [value] when the tile or its radio is tapped. Null disables
  /// the radio. The returned bool is ignored.
  final bool Function(T?)? onChanged;

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

  /// Creates a list tile with a leading hand-drawn radio button.
  const WiredRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
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
      leading: SizedBox(
        width: 48,
        height: 48,
        child: WiredRadio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
      ),
      onTap: () => onChanged?.call(value),
    );
  }
}
