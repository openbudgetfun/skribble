import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// An elevated button with hand-drawn fill and slight offset shadow.
class WiredElevatedButton extends HookWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const WiredElevatedButton({super.key, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: Stack(
        children: [
          // Shadow offset
          Positioned(
            left: 2,
            top: 2,
            right: -2,
            bottom: -2,
            child: Container(
              decoration: RoughBoxDecoration(
                shape: RoughBoxShape.rectangle,
                borderStyle: RoughDrawingStyle(width: 0.5, color: borderColor),
                fillStyle: RoughDrawingStyle(color: borderColor),
                filler: HachureFiller(FillerConfig.build(hachureGap: 2)),
              ),
            ),
          ),
          Container(
            height: 42.0,
            decoration: RoughBoxDecoration(
              shape: RoughBoxShape.rectangle,
              borderStyle: RoughDrawingStyle(width: 1, color: borderColor),
              fillStyle: RoughDrawingStyle(color: filledColor),
              filler: HachureFiller(FillerConfig.build(hachureGap: 3)),
            ),
            child: SizedBox(
              height: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(foregroundColor: textColor),
                onPressed: onPressed,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
