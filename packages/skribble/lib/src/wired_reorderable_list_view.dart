import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'const.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';

/// A hand-drawn version of Flutter's [ReorderableListView].
///
/// Each item is wrapped in a sketchy rounded-rectangle border.
/// The drag handle has a hand-drawn grip icon drawn via [WiredCanvas].
class WiredReorderableListView extends HookWidget {
  /// The list of items to display. Each must have a unique [Key].
  final List<Widget> children;

  /// Called when a child is dropped into a new position.
  final ReorderCallback onReorder;

  /// Padding around the entire list.
  final EdgeInsets padding;

  /// Height of the hand-drawn border for each item.
  final double itemHeight;

  /// Border radius of item cards.
  final double borderRadius;

  /// Whether to show the drag handle on each item.
  final bool showDragHandle;

  const WiredReorderableListView({
    super.key,
    required this.children,
    required this.onReorder,
    this.padding = const EdgeInsets.all(8),
    this.itemHeight = 56,
    this.borderRadius = 8,
    this.showDragHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    return buildWiredElement(
      child: ReorderableListView(
        onReorder: onReorder,
        padding: padding,
        proxyDecorator: _proxyDecorator,
        buildDefaultDragHandles: !showDragHandle,
        children: [
          for (var i = 0; i < children.length; i++)
            _WiredReorderableItem(
              key: children[i].key,
              index: i,
              height: itemHeight,
              borderRadius: borderRadius,
              showDragHandle: showDragHandle,
              child: children[i],
            ),
        ],
      ),
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(animation.value);
        final elevation = _lerpDouble(0, 6, t);
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(borderRadius),
          child: child,
        );
      },
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

class _WiredReorderableItem extends StatelessWidget {
  final Widget child;
  final int index;
  final double height;
  final double borderRadius;
  final bool showDragHandle;

  const _WiredReorderableItem({
    super.key,
    required this.child,
    required this.index,
    required this.height,
    required this.borderRadius,
    required this.showDragHandle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: WiredCanvas(
              painter: WiredRoundedRectangleBase(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              fillerType: RoughFilter.noFiller,
            ),
          ),
          Row(
            children: [
              if (showDragHandle)
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.drag_handle, color: textColor, size: 20),
                  ),
                ),
              Expanded(child: child),
            ],
          ),
        ],
      ),
    );
  }
}
