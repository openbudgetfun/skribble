import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'wired_base.dart';

/// An icon button with a hand-drawn circle border.
class WiredIconButton extends HookWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;

  const WiredIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            WiredCanvas(
              painter: WiredCircleBase(diameterRatio: 0.85),
              fillerType: RoughFilter.noFiller,
            ),
            IconButton(
              icon: Icon(icon, color: iconColor ?? textColor),
              onPressed: onPressed,
              iconSize: size * 0.5,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                maxWidth: size,
                maxHeight: size,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
