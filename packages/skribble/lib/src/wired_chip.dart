import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'wired_base.dart';

/// A chip with a hand-drawn rounded rectangle border.
class WiredChip extends HookWidget {
  final Widget label;
  final Widget? avatar;
  final VoidCallback? onDeleted;

  const WiredChip({
    super.key,
    required this.label,
    this.avatar,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: IntrinsicWidth(
        child: SizedBox(
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: WiredCanvas(
                  painter: WiredRoundedRectangleBase(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (avatar != null) ...[avatar!, const SizedBox(width: 8)],
                    DefaultTextStyle(
                      style: TextStyle(color: textColor, fontSize: 13),
                      child: label,
                    ),
                    if (onDeleted != null) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onDeleted,
                        child: Icon(Icons.close, size: 16, color: textColor),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
