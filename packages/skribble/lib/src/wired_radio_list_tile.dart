import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_list_tile.dart';
import 'wired_radio.dart';

/// A list tile with a hand-drawn radio button.
///
/// Combines [WiredListTile] with [WiredRadio] for a labeled radio button.
/// The combined widget is wrapped in [Semantics] for accessibility.
class WiredRadioListTile<T> extends HookWidget {
  final T value;
  final T? groupValue;
  final bool Function(T?)? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final bool showDivider;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

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
    return WiredListTile(
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
