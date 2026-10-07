import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'generated/skribble_glyphs.g.dart';
import 'wired_base.dart';
import 'wired_icon.dart';
import 'wired_theme.dart';

/// A step in [WiredStepper].
class WiredStep {
  final Widget title;
  final Widget? subtitle;
  final Widget content;

  const WiredStep({required this.title, this.subtitle, required this.content});
}

/// A stepper with hand-drawn connected circles and lines.
///
/// The stepper is wrapped in [Semantics] for accessibility, providing
/// screen readers with the current step information.
class WiredStepper extends HookWidget {
  final List<WiredStep> steps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  /// <!-- {=dartSemanticLabelOptional|trim|linePrefix:"  /// "} -->
  /// Optional semantic label for accessibility.
  /// <!-- {/dartSemanticLabelOptional} -->
  final String? semanticLabel;

  const WiredStepper({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.onStepTapped,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    return Semantics(
      label:
          semanticLabel ??
          'Stepper, step ${currentStep + 1} of ${steps.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _buildStep(i, steps[i], theme, MediaQuery.textScalerOf(context)),
            if (i < steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SizedBox(
                  width: 2,
                  height: 24,
                  child: WiredCanvas(
                    painter: WiredLineBase(
                      strokeWidth: theme.strokeWidth,
                      x1: 0,
                      y1: 0,
                      x2: 0,
                      y2: 24,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.noFiller,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep(
    int index,
    WiredStep step,
    WiredThemeData theme,
    TextScaler textScaler,
  ) {
    final isActive = index == currentStep;
    final isCompleted = index < currentStep;

    return GestureDetector(
      onTap: () => onStepTapped?.call(index),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            // The circle keeps the ink's breathing room as text grows.
            dimension: math.max(
              36,
              textScaler.scale(14) + 22,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                WiredCanvas(
                  painter: WiredCircleBase(
                    strokeWidth: theme.strokeWidth,
                    diameterRatio: 0.85,
                    fillColor: theme.markerColor,
                    borderColor: theme.borderColor,
                  ),
                  fillerType: isCompleted || isActive
                      ? RoughFilter.solidFiller
                      : RoughFilter.noFiller,
                ),
                if (isCompleted)
                  WiredSvgIcon(
                    data: SkribbleGlyphs.check,
                    size: 16,
                    color: theme.textColor,
                    weight: 500,
                  )
                else
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: theme.textColor,
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
                DefaultTextStyle.merge(
                  style: TextStyle(
                    color: isActive ? theme.textColor : theme.disabledTextColor,
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: step.title,
                ),
                if (step.subtitle != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      color: theme.disabledTextColor,
                      fontSize: 12,
                    ),
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
