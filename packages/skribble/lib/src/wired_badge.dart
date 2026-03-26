import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A badge overlay with a hand-drawn circle indicator.
class WiredBadge extends HookWidget {
  final Widget child;
  final String? label;
  final bool isVisible;
  final Color? backgroundColor;

  const WiredBadge({
    super.key,
    required this.child,
    this.label,
    this.isVisible = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (isVisible)
          Positioned(
            right: -6,
            top: -6,
            child: SizedBox(
              width: label == null
                  ? 16
                  : math.max(16.0, label!.length * 8.0 + 8.0),
              height: 16,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  WiredCanvas(
                    painter: WiredCircleBase(
                      fillColor: backgroundColor ?? theme.borderColor,
                      diameterRatio: 0.9,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.hachureFiller,
                    fillerConfig: FillerConfig.build(hachureGap: 1.0),
                  ),
                  if (label != null)
                    Text(
                      label!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
