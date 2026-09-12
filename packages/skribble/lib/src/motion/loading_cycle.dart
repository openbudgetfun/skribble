import 'package:flutter/widgets.dart';

import 'wired_motion.dart';

/// Internal clock shared by loaders and skeleton ink. Never owns a borrowed
/// animation. Muted and reduced-motion subtrees detach from external ticks.
class WiredLoadingCycle extends StatefulWidget {
  /// Creates an internal, policy-aware clock for a paint signal.
  const WiredLoadingCycle({
    super.key,
    required this.duration,
    required this.animating,
    required this.builder,
    this.progress,
  });

  /// Length of a complete loop.
  final Duration duration;

  /// Whether the consumer permits repeating motion.
  final bool animating;

  /// Optional borrowed signal, owned by the caller.
  final Animation<double>? progress;

  /// Builds the paint consumer when its signal or motion policy changes.
  final Widget Function(BuildContext, Animation<double>) builder;

  @override
  State<WiredLoadingCycle> createState() => _WiredLoadingCycleState();
}

class _WiredLoadingCycleState extends State<WiredLoadingCycle>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this);
  bool _enabled = false;

  void _sync() {
    _enabled =
        widget.animating &&
        WiredMotion.enabledOf(context) &&
        TickerMode.of(context);
    _controller.duration = widget.duration;

    if (_enabled && widget.progress == null) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(WiredLoadingCycle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) _controller.stop();
    _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
    context,
    _enabled
        ? widget.progress ?? _controller
        : const AlwaysStoppedAnimation(.25),
  );
}
