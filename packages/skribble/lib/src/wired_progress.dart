import 'dart:math' as math;

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

  /// The height of the bar in logical pixels, including its ink.
  ///
  /// The pen's line and wobble sit inside this box, so a bar is never drawn
  /// shorter than its ink plus a visible band; smaller values are raised to
  /// that minimum.
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

    // The track's ink sits half an ink extent inside every edge, and the fill
    // is drawn the same way, so the fill is laid out against the track's
    // interior: its painted edges then land exactly on the value.
    final inkExtent = theme.inkExtent;
    final boxHeight = math.max(height, inkExtent + _minimumBand);

    return Semantics(
      label: semanticLabel,
      value: indeterminate ? null : '${(value!.clamp(0, 1) * 100).round()}%',
      child: buildWiredElement(
        child: SizedBox(
          height: boxHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final interior = math.max(0.0, constraints.maxWidth - inkExtent);
              final rtl = Directionality.of(context) == TextDirection.rtl;
              Widget fill(double start, double fraction) {
                if (fraction <= 0) return const SizedBox.shrink();
                return Positioned(
                  left: rtl ? null : interior * start,
                  right: rtl ? interior * start : null,
                  top: 0,
                  bottom: 0,
                  // The marker insets itself by the same ink, so its box is
                  // widened by one extent to paint exactly `fraction`.
                  width: interior * fraction + inkExtent,
                  child: marker,
                );
              }

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
                          return Stack(children: [fill(t * 1.4 - .4, .4)]);
                        },
                      )
                    else
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: value!.clamp(0, 1).toDouble()),
                        duration: motion
                            ? const Duration(milliseconds: 320)
                            : Duration.zero,
                        curve: Curves.easeOutCubic,
                        builder: (context, fraction, _) =>
                            Stack(children: [fill(0, fraction)]),
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

/// The thinnest band of fill a bar keeps visible inside its ink.
const double _minimumBand = 6;
