import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_activatable.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A simple hand-drawn on/off toggle.
///
/// Draws a sketchy rounded rectangle track with a circle thumb that
/// animates between on and off positions. Uses `WiredRoundedRectangleBase`
/// for the track and `WiredCircleBase` for the thumb.
///
/// See also:
///  * `WiredSwitch`, which wraps Flutter's `Switch`.
///  * `WiredCupertinoSwitch`, for Cupertino styling.
class WiredToggle extends HookWidget {
  const WiredToggle({
    super.key,
    required this.value,
    this.onChanged,
    @Deprecated(
      'Use onChanged, which follows the framework convention of a '
      'void callback where null disables the toggle',
    )
    bool Function(bool)? onChange,
    this.thumbRadius = 24.0,
    this.semanticLabel,
    this.seed,
  }) : _legacyOnChange = onChange;

  /// Varies the hand behind this widget's ink. The same seed always draws
  /// the same wobble, so neighbouring shapes of the same size need different
  /// seeds to stop them reading as copies of each other. Null keeps the
  /// theme's seed.
  final int? seed;

  final bool value;

  /// Called when the thumb settles on a new side.
  ///
  /// Null disables the toggle. Return-style vetoes belong to the deprecated
  /// onChange parameter.
  final void Function(bool)? onChanged;

  /// Called when the thumb settles on a new side; returning false vetoes the
  /// change.
  @Deprecated(
    'Use onChanged, which follows the framework convention of a '
    'void callback where null disables the toggle',
  )
  bool Function(bool)? get onChange => _legacyOnChange;

  final bool Function(bool)? _legacyOnChange;
  final double thumbRadius;

  /// <!-- {=dartSemanticLabel|trim|linePrefix:"  /// "} -->
  /// Semantic label for accessibility.
  /// <!-- {/dartSemanticLabel} -->
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final isSwitched = useRef(value);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    // The thumb position animates inside an AnimatedBuilder around a
    // prebuilt child, so a tick repositions the thumb without rebuilding the
    // toggle or regenerating any rough geometry.
    final thumbTravel = useMemoized(
      () => Tween<double>(
        begin: -thumbRadius,
        end: thumbRadius * 1.5,
      ).chain(CurveTween(curve: Curves.easeIn)),
      [thumbRadius],
    );
    final toggle = useCallback(() {
      unawaited(isSwitched.value ? controller.forward() : controller.reverse());
    });

    useEffect(() {
      // Keep the painted position in sync with the controlled value: the
      // widget may be rebuilt with a new value by its parent at any time.
      isSwitched.value = value;
      toggle();
      return null;
    }, [value]);

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final enabled = onChanged != null || _legacyOnChange != null;
    final thumb = SizedBox(
      height: thumbRadius * 2,
      width: thumbRadius * 2,
      child: WiredCanvas(
        painter: WiredCircleBase(
          strokeWidth: theme.strokeWidth,
          diameterRatio: .7,
          fillColor: theme.textColor,
          borderColor: theme.borderColor,
        ),
        seed: seed,
        fillerType: RoughFilter.hachureFiller,
        fillerConfig: FillerConfig.build(hachureGap: 1.0),
      ),
    );

    return Semantics(
      label: semanticLabel,
      toggled: value,
      enabled: enabled,
      child: buildWiredElement(
        child: WiredActivatable(
          enabled: enabled,
          onActivate: enabled
              ? () {
                  final nextValue = !isSwitched.value;
                  bool accepted;
                  if (_legacyOnChange != null) {
                    accepted = _legacyOnChange(nextValue);
                  } else {
                    onChanged?.call(nextValue);
                    accepted = true;
                  }

                  if (accepted) {
                    isSwitched.value = nextValue;
                    toggle();
                  }
                }
              : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: controller,
                child: thumb,
                builder: (context, child) => Positioned(
                  // Mirror the thumb travel so "on" sits at the inline end.
                  left: isRtl
                      ? thumbRadius * 0.5 - thumbTravel.evaluate(controller)
                      : thumbTravel.evaluate(controller),
                  top: -thumbRadius / 2,
                  child: child!,
                ),
              ),
              SizedBox(
                width: thumbRadius * 2.5,
                height: thumbRadius,
                child: WiredCanvas(
                  painter: WiredRectangleBase(
                    strokeWidth: theme.strokeWidth,
                    fillColor: theme.fillColor,
                    borderColor: theme.borderColor,
                  ),
                  seed: seed,
                  fillerType: RoughFilter.noFiller,
                  fillerConfig: FillerConfig.build(fillWeight: 3.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
