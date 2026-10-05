import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart' show Alignment;
import 'package:flutter/widgets.dart' show Axis, Matrix4;

import 'package:skribble_emoji/src/emoji_drawing.dart';

/// Where a part is at one moment of a motion, relative to where it rests.
///
/// Distances are in art units, the 36-unit grid emoji are drawn on, so a
/// motion looks the same at every size.
@immutable
final class EmojiPose {
  /// Creates a pose. The defaults are the resting pose.
  const EmojiPose({
    this.dx = 0,
    this.dy = 0,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.opacity = 1,
  });

  /// The resting pose: no movement at all.
  static const EmojiPose rest = EmojiPose();

  /// Horizontal movement in art units; positive is right.
  final double dx;

  /// Vertical movement in art units; positive is down.
  final double dy;

  /// Rotation in radians; positive is clockwise.
  final double rotation;

  /// Horizontal scale around the pivot.
  final double scaleX;

  /// Vertical scale around the pivot.
  final double scaleY;

  /// How opaque the part is, from 0 (gone) to 1 (as drawn).
  final double opacity;

  /// Whether this pose moves nothing.
  bool get isRest => isStill && opacity == 1;

  /// Whether this pose leaves the part where it is, however faded.
  bool get isStill =>
      dx == 0 && dy == 0 && rotation == 0 && scaleX == 1 && scaleY == 1;

  /// Both poses at once: movements and rotations add, scales and opacities
  /// multiply.
  EmojiPose operator +(EmojiPose other) => EmojiPose(
    dx: dx + other.dx,
    dy: dy + other.dy,
    rotation: rotation + other.rotation,
    scaleX: scaleX * other.scaleX,
    scaleY: scaleY * other.scaleY,
    opacity: opacity * other.opacity,
  );

  /// The transform for this pose around [pivot], with [unit] logical pixels
  /// per art unit.
  Matrix4 toMatrix(Offset pivot, double unit) =>
      Matrix4.translationValues(pivot.dx + dx * unit, pivot.dy + dy * unit, 0)
        ..rotateZ(rotation)
        ..scaleByDouble(scaleX, scaleY, 1, 1)
        ..translateByDouble(-pivot.dx, -pivot.dy, 0, 1);

  @override
  bool operator ==(Object other) =>
      other is EmojiPose &&
      other.dx == dx &&
      other.dy == dy &&
      other.rotation == rotation &&
      other.scaleX == scaleX &&
      other.scaleY == scaleY &&
      other.opacity == opacity;

  @override
  int get hashCode => Object.hash(dx, dy, rotation, scaleX, scaleY, opacity);

  @override
  String toString() =>
      'EmojiPose(dx: $dx, dy: $dy, rotation: $rotation, '
      'scaleX: $scaleX, scaleY: $scaleY, opacity: $opacity)';
}

/// How a part moves through one loop of a motion.
///
/// [at] maps the loop's progress, from 0 up to 1, to a pose. Every built-in
/// move rests at 0 and returns to rest at 1, so loops join without a jump and
/// a stopped animation shows the drawing as it was drawn. Subclass to write
/// your own move.
abstract class EmojiMove {
  /// Allows subclasses to have const constructors.
  const EmojiMove();

  /// A heartbeat: two quick swells, then a rest.
  const factory EmojiMove.beat({double scale}) = _Beat;

  /// A blink near the end of the loop, for eyes.
  const factory EmojiMove.blink() = _Blink;

  /// A gentle rise and fall.
  const factory EmojiMove.bob({double height}) = _Bob;

  /// A hand wave: a few swings back and forth around the pivot.
  const factory EmojiMove.wave({double angle, int swings}) = _Wave;

  /// A slow lean from side to side, like a plant in a breeze.
  const factory EmojiMove.sway({double angle}) = _Sway;

  /// A quick shake along [axis], easing out, then a rest.
  const factory EmojiMove.shake({double distance, Axis axis, int times}) =
      _Shake;

  /// A flame's flicker: restless stretching and leaning.
  const factory EmojiMove.flicker({double amount}) = _Flicker;

  /// Whole turns around the pivot.
  const factory EmojiMove.spin({int turns}) = _Spin;

  /// A hop with a squash before take-off and on landing.
  const factory EmojiMove.hop({double height}) = _Hop;

  /// A slow, even swell and shrink, like breathing.
  const factory EmojiMove.breathe({double scale}) = _Breathe;

  /// A fall that fades away, then starts again: tears, drops, and sweat.
  const factory EmojiMove.drip({double distance}) = _Drip;

