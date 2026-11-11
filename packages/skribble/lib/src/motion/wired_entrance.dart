import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'wired_curves.dart';
import 'wired_draw.dart';
import 'wired_motion.dart';

/// Brings its child onto the page like a sticker pressed onto paper: it
/// springs up from slightly below, small and tilted, fades in, and its
/// Wired ink draws itself on with the pen.
///
/// Plays once when mounted, after [delay]. Give it a new key to replay. Use
/// [WiredEntrance.staggered] for items of a list, or [WiredCascade] for a
/// column or row of them.
///
/// ```dart
/// WiredEntrance(
///   child: WiredCard(color: theme.accentAt(0), child: Text('Hello!')),
/// )
/// ```
///
/// With motion off ([WiredMotion], `WiredThemeData.motionEnabled`, or the
/// platform's reduced-motion setting) the child appears at once, settled.
/// Layout, semantics, and hit testing never wait for the animation: the
/// child takes its full size from the first frame, and only its paint moves.
class WiredEntrance extends StatefulWidget {
  /// Creates an entrance that starts after [delay].
  const WiredEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 720),
    this.curve = WiredCurves.springy,
    this.offset = const Offset(0, 18),
    this.scale = 0.92,
    this.turns = -0.006,
    this.drawInk = true,
  });

  /// Creates the entrance of item [index] in a list: each item starts
  /// [stagger] after the one before, so the list sketches itself in from
  /// the top.
  ///
  /// Items past [maxStaggered] start together, so a long list never keeps
  /// its reader waiting.
  WiredEntrance.staggered({
    super.key,
    required int index,
    required this.child,
    Duration stagger = const Duration(milliseconds: 70),
    int maxStaggered = 10,
    this.duration = const Duration(milliseconds: 720),
    this.curve = WiredCurves.springy,
    this.offset = const Offset(0, 18),
    this.scale = 0.92,
    this.turns = -0.006,
    this.drawInk = true,
  }) : assert(index >= 0),
       delay = stagger * math.min(index, maxStaggered);

  /// The widget to bring in.
  final Widget child;

  /// How long to wait after mounting before starting.
  final Duration delay;

  /// How long the spring takes to settle, once started.
  final Duration duration;

  /// The motion's timing. The default spring overshoots a little; use
  /// [WiredCurves.snappy] for less or [WiredCurves.bouncy] for more.
  final Curve curve;

  /// Where the child starts, in logical pixels from where it lands. The
  /// x offset flips in right-to-left text.
  final Offset offset;

  /// The child's starting scale. One starts at full size.
  final double scale;

  /// The child's starting tilt, in full turns. Negative tilts it
  /// anticlockwise; zero keeps it level.
  final double turns;

  /// Whether the child's Wired outlines and hatching draw on with the pen
  /// as it arrives, as in [WiredDraw].
  final bool drawInk;

  @override
  State<WiredEntrance> createState() => _WiredEntranceState();
}

class _WiredEntranceState extends State<WiredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.delay + widget.duration,
  );
  late _EntranceAnimations _animations = _build();
  bool _started = false;

  _EntranceAnimations _build() {
    final total = (widget.delay + widget.duration).inMicroseconds;
    final start = total <= 0 ? 0.0 : widget.delay.inMicroseconds / total;
    Animation<double> over(double from, double to, Curve curve) =>
        _controller.drive(
          CurveTween(
            curve: Interval(
              start + (1 - start) * from,
              start + (1 - start) * to,
              curve: curve,
            ),
          ),
        );
    return _EntranceAnimations(
      motion: over(0, 1, widget.curve),
      opacity: over(0, 0.35, Curves.easeOut),
      ink: over(0.05, 0.8, WiredCurves.pen),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!WiredMotion.enabledOf(context)) {
      _controller.value = 1;
      _started = true;
    } else if (!_started) {
      _started = true;
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(WiredEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delay != widget.delay ||
        oldWidget.duration != widget.duration ||
        oldWidget.curve != widget.curve) {
      _controller.duration = widget.delay + widget.duration;
      _animations = _build();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    Widget child = widget.child;
    if (widget.drawInk) {
      child = WiredDrawTransition(progress: _animations.ink, child: child);
    }
    return FadeTransition(
      opacity: _animations.opacity,
      child: _EntranceTransform(
        motion: _animations.motion,
        offset: rtl
            ? Offset(-widget.offset.dx, widget.offset.dy)
            : widget.offset,
        scale: widget.scale,
        turns: rtl ? -widget.turns : widget.turns,
        child: child,
      ),
    );
  }
}

class _EntranceAnimations {
  const _EntranceAnimations({
    required this.motion,
    required this.opacity,
    required this.ink,
  });

  final Animation<double> motion;
  final Animation<double> opacity;
  final Animation<double> ink;
}

/// Paints [child] moved from its start pose towards its resting place by
/// the motion animation, without rebuilding it.
class _EntranceTransform extends AnimatedWidget {
  const _EntranceTransform({
    required Animation<double> motion,
    required this.offset,
    required this.scale,
    required this.turns,
    required this.child,
  }) : super(listenable: motion);

  final Offset offset;
  final double scale;
  final double turns;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    if (t == 1) return child;
    final away = 1 - t;
    final matrix = Matrix4.translationValues(
      offset.dx * away,
      offset.dy * away,
      0,
    );
    final angle = turns * away * 2 * math.pi;
    if (angle != 0) matrix.rotateZ(angle);
    final s = 1 - (1 - scale) * away;
    matrix.scaleByDouble(s, s, 1, 1);
    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// A column or row whose children sketch themselves in one after another,
/// each with a [WiredEntrance].
///
/// ```dart
/// WiredCascade(
///   spacing: 12,
///   children: [
///     for (final (i, plant) in plants.indexed)
///       WiredCard(color: theme.accentAt(i), child: Text(plant.name)),
///   ],
/// )
/// ```
///
/// For a lazily built list, wrap each item in [WiredEntrance.staggered]
/// instead.
class WiredCascade extends StatelessWidget {
  /// Lays [children] out along [direction] and brings them in [stagger]
  /// apart.
  const WiredCascade({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.spacing = 0,
    this.stagger = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 720),
    this.curve = WiredCurves.springy,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment,
  });

  /// The widgets to lay out and bring in, in order.
  final List<Widget> children;

  /// Whether the children run down a column or along a row.
  final Axis direction;

  /// Space between neighbouring children, in logical pixels.
  final double spacing;

  /// The time between one child starting and the next.
  final Duration stagger;

  /// How long each child's spring takes to settle.
  final Duration duration;

  /// Each child's timing.
  final Curve curve;

  /// How the children sit along [direction].
  final MainAxisAlignment mainAxisAlignment;

  /// Whether the flex fills [direction] or wraps its children.
  final MainAxisSize mainAxisSize;

  /// How the children sit across [direction]. Null stretches the children
  /// of a column across its width and centres the children of a row.
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      spacing: spacing,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment:
          crossAxisAlignment ??
          (direction == Axis.vertical
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.center),
      children: [
        for (final (index, child) in children.indexed)
          WiredEntrance.staggered(
            index: index,
            stagger: stagger,
            duration: duration,
            curve: curve,
            child: child,
          ),
      ],
    );
  }
}
