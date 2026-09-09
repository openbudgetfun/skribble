import 'package:flutter/widgets.dart';

import 'wired_motion.dart';

/// Internal bridge from Flutter button states to paint-only pen pressure.
///
/// The underlying control retains gesture, focus, and semantics ownership.
class WiredInkResponse extends StatefulWidget {
  /// Builds a control using the supplied states controller.
  const WiredInkResponse({super.key, required this.builder});

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
    with SingleTickerProviderStateMixin {
  final _states = WidgetStatesController();
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _states.addListener(_updatePressure);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = WiredMotion.enabledOf(context);
    if (enabled != _enabled) {
      _enabled = enabled;
      _updatePressure();
    }
  }

  void _updatePressure() {
    final states = _states.value;
    final target = !_enabled || states.contains(WidgetState.disabled)
        ? 0.0
        : states.contains(WidgetState.pressed)
        ? 1.0
        : states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)
        ? 0.5
        : 0.0;
    if (!_enabled || states.contains(WidgetState.disabled)) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _InkPressure(
    pressure: _controller,
    child: Builder(builder: (context) => widget.builder(context, _states)),
  );
}

class _InkPressure extends InheritedWidget {
  const _InkPressure({required this.pressure, required super.child});
  final Animation<double> pressure;

  @override
  bool updateShouldNotify(_InkPressure oldWidget) =>
      pressure != oldWidget.pressure;
}
