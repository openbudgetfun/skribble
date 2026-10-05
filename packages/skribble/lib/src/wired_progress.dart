import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'motion/wired_motion.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

/// A hand-drawn linear progress bar, corresponding to Flutter's
/// `LinearProgressIndicator`.
///
/// Give [value] from 0 to 1 to show how far along something is; the marker
/// fill glides to each new value. Leave it null while the amount is unknown,
/// and a stretch of marker sweeps along the track instead.
///
/// ```dart
/// WiredProgress(value: uploaded / total)
/// const WiredProgress() // indeterminate
/// ```
///
/// The glide is decorative and settles immediately when [WiredMotion] or the
/// platform turns motion off. The indeterminate sweep tells people something
/// is happening, so like Flutter's own indicators it keeps moving.
///
/// See also:
///  * `WiredCircularProgress`, for a circular variant.
class WiredProgress extends HookWidget {
  /// Creates a progress bar showing [value], or an indeterminate one.
  const WiredProgress({
    super.key,
    this.value,
    this.height = 20,
    this.semanticLabel,
  });

  /// How far along, from 0 to 1, or null when unknown.
  final double? value;

  /// The height of the track in logical pixels.
  final double height;

  /// Accessible description, such as "Uploading photos".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final motion = WiredMotion.enabledOf(context);
    final sweep = useAnimationController(
      duration: const Duration(milliseconds: 1600),
    );
    final indeterminate = value == null;
    useEffect(() {
      if (indeterminate) {
        sweep.repeat();
      } else {
        sweep.stop();
      }
      return null;
    }, [indeterminate]);

    final track = WiredCanvas(
      painter: WiredRectangleBase(
        strokeWidth: theme.strokeWidth,
        fillColor: theme.fillColor,
        borderColor: theme.borderColor,
      ),
      fillerType: RoughFilter.noFiller,
    );
    final marker = WiredCanvas(
      painter: WiredRectangleBase(
        strokeWidth: theme.strokeWidth,
        fillColor: theme.markerColor,
        borderColor: theme.markerColor,
      ),
      fillerType: RoughFilter.solidFiller,
    );

    return Semantics(
      label: semanticLabel,
      value: indeterminate ? null : '${(value!.clamp(0, 1) * 100).round()}%',
      child: buildWiredElement(
        child: SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final rtl = Directionality.of(context) == TextDirection.rtl;
              Widget fill(double start, double fraction) => Positioned(
                left: rtl ? null : width * start,
                right: rtl ? width * start : null,
                top: 0,
                bottom: 0,
                width: width * fraction,
                child: marker,
              );
              return ClipRect(
                child: Stack(
                  children: [
                    if (indeterminate)
                      AnimatedBuilder(
                        animation: sweep,
                        builder: (context, _) {
                          // A third of the track sweeps in from the start and
                          // out past the end, easing at both.
                          final t = Curves.easeInOut.transform(sweep.value);
                          return Stack(
                            children: [fill(t * 1.4 - .4, .4)],
                          );
                        },
                      )
                    else
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: value!.clamp(0, 1).toDouble()),
                        duration: motion
                            ? const Duration(milliseconds: 320)
                            : Duration.zero,
                        curve: Curves.easeOutCubic,
                        builder: (context, fraction, _) => Stack(
                          children: [fill(0, fraction)],
                        ),
                      ),
                    Positioned.fill(child: track),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
