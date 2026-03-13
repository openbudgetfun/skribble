import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_theme.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A floating action button with a hand-drawn circle.
class WiredFloatingActionButton extends HookWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;

  const WiredFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return buildWiredElement(
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              WiredCanvas(
                painter: WiredCircleBase(
                  diameterRatio: 0.9,
                  fillColor: theme.borderColor,
                ),
                fillerType: RoughFilter.hachureFiller,
                fillerConfig: FillerConfig.build(hachureGap: 2.0),
              ),
              Icon(
                icon,
                color: iconColor ?? theme.fillColor,
                size: size * 0.43,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