  /// A drift up and down with a slight tilt, like something weightless.
  const factory EmojiMove.float({double height}) = _Float;

  /// A burst outwards from the pivot that settles back: confetti and sparks.
  const factory EmojiMove.burst({double scale}) = _Burst;

  /// The pose at loop progress [t], from 0 up to 1.
  EmojiPose at(double t);

  /// This move, held at rest until [fraction] of the loop has passed and
  /// then played in the time that is left. Use it to stagger parts, such as
  /// a blink that follows a beat.
  EmojiMove delayed(double fraction) => _Delayed(this, fraction);
}

final class _Delayed extends EmojiMove {
  const _Delayed(this.move, this.fraction)
    : assert(fraction >= 0 && fraction < 1, 'fraction must be in [0, 1)');

  final EmojiMove move;
  final double fraction;

  @override
  EmojiPose at(double t) =>
      t < fraction ? move.at(0) : move.at((t - fraction) / (1 - fraction));
}

/// One part's move within a motion.
@immutable
final class EmojiTrack {
  /// Moves [part] with [move] around [pivot].
  ///
  /// A null [part] moves the whole emoji. [pivot] is a point in the part's
  /// bounds: `Alignment.bottomCenter` rotates a hand around its wrist.
  const EmojiTrack(this.part, this.move, {this.pivot = Alignment.center});

  /// The part to move, or null for the whole emoji.
  final String? part;

  /// How the part moves.
  final EmojiMove move;

  /// The point the part turns and scales around, within its bounds.
  final Alignment pivot;
}

/// A looping animation of an emoji's parts.
///
/// Tracks for parts a drawing does not have are skipped, so one motion can
/// serve every drawing in a family.
@immutable
final class EmojiMotion {
  /// Creates a motion from [tracks] that loops every [duration].
  const EmojiMotion(
    this.tracks, {
    this.duration = const Duration(milliseconds: 1600),
  });

  /// The parts and how each moves.
  final List<EmojiTrack> tracks;

  /// How long one loop takes.
  final Duration duration;

  /// Paints [drawing] at loop progress [t], from 0 up to 1.
  ///
  /// Each track turns and scales its part around its own pivot, and tracks
  /// on the same part compose in order.
  void paint(Canvas canvas, EmojiDrawing drawing, double t) {
    final unit = drawing.size / kEmojiArtSize;
    final square = Offset.zero & Size.square(drawing.size);
    final transforms = <String?, Matrix4>{};
    final opacities = <String?, double>{};
    for (final track in tracks) {
      final part = track.part;
      final bounds = part == null ? square : drawing.boundsOf(part);
      if (bounds == null) continue;
      final pose = track.move.at(t);
      if (!pose.isStill) {
        final matrix = pose.toMatrix(track.pivot.withinRect(bounds), unit);
        transforms[part] = transforms[part]?.multiplied(matrix) ?? matrix;
      }
      if (pose.opacity < 1) {
        opacities[part] = (opacities[part] ?? 1) * pose.opacity;
      }
    }
    final whole = transforms.remove(null);
    final wholeOpacity = opacities.remove(null);
    final pose = transforms.cast<String, Matrix4>();
    final opacity = opacities.cast<String, double>();
    if (whole == null && wholeOpacity == null) {
      drawing.paint(canvas, pose: pose, opacity: opacity);
      return;
    }
    if (wholeOpacity != null) {
      canvas.saveLayer(
        square.inflate(drawing.size / 2),
        Paint()..color = Color.fromRGBO(0, 0, 0, wholeOpacity),
      );
    } else {
      canvas.save();
    }
    if (whole != null) canvas.transform(whole.storage);
    drawing.paint(canvas, pose: pose, opacity: opacity);
    canvas.restore();
  }
}

/// A smooth 0 → 1 → 0 bump over [start]–[end] of the loop.
double _bump(double t, double start, double end) {
  if (t <= start || t >= end) return 0;
  return math.sin((t - start) / (end - start) * math.pi);
}

/// Fades a looping wave in and out so the loop starts and ends at rest.
double _envelope(double t) => math.sin(t * math.pi);

final class _Beat extends EmojiMove {
  const _Beat({this.scale = 1.14});

  final double scale;

  @override
  EmojiPose at(double t) {
    final swell = 1 + (scale - 1) * (_bump(t, 0, .16) + .7 * _bump(t, .2, .36));
    return EmojiPose(scaleX: swell, scaleY: swell);
  }
}

