import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A step in [WiredStepper].
class WiredStep {
  final Widget title;
  final Widget? subtitle;
  final Widget content;

  const WiredStep({required this.title, this.subtitle, required this.content});
}

/// A stepper with hand-drawn connected circles and lines.
class WiredStepper extends HookWidget {
  final List<WiredStep> steps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  const WiredStepper({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildStep(i, steps[i]),
          if (i < steps.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SizedBox(
                width: 2,
                height: 24,
                child: WiredCanvas(
                  painter: WiredLineBase(x1: 0, y1: 0, x2: 0, y2: 24),
                  fillerType: RoughFilter.noFiller,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildStep(int index, WiredStep step) {
    final isActive = index == currentStep;
    final isCompleted = index < currentStep;

    return GestureDetector(
      onTap: () => onStepTapped?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                WiredCanvas(
                  painter: WiredCircleBase(
                    diameterRatio: 0.85,
                    fillColor: isCompleted || isActive
                        ? borderColor
                        : filledColor,
                  ),
                  fillerType: isCompleted || isActive
                      ? RoughFilter.hachureFiller
                      : RoughFilter.noFiller,
                  fillerConfig: FillerConfig.build(hachureGap: 2.0),
                ),
                if (isCompleted)
                  Icon(Icons.check, size: 16, color: filledColor)
                else
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? filledColor : textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    color: isActive ? textColor : disabledTextColor,
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: step.title,
                ),
                if (step.subtitle != null)
                  DefaultTextStyle(
                    style: TextStyle(color: disabledTextColor, fontSize: 12),
                    child: step.subtitle!,
                  ),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: step.content,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
