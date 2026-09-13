import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Base widget that wraps children with [RepaintBoundary] to isolate repaints.
abstract class WiredBaseWidget extends HookWidget {
  /// Creates a repaint-isolated wired widget.
  const WiredBaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: buildWiredElement());
  }

  /// Builds the widget subtree that the [RepaintBoundary] isolates.
  Widget buildWiredElement();
}

/// Mixin for isolating repaints.
abstract mixin class WiredRepaintMixin {
  /// Wraps [child] in a [RepaintBoundary] keyed by [key].
  Widget buildWiredElement({Key? key, required Widget child}) {
    return RepaintBoundary(key: key, child: child);
  }
}

/// Wraps [child] in a [RepaintBoundary] keyed by [key].
Widget buildWiredElement({Key? key, required Widget child}) {
  return RepaintBoundary(key: key, child: child);
}
