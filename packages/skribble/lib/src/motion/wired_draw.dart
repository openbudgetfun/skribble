import 'package:flutter/widgets.dart';

import 'wired_motion.dart';

/// Draws descendant Wired outlines and hatch fills once when mounted.
///
/// Content and layout remain visible and interactive. Use a new key to replay,
/// or [WiredDrawTransition] for explicit control, reversal, and staggering.
/// Ordinary widgets remain static until wrapped in a draw transition.
class WiredDraw extends StatefulWidget {
  /// Creates a one-shot pen entrance using a standard Flutter ticker.
  const WiredDraw({
    super.key,
    this.duration = const Duration(milliseconds: 650),
    this.curve = Curves.easeInOutCubic,
    required this.child,
  }) : assert(duration >= Duration.zero);

  /// Time for the complete outline and patterned fill.
  final Duration duration;

  /// Timing applied to the measured pen distance.
  final Curve curve;

  /// Widgets whose ink should draw in.
  final Widget child;

  @override
  State<WiredDraw> createState() => _WiredDrawState();
}

class _WiredDrawState extends State<WiredDraw>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late Animation<double> _progress = _controller.drive(
    CurveTween(curve: widget.curve),
  );
  bool _started = false;

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
  void didUpdateWidget(WiredDraw oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    if (oldWidget.curve != widget.curve) {
      _progress = _controller.drive(CurveTween(curve: widget.curve));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WiredDrawTransition(
    progress: _progress,
    child: widget.child,
  );
}

/// Drives descendant ink directly from an ordinary Flutter animation.
///
/// Zero hides outlines and patterned fill, one completes them. Solid fills,
/// text, icons, semantics, and layout remain intact. A nested transition uses
/// its own progress. The caller owns the animation and its controller.
///
/// Ticks repaint ink without rebuilding children. Use `drive(CurveTween(...))`
/// for curves or `Interval` staggering, including with hooks-owned controllers.
class WiredDrawTransition extends InheritedWidget {
  /// Borrows [progress] without starting, stopping, or disposing it.
  const WiredDrawTransition({
    super.key,
    required this.progress,
    required super.child,
  });

  /// Pen progress, clamped by the renderer to the range zero through one.
  final Animation<double> progress;

  /// Resolves a paint signal for a custom canvas or rough decoration.
  ///
  /// Null means fully drawn. While [TickerMode] is muted this returns a frozen
  /// value and painters detach from the caller's animation until re-enabled.
  static Animation<double>? progressOf(BuildContext context) {
    if (!WiredMotion.enabledOf(context)) return null;
    final progress = context
        .dependOnInheritedWidgetOfExactType<WiredDrawTransition>()
        ?.progress;
    if (progress == null || TickerMode.of(context)) return progress;
    return AlwaysStoppedAnimation(progress.value);
  }

  @override
  bool updateShouldNotify(WiredDrawTransition oldWidget) =>
      progress != oldWidget.progress;
}
