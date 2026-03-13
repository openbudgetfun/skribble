import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A switch widget with a hand-drawn appearance, mirroring Flutter's Switch API.
class WiredSwitch extends HookWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const WiredSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  static const double _trackWidth = 60.0;
  static const double _trackHeight = 24.0;
  static const double _thumbSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
      initialValue: value ? 1.0 : 0.0,
    );
    final animation = useAnimation(
      Tween<double>(
        begin: 0,
        end: _trackWidth - _thumbSize,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
    );

    useEffect(() {
      unawaited(value ? controller.forward() : controller.reverse());
      return null;
    }, [value]);

    final effectiveActiveColor = activeColor ?? borderColor;
    final effectiveInactiveColor = inactiveColor ?? filledColor;

    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: SizedBox(
        width: _trackWidth,
        height: _thumbSize,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            SizedBox(
              width: _trackWidth,
              height: _trackHeight,
              child: WiredCanvas(
                painter: WiredRoundedRectangleBase(
                  borderRadius: BorderRadius.circular(12),
                  fillColor: value
                      ? effectiveActiveColor
                      : effectiveInactiveColor,
                ),
                fillerType: value
                    ? RoughFilter.hachureFiller
                    : RoughFilter.noFiller,
                fillerConfig: FillerConfig.build(hachureGap: 2.0),
              ),
            ),
            Positioned(
              left: animation,
              child: SizedBox(
                width: _thumbSize,
                height: _thumbSize,
                child: WiredCanvas(
                  painter: WiredCircleBase(
                    diameterRatio: 0.8,
                    fillColor: value ? filledColor : borderColor,
                  ),
                  fillerType: RoughFilter.hachureFiller,
                  fillerConfig: FillerConfig.build(hachureGap: 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