final class _Blink extends EmojiMove {
  const _Blink();

  @override
  EmojiPose at(double t) => EmojiPose(scaleY: 1 - .9 * _bump(t, .84, .94));
}

final class _Bob extends EmojiMove {
  const _Bob({this.height = 1.2});

  final double height;

  @override
  EmojiPose at(double t) => EmojiPose(dy: -height * _bump(t, 0, 1));
}

final class _Wave extends EmojiMove {
  const _Wave({this.angle = .35, this.swings = 2});

  final double angle;
  final int swings;

  @override
  EmojiPose at(double t) => EmojiPose(
    rotation: angle * math.sin(t * math.pi * 2 * swings) * _envelope(t),
  );
}

final class _Sway extends EmojiMove {
  const _Sway({this.angle = .12});

  final double angle;

  @override
  EmojiPose at(double t) =>
      EmojiPose(rotation: angle * math.sin(t * math.pi * 2));
}

final class _Shake extends EmojiMove {
  const _Shake({
    this.distance = .9,
    this.axis = Axis.horizontal,
    this.times = 4,
  });

  final double distance;
  final Axis axis;
  final int times;

  @override
  EmojiPose at(double t) {
    // Shake during the first half of the loop, easing out, then rest.
    if (t >= .5) return EmojiPose.rest;
    final offset = distance * math.sin(t * 2 * math.pi * times) * (1 - t * 2);
    return axis == Axis.horizontal
        ? EmojiPose(dx: offset)
        : EmojiPose(dy: offset);
  }
}

final class _Flicker extends EmojiMove {
  const _Flicker({this.amount = 1});

  final double amount;

  @override
  EmojiPose at(double t) {
    final a = t * math.pi * 2;
    // Several whole-loop waves at once feel restless but still join up.
    final stretch = math.sin(a * 3) * .6 + math.sin(a * 5) * .4;
    final lean = math.sin(a * 2) * .7 + math.sin(a * 7) * .3;
    return EmojiPose(
      scaleY: 1 + .09 * amount * stretch,
      scaleX: 1 - .05 * amount * stretch,
      rotation: .07 * amount * lean,
    );
  }
}

final class _Spin extends EmojiMove {
  const _Spin({this.turns = 1});

  final int turns;

  @override
  EmojiPose at(double t) {
    // Ease in and out so the spin settles where it started.
    final eased = t * t * (3 - 2 * t);
    return EmojiPose(rotation: eased * math.pi * 2 * turns);
  }
}

final class _Hop extends EmojiMove {
  const _Hop({this.height = 3});

  final double height;

  @override
  EmojiPose at(double t) {
    final squash = .12 * (_bump(t, 0, .14) + _bump(t, .56, .7));
    return EmojiPose(
      dy: -height * _bump(t, .12, .58),
      scaleX: 1 + squash,
      scaleY: 1 - squash,
    );
  }
}

final class _Breathe extends EmojiMove {
  const _Breathe({this.scale = 1.06});

  final double scale;

  @override
  EmojiPose at(double t) {
    final swell = 1 + (scale - 1) * _bump(t, 0, 1);
    return EmojiPose(scaleX: swell, scaleY: swell);
  }
}

final class _Drip extends EmojiMove {
  const _Drip({this.distance = 5});

  final double distance;

  @override
  EmojiPose at(double t) {
    // Rest for the first third, then fall faster and faster while fading
    // away, and reappear at rest when the loop starts again.
    if (t < .35) return EmojiPose.rest;
    final fall = (t - .35) / .65;
    return EmojiPose(
      dy: distance * fall * fall,
      scaleY: 1 + .15 * fall,
      opacity: 1 - fall,
    );
  }
}

final class _Float extends EmojiMove {
  const _Float({this.height = 1.5});

  final double height;

  @override
  EmojiPose at(double t) {
    final a = t * math.pi * 2;
    return EmojiPose(
      dy: -height * math.sin(a),
      rotation: .05 * math.sin(a * 2),
    );
  }
}

final class _Burst extends EmojiMove {
  const _Burst({this.scale = 1.25});

  final double scale;

  @override
  EmojiPose at(double t) {
    // Out fast, back slowly.
    final out = t < .2
        ? math.sin(t / .2 * math.pi / 2)
        : math.cos((t - .2) / .8 * math.pi / 2);
    final grow = 1 + (scale - 1) * out;
    return EmojiPose(scaleX: grow, scaleY: grow, rotation: .15 * out);
  }
}
