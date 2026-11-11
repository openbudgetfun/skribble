import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../rough/skribble_rough.dart';
import '../wired_theme.dart';
import '../wired_theme_scope.dart';
import 'wired_motion.dart';

/// Makes the hand-drawn lines of its child "boil": every Wired outline,
/// hatch, and doodle is redrawn a few times a second with a slightly
/// different wobble, the way hand-drawn animation redraws each frame.
///
/// The child stays put: text, layout, and hit testing never move, and each
/// frame is the same shape drawn by a fresh hand. Wrap a focal element, such
/// as a logo, an empty-state doodle, or a call to action, rather than a whole
/// screen: every frame rebuilds the subtree's ink.
///
/// ```dart
/// WiredBoil(child: WiredDoodle(kind: WiredDoodleKind.sun, size: 96))
/// ```
///
/// With motion off ([WiredMotion], `WiredThemeData.motionEnabled`, or the
/// platform's reduced-motion setting), while [enabled] is false, or while
/// tickers are muted, the child shows its usual drawing and nothing ticks.
class WiredBoil extends StatefulWidget {
  /// Creates a boiling subtree.
  const WiredBoil({
    super.key,
    required this.child,
    this.enabled = true,
    this.framesPerSecond = 8,
    this.drawings = 3,
  }) : assert(framesPerSecond > 0),
       assert(drawings >= 2);

  /// The widgets whose ink boils.
  final Widget child;

  /// Whether the ink boils. Toggle it to boil only on hover or focus.
  final bool enabled;

  /// How many times a second the ink is redrawn. Eight ("on threes") reads
  /// as hand-drawn; twelve ("on twos") is livelier.
  final double framesPerSecond;

  /// How many different drawings to cycle through. The first is the
  /// child's usual drawing.
  final int drawings;

  /// The seed offset of the drawing [context] is boiling through: zero
  /// outside a [WiredBoil] or while it rests.
  ///
  /// Shapes that pick their own seed add this to it, so they boil along
  /// with the theme's ink.
  static int seedOffsetOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_BoilFrame>()?.offset ?? 0;

  @override
  State<WiredBoil> createState() => _WiredBoilState();
}

class _WiredBoilState extends State<WiredBoil>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  WiredThemeData? _base;
  List<WiredThemeData> _themes = const [];
  int _frame = 0;
  bool _motion = true;

  /// A prime stride keeps the drawings unrelated to neighbouring seeds.
  static const int _stride = 7919;

  void _tick(Duration elapsed) {
    final frame =
        (elapsed.inMicroseconds * widget.framesPerSecond / 1e6).floor() %
        widget.drawings;
    if (frame != _frame) setState(() => _frame = frame);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion = WiredMotion.enabledOf(context);
    final base = WiredTheme.of(context);
    if (base != _base) {
      _base = base;
      _themes = _drawingsFor(base);
    }
    _sync();
  }

  @override
  void didUpdateWidget(WiredBoil oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drawings != widget.drawings) {
      _themes = _drawingsFor(_base!);
      _frame %= widget.drawings;
    }
    _sync();
  }

  List<WiredThemeData> _drawingsFor(WiredThemeData base) {
    final DrawConfig config = base.drawConfig;
    return [
      base,
      for (var i = 1; i < widget.drawings; i++)
        base.copyWith(
          drawConfig: config.copyWith(seed: config.seed + i * _stride),
        ),
    ];
  }

  void _sync() {
    final boil = widget.enabled && _motion;
    if (boil && !_ticker.isActive) {
      _ticker.start();
    } else if (!boil) {
      if (_ticker.isActive) _ticker.stop();
      _frame = 0;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The scope is always there, so moving between drawings never changes
    // the tree's shape or the child's state.
    return _BoilFrame(
      offset: _frame * _stride,
      child: WiredThemeScope(data: _themes[_frame], child: widget.child),
    );
  }
}

class _BoilFrame extends InheritedWidget {
  const _BoilFrame({required this.offset, required super.child});

  final int offset;

  @override
  bool updateShouldNotify(_BoilFrame oldWidget) => offset != oldWidget.offset;
}
