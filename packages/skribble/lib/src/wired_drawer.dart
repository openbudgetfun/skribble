import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';

/// A drawer with a hand-drawn border on the right edge.
class WiredDrawer extends HookWidget {
  final Widget child;
  final double width;

  const WiredDrawer({super.key, required this.child, this.width = 304.0});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: width,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 2,
              child: WiredCanvas(
                painter: WiredLineBase(
                  x1: 0,
                  y1: 0,
                  x2: 0,
                  y2: double.infinity,
                  strokeWidth: 2,
                ),
                fillerType: RoughFilter.noFiller,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
