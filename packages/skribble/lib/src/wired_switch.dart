import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_theme.dart';
import 'wired_thumb_animation.dart';

/// A switch widget with a hand-drawn appearance, mirroring Flutter's Switch API.
class WiredSwitch extends HookWidget {
  /// Whether the switch is on.
  final bool value;

  /// Called with the new value when the switch is toggled. Null disables the
  /// switch.
  final ValueChanged<bool>? onChanged;

  /// Track fill color while [value] is true. Defaults to the theme's marker
  /// color.
  final Color? activeColor;

  /// Track fill color while [value] is false. Defaults to the theme's fill
  /// color. The off track is drawn as an outline with no fill, so this
  /// currently has no visible effect.
  final Color? inactiveColor;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  /// Creates a hand-drawn switch, 60 by 24 logical pixels.
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

    final effectiveActiveColor = activeColor ?? theme.markerColor;
    final effectiveInactiveColor = inactiveColor ?? theme.fillColor;
    return Semantics(
      container: true,
      label: semanticLabel,
      toggled: value,
      enabled: onChanged != null,
      child: WiredActivatable(
        enabled: onChanged != null,
        onActivate: onChanged == null ? null : () => onChanged!(!value),
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
                      ? RoughFilter.solidFiller
                      : RoughFilter.noFiller,
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
