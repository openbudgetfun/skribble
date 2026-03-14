import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A search bar with a hand-drawn rounded rectangle border.
class WiredSearchBar extends HookWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? leading;
  final Widget? trailing;

  const WiredSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                borderRadius: BorderRadius.circular(24),
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                leading ??
                    WiredIcon(
                      icon: Icons.search,
                      color: theme.disabledTextColor,
                      size: 20,
                      fillStyle: WiredIconFillStyle.solid,
                      strokeWidth: 1.2,
                    ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText ?? 'Search...',
                      hintStyle: TextStyle(color: theme.disabledTextColor),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(color: theme.textColor),
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
