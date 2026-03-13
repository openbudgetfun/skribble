import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_theme.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

class WiredToggle extends HookWidget {
  const WiredToggle({
    super.key,
    required this.value,
    this.onChange,
    this.thumbRadius = 24.0,
  });

  final bool value;
  final bool Function(bool)? onChange;
  final double thumbRadius;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isSwitched = useRef(value);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    final animation = useAnimation(
      Tween<double>(
        begin: -thumbRadius,
        end: thumbRadius * 1.5,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn)),
    );
    final toggle = useCallback(() {
      unawaited(isSwitched.value ? controller.forward() : controller.reverse());
    });

    useEffect(() {
      toggle();
      return null;
    }, []);

    return buildWiredElement(
      child: GestureDetector(
        onTap: () {
          final nextValue = !isSwitched.value;
          final result = onChange?.call(nextValue) ?? false;

          if (result) {
            isSwitched.value = nextValue;
            toggle();
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: animation,
              top: -thumbRadius / 2,
              child: SizedBox(
                height: thumbRadius * 2,
                width: thumbRadius * 2,
                child: WiredCanvas(
                  painter: WiredCircleBase(
                    diameterRatio: .7,
                    fillColor: theme.textColor,
                  ),
                  fillerType: RoughFilter.hachureFiller,
                  fillerConfig: FillerConfig.build(hachureGap: 1.0),
                ),
              ),
            ),
            SizedBox(
              width: thumbRadius * 2.5,
              height: thumbRadius,
              child: WiredCanvas(
                painter: WiredRectangleBase(),
                fillerType: RoughFilter.noFiller,
                fillerConfig: FillerConfig.build(fillWeight: 3.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
