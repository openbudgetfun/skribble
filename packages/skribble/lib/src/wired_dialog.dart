import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_base.dart';

class WiredDialog extends HookWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const WiredDialog({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(5.0),
            child: WiredCanvas(
              painter: WiredRectangleBase(),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Padding(padding: padding ?? EdgeInsets.all(20.0), child: child),
        ],
      ),
    );
  }
}
