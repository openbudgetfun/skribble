import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
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
    this.onChange,
    this.thumbRadius = 24.0,
    this.semanticLabel,
  });

  final bool value;
  final bool Function(bool)? onChange;
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
      // Keep the painted position in sync with the controlled value: the
      // widget may be rebuilt with a new value by its parent at any time.
      isSwitched.value = value;
      toggle();
      return null;
    }, [value]);

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      label: semanticLabel,
      toggled: value,
      enabled: onChange != null,
      child: buildWiredElement(
        child: GestureDetector(
          onTap: onChange == null
              ? null
              : () {
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
                // Mirror the thumb travel so "on" sits at the inline end.
                left: isRtl ? thumbRadius * 0.5 - animation : animation,
                top: -thumbRadius / 2,
                child: SizedBox(
                  height: thumbRadius * 2,
                  width: thumbRadius * 2,
                  child: WiredCanvas(
                    painter: WiredCircleBase(
                      strokeWidth: theme.strokeWidth,
                      diameterRatio: .7,
                      fillColor: theme.textColor,
                      borderColor: theme.borderColor,
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
                  painter: WiredRectangleBase(
                    strokeWidth: theme.strokeWidth,
                    fillColor: theme.fillColor,
                    borderColor: theme.borderColor,
                  ),
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
