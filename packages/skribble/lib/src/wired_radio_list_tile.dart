import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'wired_list_tile.dart';
import 'wired_radio.dart';

/// A list tile with a hand-drawn radio button.
class WiredRadioListTile<T> extends HookWidget {
  final T value;
  final T? groupValue;
  final bool Function(T?)? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final bool showDivider;

  const WiredRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
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
