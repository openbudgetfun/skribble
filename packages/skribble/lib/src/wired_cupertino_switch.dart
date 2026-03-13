import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn switch corresponding to Flutter's [CupertinoSwitch].
///
/// Provides the same API as [CupertinoSwitch] with a sketchy hand-drawn
/// track and thumb using rough rounded rectangles and circles.
class WiredCupertinoSwitch extends HookWidget {
  /// Whether this switch is on or off.
  final bool value;

  /// Called when the switch is toggled.
  final ValueChanged<bool>? onChanged;

  /// The color used when the switch is on.
  final Color? activeTrackColor;

  /// The color used when the switch is off.
  final Color? inactiveTrackColor;

  /// The color of the thumb.
  final Color? thumbColor;

  /// Whether to apply Cupertino haptic feedback on toggle.
  final bool applyTheme;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  static const double _trackWidth = 52.0;
  static const double _trackHeight = 32.0;
  static const double _thumbSize = 28.0;

  const WiredCupertinoSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.applyTheme = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
      initialValue: value ? 1.0 : 0.0,
    );
    final animation = useAnimation(
      Tween<double>(
        begin: 2,
        end: _trackWidth - _thumbSize - 2,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
    );

    useEffect(() {
      unawaited(value ? controller.forward() : controller.reverse());
      return null;
    }, [value]);

    final enabled = onChanged != null;
    final effectiveActiveColor =
        activeTrackColor ?? CupertinoColors.activeGreen;
    final effectiveInactiveColor =
        inactiveTrackColor ?? CupertinoColors.systemGrey4;
    final effectiveThumbColor = thumbColor ?? Colors.white;

    return Semantics(
      label: semanticLabel,
      toggled: value,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        child: buildWiredElement(
          child: AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              width: _trackWidth,
              height: _trackHeight,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Track
                  SizedBox(
                    width: _trackWidth,
                    height: _trackHeight,
                    child: WiredCanvas(
                      painter: WiredRoundedRectangleBase(
                        borderRadius: BorderRadius.circular(16),
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
                  // Thumb
                  Positioned(
                    left: animation,
                    child: SizedBox(
                      width: _thumbSize,
                      height: _thumbSize,
                      child: WiredCanvas(
                        painter: WiredCircleBase(
                          fillColor: effectiveThumbColor,
                          borderColor: theme.borderColor,
                        ),
                        fillerType: RoughFilter.hachureFiller,
                        fillerConfig: FillerConfig.build(hachureGap: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
