import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../wired_theme.dart';
import 'wired_draw.dart';
import 'wired_ink_interaction.dart';
import 'wired_motion.dart';

/// Internal bridge from Flutter button states to paint-only pen pressure.
///
/// The underlying control retains gesture, focus, and semantics ownership.
class WiredInkResponse extends StatefulWidget {
  /// Builds a control using the supplied states controller.
  const WiredInkResponse({super.key, required this.builder, this.interaction});

  /// Optional per-control override of the theme's interaction style.
  final WiredInkInteraction? interaction;

  /// Must pass the controller to the underlying Flutter control.
  final Widget Function(BuildContext context, WidgetStatesController states)
  builder;

  /// Returns the nearest button's ink pressure, respecting motion policy.
  static Animation<double>? pressureOf(BuildContext context) {
    if (!WiredMotion.enabledOf(context)) return null;
    final pressure = context
        .dependOnInheritedWidgetOfExactType<_InkPressure>()
        ?.pressure;
    if (pressure == null || TickerMode.of(context)) return pressure;
    return AlwaysStoppedAnimation(pressure.value);
  }

  @override
  State<WiredInkResponse> createState() => _WiredInkResponseState();
}

class _WiredInkResponseState extends State<WiredInkResponse>
    with TickerProviderStateMixin {
  final _states = WidgetStatesController();
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  bool _enabled = true;
  bool _pressed = false;
  WiredInkInteraction _interaction = WiredInkInteraction.pressure;
  late final _redraw = AnimationController(
    vsync: this,
    value: 1,
    duration: const Duration(milliseconds: 360),
  );
  late final Animation<double> _drawProgress = _redraw.drive(
    CurveTween(curve: Curves.easeOutCubic),
  );
  Animation<double>? _parentProgress;
  Animation<double>? _combinedProgress;

  @override
  void initState() {
    super.initState();
    _states.addListener(_updatePressure);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _enabled = WiredMotion.enabledOf(context) && TickerMode.of(context);
    _interaction = widget.interaction ?? WiredTheme.of(context).inkInteraction;
    _parentProgress = WiredDrawTransition.progressOf(context);
    _combinedProgress = _parentProgress == null
        ? _drawProgress
        : _InkProgress(first: _parentProgress!, next: _drawProgress);
    _updatePressure();
  }

  @override
  void didUpdateWidget(WiredInkResponse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.interaction == widget.interaction) return;
    _interaction = widget.interaction ?? WiredTheme.of(context).inkInteraction;
    _updatePressure();
  }

  void _updatePressure() {
    final states = _states.value;
    final idle =
        !_enabled ||
        states.contains(WidgetState.disabled) ||
        _interaction == WiredInkInteraction.none;
    final pressed = states.contains(WidgetState.pressed);
    if (idle || _interaction != WiredInkInteraction.redraw) {
      _redraw.value = 1;
    } else if (pressed && !_pressed) {
      _redraw.forward(from: 0);
    }
    _pressed = pressed;
    final target = idle
        ? 0.0
        : states.contains(WidgetState.pressed)
        ? 1.0
        : states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)
        ? 0.5
        : 0.0;
    if (idle) {
      _controller.value = target;
    } else {
      _controller.animateTo(target, curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _states.removeListener(_updatePressure);
    _states.dispose();
    _controller.dispose();
    _redraw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _InkPressure(
    pressure: _controller,
    child: WiredDrawTransition(
      progress: _combinedProgress ?? _drawProgress,
      child: Builder(builder: (context) => widget.builder(context, _states)),
    ),
  );
}

/// Interaction ink never reveals more than an enclosing entrance permits.
class _InkProgress extends CompoundAnimation<double> {
  _InkProgress({required super.first, required super.next});

  @override
  double get value => math.min(first.value, next.value);
}

class _InkPressure extends InheritedWidget {
  const _InkPressure({required this.pressure, required super.child});
  final Animation<double> pressure;

  @override
  bool updateShouldNotify(_InkPressure oldWidget) =>
      pressure != oldWidget.pressure;
}
