import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// A spring as a [Curve]: it rushes towards the end, overshoots by an amount
/// set by [bounce], and settles exactly at one when the animation ends.
///
/// This is the step response of a damped spring whose stiffness is chosen so
/// it has settled to within a thousandth when `t` reaches one, so the same
/// spring feels right at any duration. Values overshoot one in between, so
/// use it for position, scale, and rotation, and clamp it, or pick another
/// curve, for opacity.
///
/// ```dart
/// controller.drive(CurveTween(curve: const WiredSpringCurve(bounce: 0.4)));
/// ```
class WiredSpringCurve extends Curve {
  /// Creates a spring. A [bounce] of zero is critically damped: it arrives
  /// without overshooting. Higher values overshoot more: 0.15 by about 1%,
  /// 0.35 by about 7%, and 0.55 by about 20%.
  const WiredSpringCurve({this.bounce = 0.35})
    : assert(bounce >= 0 && bounce < 1, 'bounce must be in [0, 1)');

  /// How springy the curve is, from zero (no overshoot) up to, but not
  /// including, one.
  final double bounce;

  /// ln(1000): the envelope decays to a thousandth by `t == 1`.
  static const double _settle = 6.907755278982137;

  @override
  double transformInternal(double t) {
    final zeta = 1 - bounce;
    final omega = _settle / zeta;
    if (bounce == 0) return 1 - math.exp(-omega * t) * (1 + omega * t);
    final damped = omega * math.sqrt(1 - zeta * zeta);
    final envelope = math.exp(-zeta * omega * t);
    return 1 -
        envelope *
            (math.cos(damped * t) +
                zeta * omega / damped * math.sin(damped * t));
  }

  @override
  String toString() => 'WiredSpringCurve(bounce: $bounce)';
}

/// skribble's motion curves: a pen stroke and three springs.
///
/// Use them with any Flutter animation: `CurveTween(curve: WiredCurves.pen)`,
/// `AnimatedContainer(curve: WiredCurves.springy)`, or the `curve` of a
/// `WiredDraw` or `WiredEntrance`.
abstract final class WiredCurves {
  /// A hand drawing a line: a quick start, a long, confident glide, and a
  /// soft landing. The default for ink that draws itself on.
  static const Curve pen = Cubic(0.45, 0.05, 0.2, 1);

  /// A firm spring that barely overshoots, for small controls and toggles.
  static const Curve snappy = WiredSpringCurve(bounce: 0.15);

  /// A lively spring with a visible overshoot: the default for entrances.
  static const Curve springy = WiredSpringCurve();

  /// A playful spring that bounces past its target, for celebrations and
  /// stickers landing on the page.
  static const Curve bouncy = WiredSpringCurve(bounce: 0.55);
}
