import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';
import 'wired_thumb_animation.dart';

/// A switch widget with a hand-drawn appearance, mirroring Flutter's Switch API.
class WiredSwitch extends HookWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  const WiredSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.semanticLabel,
  });

  static const double _trackWidth = 60.0;
  static const double _trackHeight = 24.0;
  static const double _thumbSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final animation = useWiredThumbOffset(
      context: context,
      value: value,
      begin: 0,
      end: _trackWidth - _thumbSize,
    );

    final effectiveActiveColor = activeColor ?? theme.borderColor;
    final effectiveInactiveColor = inactiveColor ?? theme.fillColor;
    return Semantics(
      container: true,
      label: semanticLabel,
      toggled: value,
      enabled: onChanged != null,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
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
                    strokeWidth: theme.strokeWidth,
                    borderRadius: BorderRadius.circular(12),
                    fillColor: value
                        ? effectiveActiveColor
                        : effectiveInactiveColor,
                    borderColor: theme.borderColor,
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
                      strokeWidth: theme.strokeWidth,
                      diameterRatio: 1,
                      fillColor: theme.fillColor,
                      borderColor: theme.borderColor,
                    ),
                    fillerType: RoughFilter.solidFiller,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
