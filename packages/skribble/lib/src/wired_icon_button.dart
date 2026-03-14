import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// An icon button with a hand-drawn circle border.
class WiredIconButton extends HookWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const WiredIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48.0,
    this.iconColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label: semanticLabel,
      button: true,
      child: buildWiredElement(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              WiredCanvas(
                painter: WiredCircleBase(
                  diameterRatio: 0.85,
                  borderColor: theme.borderColor,
                ),
                fillerType: RoughFilter.noFiller,
              ),
              IconButton(
                icon: WiredIcon(
                  icon: icon,
                  color: iconColor ?? theme.textColor,
                  size: size * 0.5,
                  fillStyle: WiredIconFillStyle.solid,
                  strokeWidth: 1.4,
                ),
                onPressed: onPressed,
                iconSize: size * 0.5,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(maxWidth: size, maxHeight: size),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
